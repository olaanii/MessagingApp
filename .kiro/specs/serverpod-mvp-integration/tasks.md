# Implementation Plan: Serverpod MVP Integration

## Overview

Incrementally bridge the Flutter app to the live Serverpod backend across four
milestones (M0→M3). Each milestone is independently deployable behind the
`MessagingSyncMode` dual-mode flag. Tasks are ordered by dependency: M0
infrastructure must land before M1 dual-write, M1 before M2 authoritative reads,
and M2 before M3 cleanup.

All implementation is in Dart/Flutter (client) and Dart (server).

---

## Tasks

- [x] 1. M0 — Gap 1: Serverpod client instantiation
  - [x] 1.1 Create `lib/core/serverpod/serverpod_auth_key_manager.dart`
    - Implement `ServerpodAuthKeyManager implements AuthenticationKeyManager`
    - `get()` reads access token from `flutter_secure_storage` under fixed key `sp_access_token`
    - `put(token)` writes access token to `flutter_secure_storage`
    - `remove()` deletes access token from `flutter_secure_storage`
    - Add `storeRefreshToken`, `readRefreshToken`, and `clearAll` helpers
    - _Requirements: 1.2, 1.3, 1.4, 1.5_

  - [x] 1.2 Write property test for `ServerpodAuthKeyManager`
    - **Property 7: Token Storage Round-Trip** — `put(token)` then `get()` returns same token; `remove()` then `get()` returns null
    - **Validates: Requirements 1.4, 1.5**

  - [x] 1.3 Create `lib/core/serverpod/serverpod_client_provider.dart`
    - Implement `authKeyManagerProvider` returning `ServerpodAuthKeyManager`
    - Implement `serverpodClientProvider` instantiating `Client(Env.serverpodApiUrl, authenticationKeyManager: manager, disconnectStreamsOnLostInternetConnection: true)`
    - Ensure `Client` is created exactly once per `ProviderScope` lifecycle
    - _Requirements: 1.1, 1.6, 1.7_

  - [x] 1.4 Write unit tests for `serverpodClientProvider`
    - Verify single instantiation per `ProviderScope`
    - Verify `disconnectStreamsOnLostInternetConnection: true` is set
    - _Requirements: 1.1, 1.6_

- [x] 2. M0 — Gap 2: Firebase → Serverpod token exchange (client)
  - [x] 2.1 Create `lib/features/auth/data/serverpod_auth_repository.dart`
    - Define `ServerpodAuthRepository` interface with `exchangeFirebaseToken`, `refreshSession`, and `logout`
    - Implement `ServerpodAuthRepositoryImpl` calling `client.auth.exchangeFirebaseToken`
    - On success: call `authKeyManager.put(accessToken)` and `authKeyManager.storeRefreshToken(refreshToken)`
    - On failure: throw typed `AuthException`; do not write any token to storage
    - Implement `logout`: call `client.auth.logout()` then `authKeyManager.clearAll()`
    - _Requirements: 2.1, 2.2, 2.3, 2.7, 2.8_

  - [x] 2.2 Write property test for `ServerpodAuthRepository`
    - **Property 8: Token Exchange Persists Both Tokens** — successful exchange stores both `accessToken` and `refreshToken` in their respective storage locations
    - **Validates: Requirements 2.2, 2.3**

  - [x] 2.3 Write property test for failed auth exchange
    - **Property 9: Failed Auth Exchange Leaves No Partial State** — any exception from `exchangeFirebaseToken` leaves no token in storage
    - **Validates: Requirements 2.8**

  - [x] 2.4 Implement `TokenRefreshInterceptor` inside `serverpod_auth_repository.dart`
    - On HTTP 401: read `refreshToken` from storage; call `client.jwtRefresh.refreshAccessToken`
    - On refresh success: update both stored tokens; retry original request exactly once
    - On refresh failure: call `authKeyManager.clearAll()`; emit `AuthEvent.sessionExpired`
    - _Requirements: 2.4, 2.5, 2.6_

  - [x] 2.5 Write property test for `TokenRefreshInterceptor`
    - **Property 5: Token Refresh Transparency** — exactly one refresh attempt and one retry on 401; no more
    - **Validates: Requirements 2.4**

  - [x] 2.6 Write property test for failed token refresh
    - **Property 10: Failed Token Refresh Clears All Tokens** — failed refresh removes both tokens and emits `AuthEvent.sessionExpired`
    - **Validates: Requirements 2.6**

  - [x] 2.7 Create `lib/features/auth/application/auth_notifier.dart` (replaces `AuthProvider`)
    - Implement `AuthNotifier extends AsyncNotifier<AuthState>`
    - Wire `ServerpodAuthRepository` for sign-in, refresh, and logout
    - Emit `AuthState` transitions; handle `AuthEvent.sessionExpired` from interceptor
    - _Requirements: 2.1, 2.7_

- [x] 3. M0 — Gap 2: `exchangeFirebaseToken` server endpoint
  - [x] 3.1 Create `chat/chat_server/lib/src/auth/firebase_auth_endpoint.dart`
    - Add `exchangeFirebaseToken(Session session, String firebaseIdToken, String deviceId, Map<String, dynamic> publicKeyBundle)` endpoint method
    - Verify `firebaseIdToken` via Firebase Admin SDK; extract `uid` and `phone`
    - Upsert `users`, `devices`, and `device_keys` rows in PostgreSQL
    - Create Serverpod session; return `TokenPair { accessToken, refreshToken }`
    - _Requirements: 2.1_

  - [x] 3.2 Register `FirebaseAuthEndpoint` in `chat_server/lib/src/generated/endpoints.dart`
    - Add endpoint to the generated endpoints list so it is reachable by the client
    - _Requirements: 2.1_

- [ ] 4. Checkpoint — M0 complete
  - Ensure all tests pass, ask the user if questions arise.
  - Verify: Flutter staging login returns a Serverpod `TokenPair`; `ServerpodAuthKeyManager.get()` returns non-null after exchange.

- [x] 5. M1 — Gap 4: Drift activation and repository providers
  - [x] 5.1 Create `lib/data/providers/database_provider.dart`
    - Implement `appDatabaseProvider` as `Provider<AppDatabase>` with `ref.onDispose(db.close)`
    - _Requirements: 4.1_

  - [x] 5.2 Create `lib/data/providers/repository_providers.dart`
    - Implement `chatRepositoryProvider`, `messageRepositoryProvider`, and `syncRepositoryProvider`
    - Each injects `AppDatabase` from `appDatabaseProvider`
    - _Requirements: 4.5_

  - [x] 5.3 Write property test for `DriftMessageRepository`
    - **Property 16: Drift Reactive Stream Emits on Change** — `upsertLocalMessage` causes `watchMessagesForChat` to emit an updated list containing the upserted message
    - **Validates: Requirements 4.4**

- [x] 6. M1 — Gap 3: Streaming subscription service
  - [x] 6.1 Create `lib/features/chat/data/stream_subscription_service.dart`
    - Define `ChatStreamService` interface and `InboundChatEvent` sealed class hierarchy (`MessageEvent`, `AckEvent`, `TypingEvent`, `ErrorEvent`)
    - Implement `StreamSubscriptionServiceImpl` calling `client.chatStream.chatRoom(chatId, deviceId, outboundController.stream)`
    - For `type == 'message'` envelopes: decrypt via `E2eeEngine.decryptUtf8Message`; on success call `DriftMessageRepository.upsertLocalMessage`; on failure emit `ErrorEvent` without writing
    - Implement exponential backoff reconnect: `delay = min(32, 2^attempt) + random(0..3)` seconds; reset `attempt` on successful connect
    - On `auth_required` error: emit `ConnectionEvent.authRequired`; do not reconnect
    - Only open stream when `MessagingSyncMode.useServerpod`; close on `dispose`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8_

  - [x] 6.2 Write property test for stream reconnect liveness
    - **Property 6: Stream Reconnect Liveness** — reconnect attempt initiated within 32 s on non-auth error; delay bounded by `min(32, 2^attempt) + 3`
    - **Validates: Requirements 3.5**

  - [x] 6.3 Write property test for inbound message handling
    - **Property 11: Inbound Message Decrypt-Then-Write** — valid envelope calls `upsertLocalMessage` exactly once; failed decryption calls it zero times
    - **Validates: Requirements 3.2, 3.3, 3.4**

  - [x] 6.4 Create `lib/features/chat/application/chat_stream_notifier.dart`
    - Implement `ChatStreamNotifier` managing stream lifecycle per `chatId`
    - Start stream on build; close on dispose; expose connection state to UI
    - _Requirements: 3.1, 3.8_

- [-] 7. M1 — Gap 6: E2EE key store and key exchange service
  - [x] 7.1 Create `lib/features/chat/data/chat_key_store.dart`
    - Define `ChatKeyStore` interface with `getChatKey`, `storeChatKey`, `deleteChatKey`
    - Implement using `flutter_secure_storage`; never store keys in unencrypted location
    - _Requirements: 6.3, 6.5, 6.6_

  - [x] 7.2 Write property test for `ChatKeyStore`
    - **Property 17: Wrapped Key Round-Trip** — a chat key wrapped for a recipient's `PublicKeyBundle` and unwrapped with the corresponding private key equals the original
    - **Validates: Requirements 6.1, 6.2**

  - [x] 7.3 Create `lib/features/chat/data/key_exchange_service.dart`
    - Define `KeyExchangeService` interface with `bootstrapChat` and `receiveWrappedKey`
    - `bootstrapChat`: generate `chatKey` via `E2eeEngine.newChatKey()`; fetch member bundles from `KeyEndpoint.fetchUserBundle`; wrap for each member; upload via `KeyEndpoint.uploadWrappedKeys`; store own key in `ChatKeyStore`
    - `receiveWrappedKey`: unwrap envelope using device private key; store in `ChatKeyStore`
    - _Requirements: 6.1, 6.2_

  - [x] 7.4 Write property test for E2EE round-trip
    - **Property 1: E2EE Round-Trip** — `decrypt(encrypt(plaintext, key), key) == plaintext` for arbitrary plaintext and key
    - **Validates: Requirements 6.1, 6.2**

  - [-] 7.5 Add `KeyEndpoint` to `chat_server`
    - Create `chat/chat_server/lib/src/security/key_endpoint.dart`
    - Implement `uploadBundle`, `fetchUserBundle`, and `uploadWrappedKeys` methods
    - Persist key material to `device_keys` table in PostgreSQL
    - _Requirements: 6.1, 6.2_

- [x] 8. M1 — Gap 5: Outbox sync worker
  - [x] 8.1 Create `lib/features/chat/data/outbox_sync_worker.dart`
    - Implement `OutboxSyncWorker` with `start()`, `pause()`, and `dispose()`
    - Processing loop: watch `syncRepo.watchOutbox(states: ['pending', 'failed'])`; skip entries where `nextRetryAt > now()`
    - For each eligible entry: set state to `sending`; retrieve `chatKey` from `ChatKeyStore` (throw `E2eeException.keyNotFound` if absent); encrypt `payloadJson` via `E2eeEngine.encryptUtf8Message`; send `ChatStreamEnvelope` with `idempotencyKey = clientMsgId`
    - On ack: set state to `sent`; update `localMessage.isPendingDelivery = false` with `serverSeq`
    - On transient error: increment `attemptCount`; set state to `failed`; set `nextRetryAt = now() + min(30s, 2^attemptCount) + random(0..2s)`
    - On `attemptCount >= 10` or permanent error (auth / payload too large): set state to `dead_letter`
    - Never transmit `payloadJson` in plaintext
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9_

  - [x] 8.2 Write property test for outbox idempotency
    - **Property 3: Outbox Idempotency** — same `clientMsgId` sent multiple times yields the same `serverSeq` on every ack
    - **Validates: Requirements 5.7**

  - [x] 8.3 Write property test for dead-letter bound
    - **Property 4: Dead-Letter Bound** — any entry with `attemptCount >= 10` transitions to `dead_letter` and receives no further send attempts
    - **Validates: Requirements 5.5**

  - [x] 8.4 Write property test for retry backoff
    - **Property 12: Outbox Retry Backoff Is Strictly Increasing** — each successive `nextRetryAt` is strictly greater than the previous; delay satisfies `delay <= min(30s, 2^attemptCount) + 2s`
    - **Validates: Requirements 5.4**

  - [x] 8.5 Create `lib/features/chat/application/outbox_worker_notifier.dart`
    - Implement `OutboxWorkerNotifier` that starts the worker after auth succeeds and pauses it on sign-out or connectivity loss
    - _Requirements: 5.1, 5.9_

- [x] 9. M1 — Gap 4 (continued): Replace `ChatProvider` with `ChatNotifier`
  - [x] 9.1 Create `lib/features/chat/application/chat_notifier.dart`
    - Implement `ChatNotifier extends AsyncNotifier<ChatState>` (family key: `chatId`)
    - When `useServerpod`: read messages from `DriftMessageRepository.watchMessagesForChat`; enqueue sends to outbox via `syncRepositoryProvider`; no Firestore imports
    - When `useFirestore`: delegate all reads and writes to legacy `MessagingService`
    - _Requirements: 4.2, 4.3_

  - [x] 9.2 Write property test for dual-mode isolation
    - **Property 13: Dual-Mode Isolation** — when `useFirestore` active, no Serverpod calls made; when `useServerpod` active, no Firestore read calls made
    - **Validates: Requirements 3.7, 4.2, 4.3, 8.5, 10.3, 11.1, 11.2**

- [ ] 10. Checkpoint — M1 complete
  - Ensure all tests pass, ask the user if questions arise.
  - Verify: Drift DB populated from stream; outbox processes without errors; E2EE ciphertext visible in Postgres staging.

- [x] 11. M2 — Gap 7: Device registry
  - [x] 11.1 Add `DeviceEndpoint` to `chat_server`
    - Create `chat/chat_server/lib/src/auth/device_endpoint.dart`
    - Implement `list()` returning active sessions for the authenticated user
    - Implement `revoke(String deviceId)` setting `sessions.revoked_at` and removing the device's push token
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [x] 11.2 Create `lib/features/settings/data/device_repository.dart`
    - Define `DeviceRepository` interface with `listMyDevices()` and `revokeDevice(deviceId)`
    - Implement calling `client.device.list()` and `client.device.revoke(deviceId)`
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 11.3 Create `lib/features/settings/application/device_manager_notifier.dart`
    - Implement `DeviceManagerNotifier extends AsyncNotifier<List<DeviceInfo>>`
    - `build()` calls `DeviceRepository.listMyDevices()`; surface error state on failure without crashing
    - `revoke(deviceId)`: call `revokeDevice`; if current device also call `ServerpodAuthRepository.logout()` and navigate to sign-in
    - Refresh list after successful revoke
    - _Requirements: 7.1, 7.3, 7.4, 7.5_

  - [x] 11.4 Write unit tests for `DeviceManagerNotifier`
    - Test error state surfaced when `listMyDevices()` throws
    - Test current-device revoke triggers logout and navigation
    - _Requirements: 7.4, 7.5_

- [x] 12. M2 — Gap 8: Serverpod media upload
  - [x] 12.1 Create `lib/features/chat/data/media_upload_service.dart`
    - Define `MediaUploadService` interface with `uploadMedia({chatId, file, mimeType, onProgress})`
    - Implement `ServerpodMediaUploadService`: call `client.media.requestUploadSlot`; upload via `ServerpodMediaUploader.upload`; call `client.media.finalizeUpload`; return `fetchUrl`
    - Invoke `onProgress` callback with values in `[0.0, 1.0]` non-decreasingly as chunks complete
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.6_

  - [x] 12.2 Write property test for media upload progress
    - **Property 14: Media Upload Progress Is Bounded** — every `onProgress` value is in `[0.0, 1.0]`; sequence is non-decreasing
    - **Validates: Requirements 8.6**

  - [x] 12.3 Wire `ServerpodMediaUploadService` into `ChatNotifier`
    - When `useServerpod`: call `ServerpodMediaUploadService.uploadMedia`; use returned `fetchUrl` in message payload
    - When `useFirestore`: use existing Firebase Storage path; do not call `ServerpodMediaUploadService`
    - _Requirements: 8.5_

- [x] 13. M2 — Gap 9: FCM token registration with Serverpod
  - [x] 13.1 Add `PushEndpoint` to `chat_server`
    - Create `chat/chat_server/lib/src/auth/push_endpoint.dart`
    - Implement `registerToken(String userId, String token, String platform)` upserting `push_tokens` table row
    - _Requirements: 9.1, 9.5_

  - [x] 13.2 Extend `lib/data/services/fcm_token_sync.dart`
    - Add `syncFcmToken({userId, token, mode, serverpodClient?})` function
    - When `useFirestore`: write to Firestore using existing path
    - When `useServerpod`: call `serverpodClient.push.registerToken(userId, token, platform)`
    - When both active (dual-write): write to both
    - On FCM token refresh: re-register with all active backends
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

  - [x] 13.3 Update `lib/core/platform/fcm_platform_service.dart`
    - Wire `publishToken` callback to call `syncFcmToken` with current `MessagingSyncMode` and `serverpodClient`
    - _Requirements: 9.1, 9.4_

- [x] 14. M2 — Gap 10: Safety endpoint wiring
  - [x] 14.1 Update `lib/features/chat/application/chat_notifier.dart` for safety calls
    - When `useServerpod`: implement `blockUser(targetAuthUserId)` calling `client.safety.blockUser`
    - When `useServerpod`: implement `reportUser(...)` calling `client.safety.submitReport`
    - Surface network errors to UI; do not silently discard failures
    - _Requirements: 10.1, 10.2, 10.5_

  - [x] 14.2 Update `lib/features/auth/application/auth_notifier.dart` for safety calls
    - When `useFirestore`: delegate block and report to existing `AuthService`
    - When `useServerpod`: call `SafetyEndpoint` directly
    - _Requirements: 10.3_

  - [x] 14.3 Write property test for safety endpoint authentication
    - **Property 15: Safety Endpoint Requires Authentication** — unauthenticated calls to `blockUser` or `submitReport` are rejected; no block/report record persisted
    - **Validates: Requirements 10.4**

- [ ] 15. Checkpoint — M2 complete
  - Ensure all tests pass, ask the user if questions arise.
  - Verify: full inbox + chat flow works with `SERVERPOD_MESSAGING=true`; zero Firestore reads in flag-on builds; device manager, media upload, FCM, and safety all functional.

- [ ] 16. M3 — Remove Firestore messaging code
  - [ ] 16.1 Delete `MessagingService` and `HiveStorage` offline queue
    - Remove `lib/data/services/messaging_service.dart` (or equivalent)
    - Remove `HiveStorage` offline queue implementation
    - Remove all Firestore message collection write calls
    - _Requirements: 11.3_

  - [ ] 16.2 Remove dual-mode branches from `ChatNotifier`, `AuthNotifier`, and `FcmTokenSync`
    - Delete `useFirestore` branches; keep only Serverpod paths
    - Remove `MessagingBackend.firestore` enum value and `kDefaultMessagingBackend`
    - Remove `MessagingSyncMode` flag and `--dart-define` wiring
    - _Requirements: 11.3, 11.4_

  - [ ] 16.3 Remove `cloud_firestore` dependency from messaging paths
    - Remove `cloud_firestore` imports from all files under `features/chat/`
    - Keep Firebase Auth and FCM imports intact
    - _Requirements: 11.3_

  - [ ] 16.4 Write unit tests confirming no Firestore imports remain in messaging paths
    - Verify `features/chat/` has no `cloud_firestore` imports
    - Verify `flutter analyze` reports no issues
    - _Requirements: 11.3_

- [ ] 17. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
  - Verify: `flutter analyze` clean; no `cloud_firestore` imports in `features/chat/`; RC checklist green.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Milestones M0→M3 must be executed in order due to dependency chain
- Property tests validate universal correctness properties across arbitrary inputs
- Unit tests validate specific examples and edge cases
- Server-side endpoint tasks (3, 7.5, 11.1, 13.1) must be completed before the corresponding client tasks that call them
