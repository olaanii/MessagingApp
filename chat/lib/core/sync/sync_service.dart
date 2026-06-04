import 'dart:async';
import 'dart:convert';

import 'package:chat_client/chat_client.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../crypto/e2ee_engine.dart';
import '../crypto/e2ee_identity_store.dart';
import '../serverpod/serverpod_client_provider.dart';
import '../../data/local/db/app_database.dart';
import '../../data/providers/database_provider.dart';
import '../../features/auth/application/auth_notifier.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final syncServiceProvider = Provider<SyncService>((ref) {
  final client = ref.watch(serverpodClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final identityStore = ref.watch(e2eeIdentityStoreProvider);
  return SyncService(
    client: client,
    db: db,
    identityStore: identityStore,
    engine: E2eeEngine(),
  );
});

// ── SyncService ───────────────────────────────────────────────────────────────

/// Pulls incremental message changes from SyncEndpoint.getChatChanges,
/// decrypts with chat key when available, and persists to Drift.
///
/// Requirements: 9.5, 9.6 (cursor strategy per ADR-0004)
final class SyncService {
  SyncService({
    required Client client,
    required AppDatabase db,
    required E2eeIdentityStore identityStore,
    required E2eeEngine engine,
  })  : _client = client,
        _db = db,
        _identityStore = identityStore,
        _engine = engine;

  final Client _client;
  final AppDatabase _db;
  final E2eeIdentityStore _identityStore;
  final E2eeEngine _engine;

  static const int _pageSize = 100;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetch all new pages for [chatId] since the stored cursor, persist locally.
  Future<void> syncChat(String chatId) async {
    final scopeKey = 'sync:$chatId';
    String? cursor = await _db.getSyncCursor(scopeKey);

    try {
      while (true) {
        final page = await _client.message.syncMessages(
          UuidValue.fromString(chatId),
          cursor,
          _pageSize,
        );

        if (page.items.isEmpty) break;

        await _persistMessages(chatId, page.items);

        cursor = page.nextCursor;
        await _db.setSyncCursor(scopeKey, cursor);

        if (page.nextCursor == null || page.items.length < _pageSize) break;
      }
    } catch (e) {
      debugPrint('[SyncService] syncChat($chatId) failed: $e');
    }
  }

  /// Sync multiple chats concurrently (bounded to [concurrency] at a time).
  Future<void> syncChats(List<String> chatIds, {int concurrency = 3}) async {
    for (var i = 0; i < chatIds.length; i += concurrency) {
      final chunk = chatIds.sublist(
        i,
        (i + concurrency).clamp(0, chatIds.length),
      );
      await Future.wait(chunk.map(syncChat));
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  Future<void> _persistMessages(
    String chatId,
    List<ChatMessage> messages,
  ) async {
    if (messages.isEmpty) return;

    final identity = await _identityStore.loadOrCreateIdentity();
    final chatKey = await _tryLoadChatKey(identity);

    await _db.transaction(() async {
      for (final m in messages) {
        String body = m.ciphertext;

        if (chatKey != null) {
          try {
            body = await _decryptBody(m.ciphertext, m.nonce, chatKey);
          } catch (e) {
            debugPrint('[SyncService] decrypt failed for ${m.id.uuid}: $e');
          }
        }

        await _db.into(_db.localMessages).insertOnConflictUpdate(
              LocalMessagesCompanion.insert(
                id: m.id.uuid,
                chatId: m.chatId.uuid,
                senderId: m.senderAuthUserId.uuid,
                body: body,
                serverSeq: drift.Value(m.serverSeq),
                clientMsgId: drift.Value(m.clientMsgId),
                createdAt: m.createdAt.toUtc(),
                status: const drift.Value('delivered'),
                isPendingDelivery: const drift.Value(false),
              ),
            );
      }
    });
  }

  Future<SecretKey?> _tryLoadChatKey(SimpleKeyPairData identity) async {
    try {
      final deviceId = base64Encode(identity.publicKey.bytes);
      final wrapped = await _client.key.fetchUserBundle(deviceId);
      if (wrapped == null) return null;

      final map = jsonDecode(wrapped) as Map<String, dynamic>;
      final envelope = WrappedChatKeyEnvelope(
        schemaVersion: map['v'] as int,
        ephemeralPublic: _b64(map['eph'] as String),
        nonce: _b64(map['n'] as String),
        ciphertextWithMac: _b64(map['c'] as String),
      );
      return _engine.unwrapChatKey(
        envelope: envelope,
        recipientIdentity: identity,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _decryptBody(
    String ciphertextB64,
    String nonceB64,
    SecretKey chatKey,
  ) {
    final envelope = MessageCryptoEnvelope(
      schemaVersion: 1,
      nonce: _b64(nonceB64),
      ciphertextWithMac: _b64(ciphertextB64),
    );
    return _engine.decryptUtf8Message(envelope, chatKey);
  }

  static Uint8List _b64(String s) => Uint8List.fromList(base64Decode(s));
}
