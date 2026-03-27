# ADR-0001: ADR process, versioning, and MVP security sign-off

## Status

Accepted

## Decision

1. ADRs live in `docs/adr/` with sequential IDs; accepted ADRs are amended only by a **new** superseding ADR.
2. **Protocol v1:** serializable models in [`docs/protocol/v1/models.yaml`](../protocol/v1/models.yaml) are copied into the Serverpod server `protocol/` tree; **generated** client code is the network DTO source of truth after `serverpod generate`.
3. **Breaking changes** bump protocol major (v1 → v2) and require migration notes in a new ADR.
4. **Firebase + Serverpod:** Firebase remains **identity + FCM**; Postgres is **system of record** for messaging; Firestore message paths are **deprecated** per phased flags in `mvp_plan.md`.

## MVP security sign-off checklist

| # | Item |
|---|------|
| 1 | TLS 1.2+ on all client ↔ Serverpod traffic |
| 2 | Firebase Admin credentials only in vault/env; verify ID tokens server-side |
| 3 | Access token TTL ≤ 15 min; refresh rotation + reuse detection per ADR-0003 |
| 4 | Rate limits: token exchange, message send, streaming connect |
| 5 | Logs redact: no message plaintext, no refresh tokens, minimal PII |
| 6 | CORS allowlist (web); no wildcard origins with credentials in prod |
| 7 | Streaming auth equals RPC session; short-lived tokens only |
