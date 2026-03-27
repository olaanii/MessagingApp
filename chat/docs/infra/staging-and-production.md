# Staging and production — Serverpod + PostgreSQL + Firebase

Operates **Serverpod** (Dart) as the API/streaming layer on **PostgreSQL**, with **Firebase Auth** (client) and **Firebase Admin** (server: ID token verify + optional FCM). Aligns with [ADR-0002](../adr/0002-backend-serverpod-postgresql-firebase.md).

## 1. Topology (recommended)

| Component | Staging | Production |
|-----------|---------|------------|
| PostgreSQL | Managed (RDS, Cloud SQL, Azure Flexible, DO, etc.) | Managed, **automated backups** + PITR where offered |
| Serverpod | Single VM/container or platform run (Fly, Render, k8s) | Same + **min 2 instances** before counting on HA streaming |
| Redis | Skip until multi-instance or rate-limit buckets need it | Optional: rate limits, streaming fan-out if Serverpod pattern requires pub/sub |
| Object storage | S3-compatible bucket or Serverpod file storage | Versioning + lifecycle rules on bucket |
| Firebase | Separate project or same project with staging app IDs | Production Firebase project; **never** reuse staging keys in prod app |

**Regions:** Pick **one** primary region per environment; note latency to majority of users. Document in runbook table (`API host`, `DB host`, `bucket`, `Firebase project id`).

## 2. Fresh staging (acceptance checklist)

1. Create Postgres database and role; TLS to DB preferred.
2. Apply **Serverpod migrations** (`dart run bin/main.dart --apply-migrations` or current Serverpod CLI — follow pinned Serverpod version docs).
3. Load **seed** data (dev users, optional chats) from a script committed in `chat_server/` — no PII from prod.
4. Deploy Serverpod with **health** reachable (see §7).
5. Store **Firebase service account** JSON in secret manager; mount or inject as env for Serverpod process only.
6. Point **Flutter staging** build at staging `SERVERPOD_*` host + Firebase staging apps.

**One-command local dev (database only):**

```bash
docker compose -f docs/infra/docker-compose.dev.yml up -d
```

## 3. Secrets (never in git)

| Secret | Consumer | Storage |
|--------|----------|---------|
| `DATABASE_URL` / discrete DB_* vars | Serverpod | Vault / CI OIDC / platform env |
| Firebase **Admin** JSON or workload identity | Serverpod | Secret manager; path via `GOOGLE_APPLICATION_CREDENTIALS` or equivalent |
| Serverpod `passwords.yaml` / session secrets | Serverpod | Injected at deploy, not committed |
| OAuth / third-party SMS (if any) | Serverpod | Same |

**Flutter:** Client secrets use **envied** + `.env` locally; see [`.env.example`](../../.env.example). **Google Services** plist/json files stay out of git per `.gitignore`; distribute via secure channel or CI artifacts per flavor.

**GitHub Actions:** Prefer **OIDC** to cloud provider for deploy jobs; short-lived tokens over long-lived `AWS_ACCESS_KEY_ID` in repository secrets where possible.

## 4. Migrations and rollback

**Apply:** Run Serverpod migration apply as part of deploy **after** backup window for prod (or automatically on staging first).

**Failed migration**

1. Stop traffic to new revision (keep previous revision serving).
2. Restore DB from snapshot **if** migration partially applied and app cannot start — coordinate with DBA; document RPO/RTO.
3. If migration is **forward-only** safe: fix forward with a follow-up migration rather than rewriting history on shared branches.

**Test once:** On staging, apply migration → record checksum → run rollback drill on a **clone** or maintain **down** scripts only if team policy requires (Serverpod defaults are often upgrade-only; document team choice).

## 5. Backups and DR

- **Postgres:** Enable automated daily backups; retention ≥ 7–30 days per policy.
- **Object storage:** Versioning recommended; separate retention for user uploads vs logs.
- **Runbook:** Export incident steps: who restores DB, how to repoint Serverpod to restored instance, how to verify Firebase still matches restored `firebase_uid` rows.

## 6. FCM (server-triggered push)

- Server needs **Firebase Admin** with **FCM** capability.
- Env vars (names vary by Serverpod wrapper — document in server README):

  - `GOOGLE_APPLICATION_CREDENTIALS` or base64-injected JSON
  - Optional: `FIREBASE_PROJECT_ID` if not inferred from JSON

- **Never** put message plaintext in notification payload; data-only or generic body per store policy.

## 7. Observability

| Requirement | MVP |
|-------------|-----|
| Structured logs | JSON or key=value; include **request_id** / correlation from incoming headers |
| Health | `GET /health` or Serverpod default — liveness |
| Readiness | `GET /ready` **if** distinct (checks DB connectivity) |
| Errors | Optional **Sentry** / OpenTelemetry exporter — redact tokens and message bodies |

**Log policy:** No E2EE plaintext, no raw Firebase ID tokens; hash or truncate device identifiers in debug logs if needed for GDPR posture.

## 8. Load testing (optional Week 3+)

- Baseline RPC latency and streaming fan-out under N concurrent users on staging.
- Document connections per instance before adding Redis / second node (per streaming ADR).

## 9. Production parity checklist

- [ ] TLS termination valid cert; HTTPS-only API.
- [ ] DB TLS + least-privilege DB user for app.
- [ ] Secrets rotated from staging defaults.
- [ ] Backups + tested restore on calendar.
- [ ] FCM and Firebase project match prod app bundle IDs.
- [ ] Rate limits / abuse middleware enabled (when Serverpod implements them).

## References

- [`mvp_plan.md`](../../mvp_plan.md) — Infra agent brief
- [CI/CD](ci-cd.md) — pipelines
- [ADR index](../adr/README.md)
