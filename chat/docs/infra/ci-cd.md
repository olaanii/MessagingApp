# CI/CD — Flutter app + Serverpod server

Goals from `mvp_plan.md`: **`flutter analyze`**, **`dart test`** on the app and on **`chat_server`** when present; optional migration dry-run in staging on merge; mobile artifacts as needed.

## 1. GitHub Actions (current)

Workflow: [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml).

| Job | When | Steps |
|-----|------|--------|
| **Flutter** | All pushes / PRs to `main` | `pub get`, format, analyze, test, APK + iOS (no codesign) builds |
| **Serverpod** | Only when `chat_server/pubspec.yaml` exists | `dart pub get`, analyze, test |

**Note:** iOS builds on every PR are slow; you can restrict **build** jobs to `push: main` only and keep analyze+test on all PRs — adjust the workflow if queue time hurts.

## 2. Adding Serverpod to CI

When `chat_server/` is committed:

- Default working directory: `chat_server`
- Run: `dart pub get`, `dart analyze`, `dart test`
- Optionally: `dart pub global activate serverpod_cli` and validate migrations **without** applying (project-specific; follow Serverpod version docs)

**Client codegen:** Document a manual or CI step: after `chat_server` protocol changes, regenerate Flutter client and fail CI if generated files are stale (`git diff --exit-code`).

## 3. Staging deploy (outline)

1. **Build** Serverpod Docker image or artifact (per official deploy guide).
2. **Migrate** staging DB (automated job or manual gate).
3. **Roll out** new revision; hit `/ready` before marking healthy.

Use **environment protection rules** on `main` or `release/*` for production.

## 4. OIDC and cloud secrets (recommended)

Instead of storing long-lived cloud keys in GitHub:

1. Configure **OIDC trust** between GitHub and your cloud (AWS IAM, GCP WIF, Azure OIDC).
2. Deploy workflow assumes a **short-lived role** to push images and update services.
3. **Firebase Admin** JSON remains in cloud secret manager; runtime injects into Serverpod, not into GitHub unless unavoidable for a specific smoke test (prefer testing against long-lived staging only).

## 5. Flutter artifacts

- **Android:** `flutter build appbundle` on tags or `main` for Play upload.
- **iOS:** Xcode / codemagic / internal Mac runner for signed IPA.
- **Web:** `flutter build web` for static hosting.

Store signing keys in platform-specific secret stores, not in the repo.

## 6. Dependency audit

- Flutter/Dart: enable **`dart pub audit`** in CI when toolchain supports it (pin SDK).
- Serverpod: **pin** version in `pubspec.yaml`; upgrade on a dedicated PR with changelog review.
