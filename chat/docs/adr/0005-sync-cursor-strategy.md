# ADR-0005: Sync cursor strategy

## Status

Accepted

## Decision

- **`server_seq`:** `bigint`, monotonic per `chat_id`, assigned atomically with insert.
- **`message.id`:** UUID primary key; **`client_msg_id`** unique per `(chat_id, sender_device_id)` (or per device globally — choose one in DB migration; document in DB engineer handoff).
- **Cursor:** opaque string returned from `SyncEndpoint.changesForChat`; encodes position for stable pagination (implementation-specific).
- **Tombstones:** deletions replicated as tombstone rows or `deleted_at`; clients apply removes idempotently.
- **Metadata conflicts:** **LWW** with server authority on timestamps for mute/roles; **message body** immutable except tombstone/edit policy (edit Phase 2 if ever).

## WebSocket

- `sync_hint` may include `latest_server_seq` to prompt Drift to pull without polling constantly.

## Consequences

- Many chats ⇒ many cursors in Drift `sync_state`; optional global inbox poll is Phase 1.1 per `mvp_plan.md` if needed.
