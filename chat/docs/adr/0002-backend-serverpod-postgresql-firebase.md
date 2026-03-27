# ADR-0002: Backend — Serverpod + PostgreSQL; Firebase for Auth and FCM

## Status

Accepted

## Context **Flutter + Dart** end-to-end reduces DTO drift; Firebase already powers OTP and FCM in the repo.

## Decision

- **Serverpod** (Dart) exposes typed **endpoints** + **streaming** for realtime.
- **PostgreSQL** stores users (linked to `firebase_uid`), devices, **sessions**, chats, members, messages (ciphertext + sync metadata), media metadata, public key material, push tokens, reports/blocks.
- **Firebase:** **Auth** for sign-in; **FCM** for push. Serverpod calls **Firebase Admin** for token verification and (optionally) downstream FCM sends.
- **Firestore:** phased **out** for message transport; see `mvp_plan.md` Firestore milestones.

## Option B

**Supabase** (Postgres + Realtime + Auth) remains an alternative documented in `mvp_plan.md` only if Serverpod is deprioritized.

## Consequences

- Positive: one language for API + models; strong generated client.
- Negative: smaller ecosystem than Node; team must operate Serverpod deploys (see Infra brief).
