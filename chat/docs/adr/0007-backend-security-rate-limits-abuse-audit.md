# ADR-0007: Backend security — rate limits, abuse, audit events, log redaction

## Status

Accepted

## Context

Serverpod RPC and streaming carry **authenticated** traffic bound to `user_id`, `device_id`, and optionally IP / AS data at the edge. Message bodies are **ciphertext** (ADR-0006); mitigations here target **credential abuse**, **flooding**, **spam/scam tooling**, **session theft**, and **metadata leakage via logs**.

Dependencies: ADR-0003 (session + device), ADR-0004 (streaming envelope + limits pointer), [`mvp_plan.md`](../../mvp_plan.md) Backend security brief.

## Decision

### 1) Rate and quota limits (MVP)

Apply **layered** limits; return typed error codes for Flutter (e.g. `RATE_LIMIT_AUTH`, `RATE_LIMIT_RPC`, `RATE_LIMIT_STREAM`, `RATE_LIMIT_MESSAGE`).

| Surface | Scope | MVP policy (tune per env) |
|---------|--------|---------------------------|
| **Auth** | `exchangeFirebaseToken`, `refreshSession` | Per **IP** + per **firebase_uid** (after first success): burst + sliding window; stricter on repeated failures |
| **RPC** | All endpoints | Per **user_id** + per **device_id** global bucket; stricter buckets for `send`, `prepareUpload`, `registerToken` |
| **Streaming** | Connect + frames | Max connections per `user_id` / `device_id`; max **events/sec** per connection; max payload size (ADR-0004); idle disconnect |
| **Message path** | `send` + stream `send_message` | Per **chat_id** + per **sender**: cap messages/min to contain automation |

**Implementation note:** Prefer Serverpod middleware / endpoint guards + optional Redis (or Postgres-backed counters) when horizontal scale warrants it — document which store backs counters per deployment.

### 2) Reports and blocks

- **`reports`:** persist `reporter_id`, target (`user_id` / `chat_id` / `message_id` as applicable), `reason` enum, `created_at`. No ciphertext in report payload beyond opaque **message id** references.
- **`blocks`:** composite PK `(blocker_id, blocked_id)`; enforce **no delivery** paths between blocked pairs where product requires it (server-side filter on fan-out / RPC list).
- **Moderation stub:** export or admin-only list endpoint **Phase 2** unless compliance requires MVP; MVP may be DB-only review.

### 3) Device reputation (MVP heuristics)

Signals (examples): rapid session churn, parallel connections from many IPs, repeated rate-limit hits, abnormal `send` volume vs account age. Outcome: **soft throttle** → **hard block** for device or user with manual override hook for support. Keep rules **versioned** in config for tuning without code deploy where possible.

### 4) Session hardening

- Short-lived access + refresh rotation per ADR-0003; **revoke** on logout and on abuse flag.
- Bind critical operations to **current** `device_id` and session id; reject mismatched context.
- Optional: require recent Firebase token refresh for high-risk RPC (policy with architect).

### 5) Audit events (security-relevant, not full request dumps)

Emit **structured** events (to log sink or `audit_log` table) for: successful/failed token exchange, session revoke, device revoke, rate-limit threshold crossed, report filed, block created, admin/mod actions (when they exist). Fields: `event`, `timestamp`, `requestId`, `userId?`, `deviceId?`, `outcome`, **no** message body, **no** decryption keys.

### 6) Logging and PII redaction

- **Never** log message **plaintext** or ciphertext blobs at `info`/`warn`; if debug needed in dev only, gate behind flag and truncate.
- Redact or hash: phone numbers, email, full Firebase UID in default logs (keep internal `user_id` where needed for correlation).
- Standard HTTP headers: set sensible **security headers** on Serverpod HTTP surface (CORS allowlist for known app origins; `nosniff`; review `COOP`/`CORP` if web client ships).

### 7) Supply chain

- Run **`dart pub audit`** in CI where available; **pin** Serverpod (and Firebase Admin) versions; document upgrade cadence with Infra.

### 8) Abuse test matrix (acceptance)

| Case | Expected |
|------|----------|
| Token exchange spam from one IP | 429 + optional temporary IP block |
| Burst `send` over cap | 429 `RATE_LIMIT_MESSAGE` |
| Duplicate stream connections same device | Oldest dropped or merged per policy |
| Report submission flood | Per-user cap |
| Logs under load | Grep fails for phone / message body patterns |

## Consequences

- Backend security work **touches** middleware/guards and **does not** change ciphertext message shapes without architect/RPC ACK.
- Flutter maps error codes to user-visible strings (compliance agent + copy).
- Tuning values live in **config** per env; staging documents baseline numbers before prod.

## Implementation (chat_server)

| Area | Location |
|------|----------|
| Limits + reputation | `chat_server/lib/src/security/security_guards.dart`, `security_config.dart`, `sliding_window_limiter.dart`, `device_reputation.dart` |
| Audit helpers | `chat_server/lib/src/security/security_audit.dart` |
| Serializable `RateLimitException` | `chat_server/lib/src/security/rate_limit_exception.spy.yaml` → generated client `chat_client/.../rate_limit_exception.dart` |
| Safety RPC | `chat_server/lib/src/safety/safety_endpoint.dart` (`submitReport`, `blockUser`); tables `safety_report`, `safety_block` + migration `migrations/20260327161831530/` |
| Streaming limits + block fan-out | `chat_stream_endpoint.dart` (connect, per-second frames, send_message/min); `chat_stream_hub.dart` + `safety_block_fanout.dart` (**skip** delivery to subscribers who blocked the sender) |
| Media / greeting RPC | `media_endpoint.dart`, `greeting_endpoint.dart` |
| Auth path throttles | `jwt_refresh_endpoint.dart`, `throttled_email_idp_endpoint.dart` |
| Tests | `chat_server/test/security/sliding_window_limiter_test.dart` |

## Related

- [ADR-0001](0001-adr-process-versioning-firebase-serverpod.md) — security sign-off checklist  
- [ADR-0004](0004-streaming-protocol-v1.md) — stream limits cross-reference  
