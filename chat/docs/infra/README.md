# Infra / DevOps — index

Mission and acceptance criteria match [**Infra / DevOps** in `mvp_plan.md`](../../mvp_plan.md) (Serverpod + PostgreSQL + Firebase; optional Redis later). The [**Documentation index**](../README.md) is the monorepo-wide entry (local app + server, diagram, doc map).

| Doc | Purpose |
|-----|--------|
| [staging-and-production.md](staging-and-production.md) | Postgres, Serverpod deploy, storage, secrets, FCM, backups, migration rollback, health |
| [ci-cd.md](ci-cd.md) | GitHub Actions, server job when `chat_server/` exists, OIDC pattern for deploy secrets |
| [docker-compose.dev.yml](docker-compose.dev.yml) | Local PostgreSQL (+ optional Redis) for developers |

**Handouts:** connection strings and bucket names → Serverpod maintainer; staging base URL → QA; Firebase `google-services.json` / `GoogleService-Info.plist` per flavor → mobile.
