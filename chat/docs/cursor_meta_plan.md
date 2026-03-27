# Cursor plan export — pointers

This file tracks the **active Cursor plan** for documentation work and links the canonical sources in-repo.

| Canonical doc | Purpose |
|---------------|---------|
| [**Docs index**](./README.md) | Monorepo doc map, local run summary, **Firebase + Serverpod** diagram, staging URL table |
| [**Serverpod runbook**](./serverpod-runbook.md) | `serverpod generate`, env vars, local DB/server, troubleshooting |
| [`../mvp_plan.md`](../mvp_plan.md) | Product spec, hybrid **Serverpod + PostgreSQL + Firebase Auth/FCM**, phased Firestore cutover, agent briefs, schedules (**§ Compliance** = store UGC checklist + [`lib/core/compliance/store_compliance_copy.dart`](../lib/core/compliance/store_compliance_copy.dart)) |
| [ADRs](./adr/README.md) | Architecture decisions (Serverpod protocol boundary, Firebase token exchange, streaming, sync, E2EE scope, [Phase 2 AI / privacy prep](./adr/0010-phase2-ai-privacy-opt-in.md)) |
| [Protocol v1 sketch](./protocol/v1/) | YAML **serializable models** + endpoint catalog to copy into `{{PROJECT}}_server/protocol/` |
| [Protocol changelog](./protocol/CHANGELOG.md) | Breaking protocol / generated-client contract notes |

## Plan alignment rule

The expand-MVP plan targets **Serverpod + Firebase** (Dart server + generated Flutter client), **not** NestJS/OpenAPI/npm backends. If external artifacts drift, **re-sync from `mvp_plan.md`**.

## Todos (maintenance)

- [x] **`chat_server/` + `chat_client/`:** Serverpod 3.4; realtime: `ChatStreamEndpoint.chatRoom`, `ChatStreamEnvelope`, in-memory `ChatStreamHub` ([ADR-0009](adr/0009-streaming-fanout-scale.md), [endpoints.md](protocol/v1/endpoints.md)). Run `serverpod generate` in `chat_server/` after `*.spy.yaml` or endpoint edits.
- [ ] Replace Provider/Hive/Firestore messaging per additive tables in `mvp_plan.md`.
- [ ] Keep ADR index updated when protocol version bumps.

Replace `{{PROJECT}}` with your Serverpod module name (e.g. `chat_server`).
