# ADR 0008 — Flutter feature layout, Riverpod migration, Serverpod client shell

| Status   | Accepted |
| -------- | -------- |
| Date     | 2026-03-27 |
| Context  | [`mvp_plan.md`](../../mvp_plan.md) §7; hybrid stack Serverpod + Firebase |
| Decides  | Target `lib/` layout, incremental **Provider → Riverpod**, GoRouter + auth refresh, generated client boundaries |

## Context

The app today uses **package:provider** (`AuthProvider`, `ChatProvider`), **GoRouter** with `refreshListenable: authProvider`, and layer-ish folders (`presentation/`, `data/`, `domain/`). The MVP target is **Riverpod** (`Notifier` / `AsyncNotifier`), **Drift**, and a **generated Serverpod client**, without a big-bang rewrite.

## Decision

1. **Target layout (feature-first, clean layers)** — Align with `mvp_plan.md` §7:

   - `lib/core/` — env, `serverpod/` (thin client + session holders), crypto, errors, routing helpers, shared non-UI utilities.
   - `lib/features/<feature>/` — each with `data/`, `application/` (notifiers, use cases), `presentation/` (widgets, screens).
   - `lib/shared/` — design-system widgets, cross-feature models if not yet owned by a feature.

   **Dependency rule:** `presentation` → `application` → `domain`; `data` implements repositories and may depend on Serverpod client + Drift + crypto services. **No** imports of generated Serverpod client types from `presentation/`.

2. **Riverpod bootstrap** — Root `runApp` wraps the tree in **`ProviderScope`** (see `lib/main.dart`). Legacy `ChangeNotifier` providers remain registered via **package:provider** `MultiProvider` **inside** `ProviderScope` until each feature migrates.

3. **Migration strategy (one vertical slice at a time)**  
   For each feature (recommended order: **auth** → **chat list** → **thread** → **settings**):

   - Introduce `@riverpod` / `Notifier` or `AsyncNotifier` in `features/<f>/application/` (or `core/` for cross-cutting session state).
   - Replace `Provider.of` / `Consumer<T>` with `ConsumerWidget` / `ref.watch` / `ref.read` for that feature’s screens only.
   - When **auth** is on Riverpod, replace GoRouter’s `refreshListenable: authProvider` with a `Listenable` derived from the auth notifier (e.g. `GoRouterRefreshNotifier` pattern or `ref.listen` + `router.refresh()`), so redirects stay correct.

   Until migration completes, **do not** remove `package:provider`; removing it is the final step after no `Provider.of` / `Consumer` references remain.

4. **Serverpod generated client** — When `{{PROJECT}}_server` exists:

   - Run **`serverpod generate`** from the server project root after **any** `protocol/*.yaml` change.
   - Wire the generated Dart client in **`lib/core/serverpod/`** (singleton or Riverpod `Provider` scoped to `device_id` / secrets as per ADR 0003).
   - CI: optional job that runs `serverpod generate` and fails on dirty `lib/` or committed client package (team choice: commit generated client vs generate in CI).

5. **Linting** — Keep **`flutter_lints`**. When migration starts in earnest, add **`riverpod_lint`** + **`custom_lint`** in `analysis_options.yaml` for `@riverpod` codegen and avoid-smells rules.

6. **Testing** — Prefer **`ProviderContainer`** (with `overrides` for `AuthService` / repositories) for notifier and application-layer unit tests; widget tests use `ProviderScope` with overrides.

## Consequences

- **Positive:** New code can use Riverpod immediately; Serverpod client has a single home; folder moves can be incremental (move-with-re-export if needed).
- **Negative:** Temporary **dual** DI (provider + riverpod) until migration finishes; developers must follow the import boundary rule to avoid spaghetti.

## Mapping (current → target)

| Current | Target |
| -------- | ------ |
| `lib/presentation/auth/` | `lib/features/auth/presentation/` |
| `lib/presentation/chat/` | `lib/features/chat/…` (+ `groups` as needed) |
| `lib/presentation/settings/` | `lib/features/settings/…` |
| `lib/presentation/theme/`, `presentation/core/` | `lib/shared/…` and/or `lib/core/theme/` |
| `lib/data/services/` | split into feature `data/` + `lib/core/serverpod/` adapters |
| `lib/domain/models/` | feature `domain/` or `shared/models/` |

## References

- ADR 0002 (Serverpod + PostgreSQL + Firebase)
- ADR 0003 (Firebase token → session + `device_id`)
