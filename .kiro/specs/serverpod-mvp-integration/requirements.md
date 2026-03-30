# Requirements Document

## Introduction

This document defines the requirements for the Serverpod MVP Integration feature,
which bridges the existing Flutter app (Riverpod + GoRouter + Drift + E2EE crypto)
to the live Serverpod backend. The integration covers ten gaps: client instantiation,
Firebase→Serverpod token exchange, streaming subscription, Drift activation, outbox
sync worker, E2EE integration, device registry, media upload, FCM token registration,
and safety endpoint wiring. All gaps are implemented behind a dual-mode flag so
Firestore paths remain functional until each milestone is validated.

## Glossary

- **ServerpodClient**: The generated `Client` instance from `chat_client` package, used for all Serverpod RPC and streaming calls.
- **ServerpodAuthKeyManager**: Client-side component that stores and retrieves the Serverpod access token from `flutter_secure_storage`.
- **TokenPair**: A pair of `{ accessToken, refreshToken }` returned by the Serverpod auth endpoint after a successful Firebase token exchange.
- **OutboxItem**: A row in the local Drift `outbox_entries` table representing a pending message operation awaiting delivery to Serverpod.
- **OutboxSyncWorker**: Background worker that processes `OutboxItem` rows, encrypts payloads, sends them to `ChatStreamEndpoint`, and updates delivery state.
- **ChatStreamService**: Client-side service that manages the bidirectional WebSocket stream to `ChatStreamEndpoint`.
- **E2eeEngine**: Existing cryptographic engine implementing X25519 key exchange and ChaCha20-Poly1305 message encryption/decryption.
- **ChatKeyStore**: Client-side store for per-chat symmetric keys, backed by `flutter_secure_storage`.
- **KeyExchangeService**: Service that bootstraps per-chat symmetric keys and distributes wrapped copies to chat members via `KeyEndpoint`.
- **MessageCryptoEnvelope**: Serialized structure `{ v, n, c }` containing schema version, nonce, and ciphertext+MAC for an encrypted message.
- **DriftMessageRepository**: Drift-backed implementation of `MessageRepository` that reads and writes messages to the local SQLite database.
- **MessagingSyncMode**: Runtime flag (`useFirestore` / `useServerpod`) controlling which backend path is active for messaging operations.
- **DeviceRepository**: Repository that lists and revokes device sessions via `DeviceEndpoint`.
- **ServerpodMediaUploadService**: Adapter that requests an upload slot from `MediaEndpoint`, performs a chunked PUT, and finalizes the upload.
- **SafetyEndpoint**: Fully-implemented Serverpod endpoint providing `blockUser` and `submitReport` RPCs.
- **clientMsgId**: UUID v4 assigned client-side to each outbox entry; used as the idempotency key on `ChatStreamEndpoint`.
- **serverSeq**: Monotonically increasing sequence number assigned by the server to each accepted message.
- **dead_letter**: Terminal outbox state assigned when `attemptCount >= 10` or a permanent error (auth, payload too large) occurs.
- **PublicKeyBundle**: A device's X25519 public key material uploaded to the server during token exchange.
- **WrappedChatKeyEnvelope**: A per-chat symmetric key encrypted for a specific recipient's public key, distributed via `KeyEndpoint`.

---

## Requirements

### Requirement 1: Serverpod Client Instantiation

**User Story:** As a developer, I want a single, correctly configured Serverpod
client instance available throughout the app, so that all data-layer code can
make authenticated RPC and streaming calls without duplicating setup logic.

#### Acceptance Criteria

1. THE ServerpodClient SHALL be instantiated exactly once per app lifecycle via `serverpodClientProvider`.
2. THE ServerpodAuthKeyManager SHALL attach the stored access token to every outgoing RPC request.
3. WHEN the app starts, THE ServerpodAuthKeyManager SHALL read the access token from `flutter_secure_storage` under a fixed key.
4. WHEN `ServerpodAuthKeyManager.put(token)` is called, THE ServerpodAuthKeyManager SHALL persist the token to `flutter_secure_storage`.
5. WHEN `ServerpodAuthKeyManager.remove()` is called, THE ServerpodAuthKeyManager SHALL delete the access token from `flutter_secure_storage`.
6. THE ServerpodClient SHALL be configured with `disconnectStreamsOnLostInternetConnection: true`.
7. THE ServerpodClient SHALL NOT be imported directly by any file in the `presentation/` layer.

---

### Requirement 2: Firebase → Serverpod Token Exchange

**User Story:** As a user who has completed Firebase OTP sign-in, I want my
Firebase identity to be exchanged for a Serverpod session, so that I can make
authenticated calls to the Serverpod backend without signing in again.

#### Acceptance Criteria

1. WHEN a Firebase ID token is available after OTP success, THE ServerpodAuthRepository SHALL call `exchangeFirebaseToken` with the token, `deviceId`, and `publicKeyBundle`.
2. WHEN `exchangeFirebaseToken` succeeds, THE ServerpodAuthRepository SHALL store the returned `accessToken` via `ServerpodAuthKeyManager.put()`.
3. WHEN `exchangeFirebaseToken` succeeds, THE ServerpodAuthRepository SHALL store the returned `refreshToken` in `flutter_secure_storage` under key `sp_refresh_token`.
4. WHEN a Serverpod RPC returns HTTP 401, THE TokenRefreshInterceptor SHALL attempt exactly one token refresh using the stored `refreshToken` before retrying the original request.
5. WHEN the token refresh succeeds, THE TokenRefreshInterceptor SHALL update the stored `accessToken` and `refreshToken` with the new values and retry the original request.
6. IF the token refresh fails, THEN THE TokenRefreshInterceptor SHALL clear both stored tokens and emit `AuthEvent.sessionExpired`.
7. WHEN `logout` is called, THE ServerpodAuthRepository SHALL call `client.auth.logout()` and then `ServerpodAuthKeyManager.clearAll()`.
8. IF `exchangeFirebaseToken` fails, THEN THE ServerpodAuthRepository SHALL throw a typed `AuthException` and SHALL NOT store any partial token state.

---

### Requirement 3: Streaming Subscription

**User Story:** As a chat participant, I want inbound messages from the Serverpod
stream to appear in my chat in real time, so that I can have live conversations
without manual refresh.

#### Acceptance Criteria

1. WHEN `MessagingSyncMode.useServerpod` is active and a chat screen is open, THE ChatStreamService SHALL open a bidirectional stream to `ChatStreamEndpoint.chatRoom` for the active `chatId` and `deviceId`.
2. WHEN a `type == 'message'` envelope is received on the stream, THE ChatStreamService SHALL decrypt the `payloadJson` via `E2eeEngine.decryptUtf8Message` before writing to `DriftMessageRepository`.
3. WHEN decryption succeeds, THE ChatStreamService SHALL call `DriftMessageRepository.upsertLocalMessage` exactly once per envelope with the decrypted plaintext and `serverSeq`.
4. IF decryption fails for an inbound envelope, THEN THE ChatStreamService SHALL emit an `ErrorEvent` on the broadcast stream and SHALL NOT perform a partial write to `DriftMessageRepository`.
5. WHEN the stream disconnects with a non-auth error, THE ChatStreamService SHALL reconnect using exponential backoff with a maximum delay of 32 seconds.
6. WHEN the stream disconnects with an `auth_required` error, THE ChatStreamService SHALL emit `ConnectionEvent.authRequired` and SHALL NOT attempt automatic reconnection.
7. WHILE `MessagingSyncMode.useFirestore` is active, THE ChatStreamService SHALL NOT open any stream connection to `ChatStreamEndpoint`.
8. WHEN the chat screen is disposed, THE ChatStreamService SHALL close the stream connection.

---

### Requirement 4: Drift Activation

**User Story:** As a developer, I want the app's chat data layer to read from
and write to the local Drift SQLite database when the Serverpod flag is active,
so that the app works offline and Firestore is no longer the source of truth for
messages.

#### Acceptance Criteria

1. THE appDatabaseProvider SHALL create a single `AppDatabase` instance and dispose it when the provider is torn down.
2. WHEN `MessagingSyncMode.useServerpod` is active, THE ChatNotifier SHALL read messages exclusively from `DriftMessageRepository.watchMessagesForChat` and SHALL NOT make any Firestore read calls.
3. WHEN `MessagingSyncMode.useFirestore` is active, THE ChatNotifier SHALL delegate all reads to the legacy `MessagingService` and SHALL NOT make any Drift read calls for messages.
4. THE DriftMessageRepository SHALL expose a reactive `watchMessagesForChat(chatId)` stream that emits an updated list whenever the underlying Drift table changes.
5. THE messageRepositoryProvider, chatRepositoryProvider, and syncRepositoryProvider SHALL each inject the `AppDatabase` instance from `appDatabaseProvider`.

---

### Requirement 5: Outbox Sync Worker

**User Story:** As a user sending a message, I want my message to be reliably
delivered to the server even if the network is temporarily unavailable, so that
I never silently lose a sent message.

#### Acceptance Criteria

1. WHEN `OutboxSyncWorker.start()` is called, THE OutboxSyncWorker SHALL begin processing `OutboxItem` rows with `state == 'pending'` or `state == 'failed'` whose `nextRetryAt` is in the past.
2. WHEN processing an outbox entry, THE OutboxSyncWorker SHALL encrypt the `payloadJson` via `E2eeEngine.encryptUtf8Message` before transmitting it to `ChatStreamEndpoint`.
3. WHEN the server acknowledges an outbox entry, THE OutboxSyncWorker SHALL update the entry's `state` to `'sent'` and set `localMessage.isPendingDelivery = false` with the received `serverSeq`.
4. WHEN a transient network error occurs, THE OutboxSyncWorker SHALL increment `attemptCount`, set `state` to `'failed'`, and set `nextRetryAt` to `now() + min(30s, 2^attemptCount) + random(0..2s)`.
5. WHEN `attemptCount` reaches 10, THE OutboxSyncWorker SHALL set the entry's `state` to `'dead_letter'` and SHALL NOT retry further.
6. WHEN a permanent error occurs (auth failure or payload too large), THE OutboxSyncWorker SHALL immediately set the entry's `state` to `'dead_letter'` regardless of `attemptCount`.
7. THE OutboxSyncWorker SHALL use the `clientMsgId` as the idempotency key in every `ChatStreamEnvelope` it sends, so that duplicate sends yield the same `serverSeq`.
8. THE OutboxSyncWorker SHALL NOT transmit `payloadJson` in plaintext; encryption MUST occur before the envelope is sent to the stream.
9. WHEN `OutboxSyncWorker.pause()` is called, THE OutboxSyncWorker SHALL stop processing new entries until `start()` is called again.

---

### Requirement 6: E2EE Integration into Messaging

**User Story:** As a user, I want all messages to be end-to-end encrypted so
that the server never has access to my message content.

#### Acceptance Criteria

1. WHEN a new chat is created, THE KeyExchangeService SHALL generate a new `chatKey` via `E2eeEngine.newChatKey()`, wrap it for each member's `PublicKeyBundle`, and upload the wrapped envelopes via `KeyEndpoint.uploadWrappedKeys`.
2. WHEN a `WrappedChatKeyEnvelope` is received from the server, THE KeyExchangeService SHALL unwrap it using the device's private key and store the resulting `chatKey` in `ChatKeyStore`.
3. THE OutboxSyncWorker SHALL retrieve the `chatKey` from `ChatKeyStore` before encrypting each outbox entry.
4. IF `ChatKeyStore.getChatKey(chatId)` returns null when the OutboxSyncWorker needs it, THEN THE OutboxSyncWorker SHALL throw `E2eeException.keyNotFound` and pause outbox processing for that `chatId`.
5. THE ChatStreamService SHALL retrieve the `chatKey` from `ChatKeyStore` before decrypting each inbound `message` envelope.
6. THE ChatKeyStore SHALL store all chat keys in `flutter_secure_storage` and SHALL NOT store them in any unencrypted location.
7. THE Serverpod server SHALL store only the `MessageCryptoEnvelope` ciphertext in the `messages` table and SHALL NOT store any plaintext message content.
8. THE DriftMessageRepository SHALL store decrypted plaintext locally on the device after successful decryption.

---

### Requirement 7: Device Registry

**User Story:** As a user, I want to see all devices where I am signed in and
be able to remotely sign out of any device, so that I can manage my account
security.

#### Acceptance Criteria

1. WHEN `DeviceManagerScreen` is opened, THE DeviceManagerNotifier SHALL call `DeviceRepository.listMyDevices()` and display the returned list.
2. THE DeviceRepository SHALL return a list of `DeviceInfo` objects each containing `deviceId`, `name`, `platform`, `lastSeenAt`, and `isCurrentDevice`.
3. WHEN a user taps the revoke button for a device, THE DeviceManagerNotifier SHALL call `DeviceRepository.revokeDevice(deviceId)` and refresh the device list.
4. WHEN `revokeDevice` is called for the current device, THE DeviceManagerNotifier SHALL also call `ServerpodAuthRepository.logout()` and navigate to the sign-in screen.
5. IF `listMyDevices()` fails, THEN THE DeviceManagerNotifier SHALL surface an error state to the UI without crashing.

---

### Requirement 8: Serverpod Media Upload

**User Story:** As a user, I want to send photos and files in chat, so that I
can share media with other participants.

#### Acceptance Criteria

1. WHEN `MessagingSyncMode.useServerpod` is active and a user sends a media file, THE ServerpodMediaUploadService SHALL call `client.media.requestUploadSlot` to obtain a `MediaUploadSlot`.
2. WHEN a `MediaUploadSlot` is obtained, THE ServerpodMediaUploadService SHALL upload the file to the provided `uploadUrl` using chunked PUT.
3. WHEN the upload completes, THE ServerpodMediaUploadService SHALL call `client.media.finalizeUpload` with `mediaId`, `finalizeToken`, and total byte count.
4. WHEN `finalizeUpload` succeeds, THE ServerpodMediaUploadService SHALL return the `fetchUrl` from `MediaFinalizeResult` to the caller.
5. WHEN `MessagingSyncMode.useFirestore` is active, THE ChatNotifier SHALL use the existing Firebase Storage upload path and SHALL NOT call `ServerpodMediaUploadService`.
6. WHEN an upload is in progress, THE ServerpodMediaUploadService SHALL invoke the `onProgress` callback with a value between 0.0 and 1.0 as each chunk completes.

---

### Requirement 9: FCM Token Registration

**User Story:** As a user, I want to receive push notifications on my device,
so that I am alerted to new messages even when the app is in the background.

#### Acceptance Criteria

1. WHEN a Serverpod session is established and `MessagingSyncMode.useServerpod` is active, THE FcmTokenSync SHALL register the FCM token with Serverpod by calling `client.push.registerToken`.
2. WHEN `MessagingSyncMode.useFirestore` is active, THE FcmTokenSync SHALL write the FCM token to Firestore using the existing path.
3. WHEN both `useFirestore` and `useServerpod` are active (dual-write cutover), THE FcmTokenSync SHALL write the FCM token to both Firestore and Serverpod.
4. WHEN the FCM token is refreshed by the platform, THE FcmTokenSync SHALL re-register the new token with all active backends.
5. WHEN a device is signed out via `DeviceRepository.revokeDevice`, THE Serverpod server SHALL remove the associated FCM token from the `push_tokens` table.

---

### Requirement 10: Safety Endpoint Wiring

**User Story:** As a user, I want to block other users and report harmful content,
so that I can protect myself and others from abuse.

#### Acceptance Criteria

1. WHEN `MessagingSyncMode.useServerpod` is active and a user blocks another user, THE ChatNotifier SHALL call `client.safety.blockUser(targetAuthUserId)`.
2. WHEN `MessagingSyncMode.useServerpod` is active and a user submits a report, THE ChatNotifier SHALL call `client.safety.submitReport` with `targetUserId`, optional `targetChatId`, optional `targetMessageId`, and `reason`.
3. WHEN `MessagingSyncMode.useFirestore` is active, THE AuthNotifier SHALL delegate block and report actions to the existing `AuthService` and SHALL NOT call `SafetyEndpoint`.
4. THE SafetyEndpoint SHALL require an authenticated session (`requireLogin = true`) for all block and report calls.
5. IF a block or report call fails due to a network error, THEN THE ChatNotifier SHALL surface an error to the UI and SHALL NOT silently discard the failure.

---

### Requirement 11: Migration Milestone Isolation

**User Story:** As a developer, I want each migration milestone to be independently
deployable and verifiable, so that I can roll back to Firestore at any point
without data loss.

#### Acceptance Criteria

1. WHILE `MessagingSyncMode.useFirestore` is active, THE system SHALL make no Serverpod RPC calls for messaging read or write operations.
2. WHILE `MessagingSyncMode.useServerpod` is active, THE system SHALL make no Firestore read calls for messaging operations.
3. WHEN the `SERVERPOD_MESSAGING` flag is set to `false`, THE system SHALL behave identically to the pre-integration Firestore-only path.
4. THE MessagingSyncMode flag SHALL be controllable via `--dart-define` at build time without requiring a code change.
5. WHEN transitioning from M1 to M2, THE system SHALL have populated the Drift database from the Serverpod stream before disabling Firestore reads.
