# ADR-0004: Streaming / realtime protocol v1

## Status

Accepted

## Decision

Envelope (JSON or Serverpod-serialized DTO) fields:

| Field | Notes |
|-------|------|
| `type` | `send_message` \| `message` \| `message_ack` \| `typing` \| `presence` \| `sync_hint` \| `error` |
| `idempotencyKey` | Required on client `send_message`; matches RPC `client_msg_id` |
| `deviceId` | Authenticated device uuid |
| `chatId` | When scoped to a chat |
| `ts` | Server ms when server-originated |
| `payload` | Event body; **ciphertext** for message bodies |
| `error` | `{ code, message, requestId? }` for `type == error` |

**Ordering:** `server_seq` monotonic **per chat** (see ADR-0005). **At-least-once** delivery acceptable; client deduplicates by `message.id` / `client_msg_id`.

**Limits:** max frame size, per-connection message rate, idle timeout — tune with Backend security brief.

**Reconnect:** re-subscribe stream; catch up via **`SyncEndpoint.changesForChat`** (REST/RPC).

## Consequences

- Server must **persist** before fan-out (or mark as pending) so reconnect + RPC sync converge.
