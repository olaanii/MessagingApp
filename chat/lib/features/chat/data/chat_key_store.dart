import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ── Interface ─────────────────────────────────────────────────────────────────

/// Manages per-chat symmetric keys in [FlutterSecureStorage].
///
/// All keys are stored exclusively in encrypted secure storage — never in
/// SharedPreferences, Hive, or any other unencrypted location.
///
/// Requirements: 6.3, 6.5, 6.6
abstract interface class ChatKeyStore {
  /// Returns the [SecretKey] for [chatId], or `null` if not found.
  Future<SecretKey?> getChatKey(String chatId);

  /// Persists [key] for [chatId] in secure storage.
  Future<void> storeChatKey(String chatId, SecretKey key);

  /// Removes the key for [chatId] from secure storage.
  Future<void> deleteChatKey(String chatId);
}

// ── Implementation ────────────────────────────────────────────────────────────

/// [ChatKeyStore] backed by [FlutterSecureStorage].
///
/// Keys are serialised as base64-encoded raw bytes (32 bytes for ChaCha20-Poly1305).
/// The storage key for a chat is `chat_key.<chatId>`.
///
/// Requirements: 6.3, 6.5, 6.6
final class FlutterSecureStorageChatKeyStore implements ChatKeyStore {
  FlutterSecureStorageChatKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kPrefix = 'chat_key.';

  String _storageKey(String chatId) => '$_kPrefix$chatId';

  @override
  Future<SecretKey?> getChatKey(String chatId) async {
    final encoded = await _storage.read(key: _storageKey(chatId));
    if (encoded == null || encoded.isEmpty) return null;
    final bytes = base64Decode(encoded);
    return SecretKeyData(bytes);
  }

  @override
  Future<void> storeChatKey(String chatId, SecretKey key) async {
    final bytes = await key.extractBytes();
    final encoded = base64Encode(bytes);
    await _storage.write(key: _storageKey(chatId), value: encoded);
  }

  @override
  Future<void> deleteChatKey(String chatId) async {
    await _storage.delete(key: _storageKey(chatId));
  }
}
