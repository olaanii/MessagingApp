# Serverpod runbook — `chat_server` + `chat_client`

Operational guide for the Dart server and generated Flutter client. Normative product and Firebase boundaries are in [ADR-0002](adr/0002-backend-serverpod-postgresql-firebase.md) and [ADR-0003](adr/0003-firebase-token-serverpod-session-device-binding.md).

## Prerequisites

- **Dart SDK** compatible with `chat_server/pubspec.yaml` (currently `^3.8.0`).
- **Docker** (optional but recommended) for PostgreSQL and, if you use the stock `chat_server/docker-compose.yaml`, Redis.
- **Flutter** (stable channel) for the app at repo root and for regenerating the client package consumed by the app.
- **serverpod_cli** pinned to the same **major.minor** as `serverpod` in `chat_server/pubspec.yaml` (currently **3.4.x**):

  ```bash
  dart pub global activate serverpod_cli 3.4.5
  ```

  Confirm `serverpod --version` matches expectations. If the global bin is not on `PATH`, use `dart pub global run serverpod_cli:serverpod` per your platform, or follow [Serverpod installation docs](https://docs.serverpod.dev).

## Repository roles

| Artifact | Path | Notes |
|----------|------|--------|
| Server | `chat_server/` | Hand-written endpoints, `*.spy.yaml` models, migrations |
| Generated protocol + client | `chat_server/lib/src/generated/`, `chat_client/` | **Do not edit by hand** — produced by codegen |
| Generator config | `chat_server/config/generator.yaml` | Sets `client_package_path: ../chat_client` |

## Local database

**Option A — infra compose (Postgres only, from repo root):**

```bash
docker compose -f docs/infra/docker-compose.dev.yml up -d
```

Align `chat_server/config/development.yaml` (or your active config) with the host, port, database name, and credentials from that file.

**Option B — `chat_server` default compose (Postgres + Redis):**

```bash
cd chat_server
docker compose up --build --detach
```

See [`chat_server/README.md`](../chat_server/README.md) for stop/teardown.

## Run the server

From `chat_server/`:

```bash
dart pub get
dart bin/main.dart
```

To apply migrations on start (when supported by your Serverpod version and project scripts):

```bash
dart bin/main.dart --apply-migrations
```

Or use the `serverpod` script defined in `chat_server/pubspec.yaml` under `serverpod.scripts.start` if your tooling invokes it.

**Config files:** `config/development.yaml`, `config/staging.yaml`, `config/production.yaml` — never commit real secrets; use `passwords.yaml` or platform env injection per [staging-and-production.md](infra/staging-and-production.md).

## `serverpod generate` — when and how

Run codegen **after** any change to:

- Serializable class definitions (`*.spy.yaml`)
- Endpoint signatures that affect the generated protocol (per Serverpod rules for your version)
- Generator configuration (`config/generator.yaml`)

**Steps (from `chat_server/`):**

1. `dart pub get`
2. `serverpod generate`  
   (or the equivalent `dart pub global run` invocation if `serverpod` is not on PATH)
3. Review `git status`: expect updates under `lib/src/generated/` and `../chat_client/`.
4. Commit generated Dart **with** the YAML / endpoint change in the same PR so CI and other clones stay consistent.

**Flutter app dependency:** The root Flutter `pubspec.yaml` should depend on `chat_client` via `path: chat_client` (or your chosen path). After codegen, run `flutter pub get` at repo root.

**CI:** Prefer a job that fails if generated files are stale (e.g. run `serverpod generate` and `git diff --exit-code`). Outline in [infra/ci-cd.md](infra/ci-cd.md).

**Documentation sketch:** Design-only models under [`docs/protocol/v1/`](protocol/v1/README.md) are merged into the server over time; when they diverge from `chat_server`, treat the **committed server protocol** as source of truth until the sketch is updated.

## Environment variables

### Flutter client (`envied` + `.env`)

Copy [`.env.example`](../.env.example) to `.env` locally (never commit `.env`). Typical keys:

- Firebase Web/Android/iOS app identifiers and API keys for **client** SDK initialization.
- Optional: `SERVERPOD_HOST`, `SERVERPOD_PORT`, `SERVERPOD_SCHEME` when the app reads Serverpod base URL from env (staging/prod flavors).

Regenerate envied output when adding fields (`dart run build_runner build` if that is how `lib/core/env` is set up in this repo).

### Serverpod runtime (server only)

These are **not** bundled into the Flutter app:

| Variable / secret | Purpose |
|-------------------|---------|
| Database URL or discrete `DB_*` / Serverpod YAML | PostgreSQL connection |
| `GOOGLE_APPLICATION_CREDENTIALS` (or platform equivalent) | Firebase **Admin**: verify ID tokens, FCM |
| Session / `passwords.yaml` material | Serverpod auth and internal secrets |

See [staging-and-production.md](infra/staging-and-production.md) §Secrets.

## Health and readiness

Use the HTTP paths your deployment exposes (Serverpod defaults or custom routes). Production rollouts should not mark instances healthy until DB connectivity (and any required Firebase Admin checks) succeed — see [staging-and-production.md](infra/staging-and-production.md) §Observability.

## Common issues

| Symptom | Checks |
|---------|--------|
| Generate fails | Serverpod CLI version vs `pubspec` `serverpod:` version; run from `chat_server/` |
| Client compile errors after pull | Run `serverpod generate` in `chat_server/`, then `flutter pub get` at root |
| Auth errors | Firebase project mismatch; token not passed to Serverpod session exchange per ADR-0003 |
| Connection refused | Postgres not up; wrong port in `development.yaml`; firewall |

## Related documents

- [Documentation index](README.md)
- [Protocol changelog](protocol/CHANGELOG.md) — breaking contract changes
- [PostgreSQL schema sketch](infra/postgresql-v1-schema.sql) — aligns with migrations over time
