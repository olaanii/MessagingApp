# Serverpod endpoints v1 (Dart)

Implement as `Endpoint` subclasses on the server. Method names map to generated Flutter `client.*` calls after **`serverpod generate`**. Authentication: **Firebase ID token** verified server-side; issue Serverpod session per ADR (`docs/adr/`).

## Auth & session

| Dart endpoint class (suggested) | Methods | Notes |
|--------------------------------|---------|------|
| `AuthEndpoint` | `exchangeFirebaseToken(String idToken, String deviceId, String? deviceName)` → `TokenPair` | Maps `firebase_uid` → `users`; creates/refreshes **sessions** row |
| | `refreshSession(String refreshToken)` → `TokenPair` | Rotation + reuse policy per ADR |
| | `logout()` | Revoke current session |

## Devices & keys

| Endpoint | Methods | Notes |
|----------|---------|------|
| `DeviceEndpoint` | `list()`, `register(...)`, `revoke(deviceId)` | Multi-device registry |
| `KeyEndpoint` | `uploadBundle(deviceId, PublicKeyBundle)`, `fetchUserBundle(userId)` | **Public** material only; bundle shape **ADR-0008** (`schemaVersion`, 32-byte `x25519Public`; optional prekeys Phase 2) |

## Chats & messages

| Endpoint | Methods | Notes |
|----------|---------|------|
| `ChatEndpoint` | `createDirect(...)`, `createGroup(...)`, `listMine(cursor?, limit)`, `get(chatId)` | |
| `ChatMemberEndpoint` | `list(chatId)` | |
| `MessageEndpoint` | `send(chatId, clientMsgId, ciphertext, nonce, schemaVersion, ...)` → `Message` | **Idempotent** on `(chatId, senderDeviceId, clientMsgId)`; `ciphertext` = **AEAD** output: raw cipher **concat** 16-byte Poly1305 tag; `nonce` = 12 bytes; **`schemaVersion`** matches client crypto ADR (`lib/core/crypto/e2ee_constants.dart`) |
| | `listHistory(chatId, cursor?, limit)` | Snapshot / backfill |

## Sync & media

| Endpoint | Methods | Notes |
|----------|---------|------|
| `SyncEndpoint` | `changesForChat(chatId, cursor?, limit)` → `MessageSyncPage` | Opaque cursor per ADR |
| `MediaEndpoint` | `prepareUpload(mime, byteSize, chatId)`, `finalize(mediaId, sha256?, ...)` | Presign or Serverpod file API |

## Push & safety

| Endpoint | Methods | Notes |
|----------|---------|------|
| `PushEndpoint` | `registerToken(deviceId, token, platform)` | For server-triggered FCM |
| `SafetyEndpoint` | `report(...)`, `block(blockedUserId)` | Store compliance |

## Search

| Endpoint | Methods | Notes |
|----------|---------|------|
| `SearchEndpoint` | `metadataSearch(query)` | **No** ciphertext indexing |

## Streaming (realtime)

Implemented on **`chat_server`**: endpoint class `ChatStreamEndpoint`, method **`chatRoom`**:

```dart
Stream<ChatStreamEnvelope> chatRoom(
  Session session,
  String chatId,
  String deviceId,
  Stream<ChatStreamEnvelope> inbound,
);
```

- **Inbound** types handled: `send_message` (idempotent via `idempotencyKey`), `typing`, `presence`, `sync_hint`, `message_ack`.
- **Outbound** types emitted: `message` (after `send_message`; MVP in-memory `serverSeq` until `MessageEndpoint` persists to Postgres), `error`, plus relay of typing/presence/sync_hint/ack from peers.
- **Auth:** same session as other endpoints once Firebase → Serverpod session is wired (ADR-0003).
- **Scale:** in-process fan-out only (ADR-0009); reconnect + RPC sync required across instances.

Generated Flutter client: `client.chatStream.chatRoom(...)`.
