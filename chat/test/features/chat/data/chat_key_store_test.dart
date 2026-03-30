// ignore_for_file: lines_longer_than_80_chars

import 'dart:typed_data';

import 'package:chat/core/crypto/e2ee_engine.dart';
import 'package:chat/features/chat/data/chat_key_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Minimal in-memory ChatKeyStore for testing ────────────────────────────────

/// Pure in-memory [ChatKeyStore] that avoids any platform channel dependency.
/// Used to test the store/get/delete contract without FlutterSecureStorage.
final class _InMemoryChatKeyStore implements ChatKeyStore {
  final Map<String, SecretKey> _store = {};

  @override
  Future<SecretKey?> getChatKey(String chatId) async => _store[chatId];

  @override
  Future<void> storeChatKey(String chatId, SecretKey key) async {
    _store[chatId] = key;
  }

  @override
  Future<void> deleteChatKey(String chatId) async {
    _store.remove(chatId);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _engine = E2eeEngine();

// ── Property 17: Wrapped Key Round-Trip ──────────────────────────────────────
// A chat key wrapped for a recipient's PublicKeyBundle and unwrapped with the
// corresponding private key equals the original.
// **Validates: Requirements 6.1, 6.2**

void main() {
  group('Property 17: Wrapped Key Round-Trip', () {
    // Test across multiple independently generated chat keys to cover the
    // property for arbitrary keys.
    for (int i = 0; i < 5; i++) {
      test('wrap/unwrap round-trip for key $i', () async {
        final chatKey = await _engine.newChatKey();
        final recipientIdentity = await _engine.newIdentityKeyPair();

        // Wrap the chat key for the recipient's public key.
        final wrapped = await _engine.wrapChatKey(
          chatKey: chatKey,
          recipientPublic: recipientIdentity.publicKey,
        );

        // Unwrap using the recipient's private key.
        final unwrapped = await _engine.unwrapChatKey(
          envelope: wrapped,
          recipientIdentity: recipientIdentity,
        );

        final originalBytes = await chatKey.extractBytes();
        final unwrappedBytes = await unwrapped.extractBytes();

        expect(
          unwrappedBytes,
          equals(originalBytes),
          reason: 'unwrapped key must equal the original chat key (Property 17)',
        );

        recipientIdentity.destroy();
      });
    }

    test('wrap for one recipient cannot be unwrapped by another', () async {
      final chatKey = await _engine.newChatKey();
      final alice = await _engine.newIdentityKeyPair();
      final bob = await _engine.newIdentityKeyPair();

      // Wrap for Alice.
      final wrapped = await _engine.wrapChatKey(
        chatKey: chatKey,
        recipientPublic: alice.publicKey,
      );

      // Bob tries to unwrap — must fail with an auth error.
      await expectLater(
        _engine.unwrapChatKey(envelope: wrapped, recipientIdentity: bob),
        throwsA(isA<SecretBoxAuthenticationError>()),
        reason: 'a different recipient must not be able to unwrap the key',
      );

      alice.destroy();
      bob.destroy();
    });

    test('ChatKeyStore store/get round-trip preserves key bytes', () async {
      final store = _InMemoryChatKeyStore();
      const chatId = 'chat_roundtrip';

      final chatKey = await _engine.newChatKey();
      final originalBytes = await chatKey.extractBytes();

      await store.storeChatKey(chatId, chatKey);
      final retrieved = await store.getChatKey(chatId);

      expect(retrieved, isNotNull);
      final retrievedBytes = await retrieved!.extractBytes();
      expect(
        retrievedBytes,
        equals(originalBytes),
        reason: 'stored and retrieved key bytes must be identical',
      );
    });

    test('getChatKey returns null for unknown chatId', () async {
      final store = _InMemoryChatKeyStore();
      final result = await store.getChatKey('nonexistent_chat');
      expect(result, isNull);
    });

    test('deleteChatKey removes the key', () async {
      final store = _InMemoryChatKeyStore();
      const chatId = 'chat_delete';

      final chatKey = await _engine.newChatKey();
      await store.storeChatKey(chatId, chatKey);

      // Confirm it's there.
      expect(await store.getChatKey(chatId), isNotNull);

      await store.deleteChatKey(chatId);

      // Now it should be gone.
      expect(await store.getChatKey(chatId), isNull);
    });

    test('different chatIds are stored independently', () async {
      final store = _InMemoryChatKeyStore();

      final key1 = await _engine.newChatKey();
      final key2 = await _engine.newChatKey();

      await store.storeChatKey('chat_a', key1);
      await store.storeChatKey('chat_b', key2);

      final bytes1 = await (await store.getChatKey('chat_a'))!.extractBytes();
      final bytes2 = await (await store.getChatKey('chat_b'))!.extractBytes();
      final original1 = await key1.extractBytes();
      final original2 = await key2.extractBytes();

      expect(bytes1, equals(original1));
      expect(bytes2, equals(original2));
      expect(
        Uint8List.fromList(bytes1),
        isNot(equals(Uint8List.fromList(bytes2))),
        reason: 'keys for different chats must be stored independently',
      );
    });

    test('overwriting a key replaces the previous value', () async {
      final store = _InMemoryChatKeyStore();
      const chatId = 'chat_overwrite';

      final key1 = await _engine.newChatKey();
      final key2 = await _engine.newChatKey();

      await store.storeChatKey(chatId, key1);
      await store.storeChatKey(chatId, key2);

      final retrieved = await store.getChatKey(chatId);
      final retrievedBytes = await retrieved!.extractBytes();
      final key2Bytes = await key2.extractBytes();

      expect(
        retrievedBytes,
        equals(key2Bytes),
        reason: 'second store must overwrite the first',
      );
    });

    test('wrap/unwrap round-trip then store/retrieve preserves key', () async {
      // End-to-end: wrap → unwrap → store → retrieve → compare
      final store = _InMemoryChatKeyStore();
      const chatId = 'chat_e2e';

      final originalKey = await _engine.newChatKey();
      final recipientIdentity = await _engine.newIdentityKeyPair();

      // Wrap for recipient.
      final wrapped = await _engine.wrapChatKey(
        chatKey: originalKey,
        recipientPublic: recipientIdentity.publicKey,
      );

      // Unwrap.
      final unwrapped = await _engine.unwrapChatKey(
        envelope: wrapped,
        recipientIdentity: recipientIdentity,
      );

      // Store in key store.
      await store.storeChatKey(chatId, unwrapped);

      // Retrieve and compare.
      final retrieved = await store.getChatKey(chatId);
      expect(retrieved, isNotNull);

      final originalBytes = await originalKey.extractBytes();
      final retrievedBytes = await retrieved!.extractBytes();

      expect(
        retrievedBytes,
        equals(originalBytes),
        reason: 'full wrap→unwrap→store→retrieve pipeline must preserve key bytes',
      );

      recipientIdentity.destroy();
    });
  });
}
