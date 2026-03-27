# Serverpod protocol v1 (documentation sketch)

**Normative product contract** for the Flutter app ↔ Serverpod server. When the Serverpod server project exists (e.g. `chat_server/`), copy or merge these definitions into the server’s `protocol/` directory and run **`serverpod generate`**; commit generated Dart for client + server per Serverpod docs.

| File | Purpose |
|------|---------|
| [`models.yaml`](models.yaml) | Serializable **classes** (YAML) — Serverpod `class` / `fields` syntax |
| [`endpoints.md`](endpoints.md) | **Endpoint methods** (Dart class names + params) — implemented as `Endpoint` subclasses on the server |

Streaming event names and envelopes align with [`mvp_plan.md`](../../mvp_plan.md) §Realtime / streaming event catalog.

When definitions are merged into `chat_server/` and shipped, record **breaking** client contract changes in [`../CHANGELOG.md`](../CHANGELOG.md).
