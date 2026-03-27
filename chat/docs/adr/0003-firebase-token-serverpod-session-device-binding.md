# ADR-0003: Firebase ID token → Serverpod session + device binding

## Status

Accepted

## Decision

- Client completes Firebase Auth (phone/email as configured), obtains **Firebase ID token**, calls `AuthEndpoint.exchangeFirebaseToken(idToken, deviceId, ...)`.
- Server verifies token via **Firebase Admin**, resolves `firebase_uid` → internal **`users.id`**, upserts **`devices`** row, creates **`sessions`** with **hashed refresh token** (opaque).
- **Access token** (JWT or Serverpod session token per framework): TTL **≤ 15 min**, embeds `userId`, `sessionId`, `deviceId` claims as applicable.
- **Refresh token:** opaque, rotated on use; **reuse** of old refresh revokes chain (policy detail: single device vs all devices — default **revoke chain**).
- **Streaming** attaches the **same** authenticated principal as RPC; include **`device_id`** in security context for idempotency keys.
- **WebSocket ticket** pattern (optional): short-lived ticket endpoint if Serverpod integration prefers separate handshake; prefer **documented** approach from Serverpod version docs.

## Product defaults (until confirmed)

- MVP sign-in: **Firebase phone OTP** (matches current app); email optional.
- **Verified / KYC badges:** Phase 2+.

## Consequences

- Multi-device UX requires explicit **device list** + revoke; increases attack surface mitigated by limits + revocation UI.
