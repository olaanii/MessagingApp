-- PostgreSQL v1 physical schema — DBA handoff for Serverpod migrations
-- Align with: mvp_plan.md §8, docs/protocol/v1/models.yaml, ADR-0005 (sync cursor / server_seq).
-- Translate to Serverpod migration SQL; keep PK/FK and index definitions in lockstep with generated models.
--
-- Target: PostgreSQL 15+ (gen_random_uuid, improved MERGE). Adjust if prod is 14.

-- -----------------------------------------------------------------------------
-- Idempotency & monotonic server_seq (application / transaction pattern)
-- -----------------------------------------------------------------------------
-- ADR-0005: server_seq is bigint, monotonic PER chat_id, assigned atomically on insert.
-- Recommended pattern in one transaction:
--   1) LOCK chats IN ROW SHARE MODE; 2) read/update counter:
--      UPDATE chats
--        SET latest_server_seq = COALESCE(latest_server_seq, 0) + 1,
--            last_activity_at = now(),
--            updated_at = now()
--      WHERE id = :chat_id
--      RETURNING latest_server_seq;
--   3) INSERT INTO messages (..., server_seq) VALUES (..., returned_seq);
-- Alternative: dedicated chat_seq_counters table with (chat_id PK, next_seq bigint) + same tx.
-- Do not rely on MAX(server_seq)+1 under concurrency without locking.

BEGIN;

-- -----------------------------------------------------------------------------
-- Core identity & sessions
-- -----------------------------------------------------------------------------

CREATE TABLE users (
  id                  TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  firebase_uid        TEXT NOT NULL,
  display_name        TEXT,
  photo_url           TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at          TIMESTAMPTZ,
  CONSTRAINT users_firebase_uid_key UNIQUE (firebase_uid)
);

CREATE INDEX idx_users_updated_active
  ON users (updated_at DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE devices (
  id                  TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id             TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  -- Opaque client device id from ADR-0003 (stable across reinstalls if client enforces)
  device_id           TEXT NOT NULL,
  name                TEXT,
  platform            TEXT NOT NULL,
  last_seen_at        TIMESTAMPTZ,
  public_key_ref      TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  revoked_at          TIMESTAMPTZ,
  CONSTRAINT devices_user_device_uid UNIQUE (user_id, device_id)
);

CREATE INDEX idx_devices_user
  ON devices (user_id)
  WHERE revoked_at IS NULL;

CREATE TABLE sessions (
  id                    TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  user_id               TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  device_row_id         TEXT NOT NULL REFERENCES devices (id) ON DELETE CASCADE,
  refresh_token_hash    TEXT NOT NULL,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  revoked_at            TIMESTAMPTZ,
  last_rotated_at       TIMESTAMPTZ
);

CREATE INDEX idx_sessions_user_active
  ON sessions (user_id, created_at DESC)
  WHERE revoked_at IS NULL;

CREATE INDEX idx_sessions_device
  ON sessions (device_row_id)
  WHERE revoked_at IS NULL;

-- -----------------------------------------------------------------------------
-- Chats & membership (inbox + ACL)
-- -----------------------------------------------------------------------------

CREATE TABLE chats (
  id                    TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  type                  TEXT NOT NULL, -- 'direct' | 'group' — enforce via CHECK or app
  title                 TEXT,
  created_by_user_id    TEXT REFERENCES users (id),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ,
  -- Per-chat monotonic assigner; see header comment for increment in same tx as message insert
  latest_server_seq     BIGINT NOT NULL DEFAULT 0,
  last_activity_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_chats_last_activity_active
  ON chats (last_activity_at DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE chat_members (
  chat_id               TEXT NOT NULL REFERENCES chats (id) ON DELETE CASCADE,
  user_id               TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  role                  TEXT NOT NULL DEFAULT 'member',
  joined_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_read_seq         BIGINT,
  muted_until           TIMESTAMPTZ,
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  left_at               TIMESTAMPTZ,
  PRIMARY KEY (chat_id, user_id)
);

-- Inbox: all memberships for a user (hot path)
CREATE INDEX idx_chat_members_user
  ON chat_members (user_id)
  WHERE left_at IS NULL;

-- Fan-out / ACL checks
CREATE INDEX idx_chat_members_chat
  ON chat_members (chat_id)
  WHERE left_at IS NULL;

-- Optional: partial for “needs sync” queries if you track per-user cursor in DB later
-- CREATE INDEX idx_chat_members_user_updated ON chat_members (user_id, updated_at DESC);

-- -----------------------------------------------------------------------------
-- Messages (ciphertext only at rest) + media link table
-- -----------------------------------------------------------------------------

CREATE TABLE messages (
  id                    TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  chat_id               TEXT NOT NULL REFERENCES chats (id) ON DELETE CASCADE,
  sender_user_id        TEXT NOT NULL REFERENCES users (id),
  sender_device_id      TEXT NOT NULL,
  server_seq            BIGINT NOT NULL,
  client_msg_id         TEXT NOT NULL,
  ciphertext            TEXT NOT NULL,
  nonce                 TEXT NOT NULL,
  schema_version        INTEGER NOT NULL DEFAULT 1,
  content_type          TEXT,
  reply_to_message_id   TEXT REFERENCES messages (id),
  deleted_at            TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT messages_chat_seq_key UNIQUE (chat_id, server_seq),
  CONSTRAINT messages_idem_key UNIQUE (chat_id, sender_device_id, client_msg_id)
);

-- Sync/history: primary index per ADR + plan brief
CREATE INDEX idx_messages_chat_seq_desc
  ON messages (chat_id, server_seq DESC);

-- Visible thread reads (server or client filter; partial reduces index size)
CREATE INDEX idx_messages_chat_seq_visible
  ON messages (chat_id, server_seq DESC)
  WHERE deleted_at IS NULL;

CREATE TABLE message_media (
  message_id            TEXT NOT NULL REFERENCES messages (id) ON DELETE CASCADE,
  media_id              TEXT NOT NULL,
  sort_order            INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (message_id, media_id)
);

CREATE INDEX idx_message_media_media
  ON message_media (media_id);

CREATE TABLE media_objects (
  id                    TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  uploader_id           TEXT NOT NULL REFERENCES users (id),
  storage_key           TEXT NOT NULL,
  mime                  TEXT,
  size_bytes            BIGINT,
  sha256                BYTEA,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at            TIMESTAMPTZ
);

CREATE INDEX idx_media_uploader_created
  ON media_objects (uploader_id, created_at DESC)
  WHERE deleted_at IS NULL;

-- -----------------------------------------------------------------------------
-- E2EE public material (server never stores private keys)
-- -----------------------------------------------------------------------------

CREATE TABLE public_key_bundles (
  device_row_id         TEXT PRIMARY KEY REFERENCES devices (id) ON DELETE CASCADE,
  user_id               TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  bundle_json           TEXT NOT NULL,
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  replenish_at          TIMESTAMPTZ
);

CREATE INDEX idx_public_key_bundles_user
  ON public_key_bundles (user_id);

-- -----------------------------------------------------------------------------
-- Push & safety
-- -----------------------------------------------------------------------------

CREATE TABLE push_tokens (
  id                    TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  device_row_id         TEXT NOT NULL REFERENCES devices (id) ON DELETE CASCADE,
  user_id               TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  token                 TEXT NOT NULL,
  platform              TEXT NOT NULL,
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT push_tokens_device_key UNIQUE (device_row_id)
);

CREATE INDEX idx_push_tokens_user
  ON push_tokens (user_id);

CREATE TABLE blocks (
  blocker_id            TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  blocked_id            TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id),
  CONSTRAINT blocks_no_self CHECK (blocker_id <> blocked_id)
);

CREATE INDEX idx_blocks_blocked
  ON blocks (blocked_id);

CREATE TABLE reports (
  id                    TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  reporter_id           TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  reported_user_id      TEXT REFERENCES users (id) ON DELETE SET NULL,
  reported_chat_id      TEXT REFERENCES chats (id) ON DELETE SET NULL,
  reported_message_id   TEXT REFERENCES messages (id) ON DELETE SET NULL,
  reason                TEXT NOT NULL,
  details               TEXT,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_reports_created
  ON reports (created_at DESC);

COMMIT;

-- =============================================================================
-- Partitioning (Phase 2+) — note only; do not apply in MVP without load proof
-- =============================================================================
-- When messages row count or churn forces it:
--   - RANGE partition `messages` on `created_at` (monthly) or on hash(chat_id).
--   - Keep PRIMARY KEY + UNIQUE constraints partition-local; consider surrogate
--     bigserial and (chat_id, server_seq) UNIQUE per partition via composite PK
--     including partition key — requires migration design with zero downtime.
--   - Rebuild indexes per partition; monitor autovacuum on hot partitions.

-- =============================================================================
-- EXPLAIN / acceptance templates (run against staging with production-like stats)
-- =============================================================================
-- Inbox (user’s chats, latest activity):
--   EXPLAIN (ANALYZE, BUFFERS)
--   SELECT c.id, c.type, c.title, c.last_activity_at, c.latest_server_seq, m.last_read_seq
--   FROM chat_members m
--   JOIN chats c ON c.id = m.chat_id AND c.deleted_at IS NULL
--   WHERE m.user_id = :uid AND m.left_at IS NULL
--   ORDER BY c.last_activity_at DESC
--   LIMIT 50;
-- Expect: index scan on idx_chat_members_user + nested loop to chats PK;
--   sort may use idx_chats_last_activity if planner chooses merge.
--
-- Sync batch after cursor (opaque cursor decodes to server_seq boundary in app layer):
--   EXPLAIN (ANALYZE, BUFFERS)
--   SELECT id, server_seq, sender_user_id, ciphertext, deleted_at, created_at
--   FROM messages
--   WHERE chat_id = :cid AND server_seq > :since
--   ORDER BY server_seq ASC
--   LIMIT 100;
-- Expect: index-only or index scan on idx_messages_chat_seq_desc (backward scan ASC range).

-- =============================================================================
-- Seeds (staging / dev only — never ship real Firebase UIDs in repo secrets)
-- =============================================================================
-- INSERT INTO users (id, firebase_uid, display_name) VALUES
--   ('usr_seed_1', 'dev-firebase-uid-1', 'Seed Alice'),
--   ('usr_seed_2', 'dev-firebase-uid-2', 'Seed Bob');
-- INSERT INTO chats (id, type, title, latest_server_seq, last_activity_at) VALUES
--   ('cht_seed_1', 'direct', NULL, 0, now());
-- INSERT INTO chat_members (chat_id, user_id, role) VALUES
--   ('cht_seed_1', 'usr_seed_1', 'member'),
--   ('cht_seed_1', 'usr_seed_2', 'member');
