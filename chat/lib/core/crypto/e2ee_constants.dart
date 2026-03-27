import 'dart:convert';

/// Wire/schema version for Serverpod `MessageEndpoint` payloads (`schemaVersion` field).
const int kE2eeSchemaVersion = 1;

/// HKDF-SHA256 domain separation: X25519 shared secret → wrap key for a chat symmetric key.
final List<int> kHkdfInfoChatKeyWrap = utf8.encode('chat/e2ee/mvp/chat-key-wrap/v1');

/// Secure-storage key for the X25519 identity seed (32 bytes, base64-encoded at rest).
const String kSecureStorageIdentityX25519Seed = 'e2ee.identity.x25519.seed';
