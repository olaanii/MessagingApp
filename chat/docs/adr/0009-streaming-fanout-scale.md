# ADR-0009: Streaming fan-out — single instance vs scale-out

## Status

Accepted (MVP default)

## Context

ADR-0004 defines the **envelope** and event types. [`ChatStreamHub`](../../chat_server/lib/src/streaming/chat_stream_hub.dart) implements fan-out **in-process** for the MVP.

## Decision (MVP)

- **Single Serverpod instance** (or sticky sessions so all chat members share one process): use `ChatStreamHub` as implemented.
- **Horizontal scale** (multiple isolates / VMs / pods): introduce one of:
  1. **Redis pub/sub** — publish `chat:{chatId}` after message persist; each instance subscribes and forwards to local `ChatStreamHub` registrations, **or**
  2. **Serverpod internal messaging** — if the project adopts server-side cluster messaging when available, route by `chatId`.

In all cases, **Postgres remains the source of truth**; streaming is **best-effort notify**; clients **must** resync via `SyncEndpoint.changesForChat` after reconnect (ADR-0005).

## Consequences

- MVP is simpler to deploy; load tests should document max concurrent streams per instance.
- Before multi-instance production, implement Redis (or equivalent) and remove reliance on cross-instance in-memory hub.

## References

- [`ChatStreamEndpoint`](../../chat_server/lib/src/streaming/chat_stream_endpoint.dart)
- [ADR-0004](0004-streaming-protocol-v1.md), [ADR-0005](0005-sync-cursor-strategy.md)
