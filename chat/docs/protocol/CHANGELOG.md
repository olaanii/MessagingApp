# Protocol / generated client — changelog

Tracks **contract changes** between the Serverpod server (`chat_server/`) and Flutter consumers (`chat_client/` + app). Hand-written sketches under [`docs/protocol/v1/`](v1/README.md) follow the product spec until merged into the server; this file focuses on **committed** protocol changes that require coordinated app or server releases.

## How to use this file

1. **When to add an entry**
   - Any change that requires **regenerating** the client (`serverpod generate`) *and* updating app code, **or**
   - Any **wire-format** change that old apps cannot understand (new required fields, renamed RPC/stream events, removed types).

2. **When a line in this file is optional**
   - Internal server refactors with **no** generated Dart diff.
   - Backward-compatible additions if old clients ignore unknown fields (still document in PR description for clarity).

3. **Process (recommended)**
   - Update `chat_server` protocol (YAML / endpoints / streams).
   - Run `serverpod generate` (see [Serverpod runbook](../serverpod-runbook.md)).
   - Add a section below with **date**, **PR / commit**, **bump label** (`PATCH` / `MINOR` / `MAJOR` for client contract), and **migration notes** for app teams.
   - If security or trust boundaries move, add or update an [ADR](../adr/README.md).

4. **CI**
   - Fail builds when generated files are not committed (see [ci-cd.md](../infra/ci-cd.md)).

## Bump semantics (suggested)

| Label | Meaning for Flutter apps |
|-------|---------------------------|
| **PATCH** | Regenerate + rebuild only; no source changes required |
| **MINOR** | Regenerate; optional new methods/events; old call paths still work |
| **MAJOR** | Regenerate **and** mandatory code changes (removed/changed RPC, breaking stream payloads, required model fields) |

## Entries

<!-- Newest first -->

### Template (copy for each release)

```
### YYYY-MM-DD — vX.Y (MAJOR|MINOR|PATCH)

- **PR / commit:** …
- **Summary:** …
- **App action:** Regenerate only | Update session code | Update sync | …
- **ADR:** … (if any)
```

### 2026-03-27 — baseline (initial Serverpod 3.4 project)

- **Summary:** Scaffold server + generated `chat_client` as created for this repo; no stable messaging protocol yet.
- **App action:** When protocol stabilizes, pin app dependency on `chat_client` path and follow entries above.
