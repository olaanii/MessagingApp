# Architecture Decision Records (ADRs) — Serverpod + Firebase

Immutable once **Accepted**; supersede with a new numbered ADR. Aligned with [`mvp_plan.md`](../../mvp_plan.md).

| ADR | Title |
|-----|--------|
| [0001](0001-adr-process-versioning-firebase-serverpod.md) | ADR process, `/v1` contracts, security sign-off checklist |
| [0002](0002-backend-serverpod-postgresql-firebase.md) | Backend: Serverpod + PostgreSQL; Firebase Auth + FCM boundary |
| [0003](0003-firebase-token-serverpod-session-device-binding.md) | Firebase ID token → Serverpod session + `device_id` |
| [0004](0004-streaming-protocol-v1.md) | Streaming / realtime envelope v1 |
| [0005](0005-sync-cursor-strategy.md) | Sync cursors + `server_seq` |
| [0006](0006-e2ee-mvp-vs-phase2.md) | E2EE MVP vs Phase 2 (Double Ratchet) |
| [0007](0007-backend-security-rate-limits-abuse-audit.md) | Rate limits, abuse (reports/blocks), audit events, log redaction |
| [0008](0008-e2ee-crypto-suite-key-lifecycle.md) | E2EE algorithms, wire shapes, FS statement, recovery, implementation map |
| [0008](0008-flutter-feature-layout-riverpod-migration.md) | Flutter feature layout, Provider→Riverpod migration, Serverpod client shell |
| [0009](0009-streaming-fanout-scale.md) | Streaming fan-out: single instance vs Redis / scale-out |
| [0010](0010-phase2-ai-privacy-opt-in.md) | Phase 2 AI: opt-in, DPIA-style boundary, `ai_translation_enabled`, Flutter stub |

## Product inputs (non-blocking for drafting)

- MVP identity: Firebase **phone OTP only** vs **email link** vs both.
- **Verified accounts:** default **Phase 2+** unless product requires Phase 1.

## Related paths

- Documentation index: [`../README.md`](../README.md)
- Serverpod runbook: [`../serverpod-runbook.md`](../serverpod-runbook.md)
- Protocol sketch: [`../protocol/v1/`](../protocol/v1/)
- Protocol changelog: [`../protocol/CHANGELOG.md`](../protocol/CHANGELOG.md)
- Infra / DevOps: [`../infra/README.md`](../infra/README.md)
- Cursor meta: [`../cursor_meta_plan.md`](../cursor_meta_plan.md)
