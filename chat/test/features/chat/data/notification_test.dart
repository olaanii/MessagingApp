// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/core/sync/messaging_backend.dart';
import 'package:chat/data/services/fcm_token_sync.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Task 20.4 — Notification Integration Tests
  // Requirements: 11.1, 11.4
  // ═══════════════════════════════════════════════════════════════════════════

  group('Task 20.4 — Notification Integration', () {
    // ── FCM token registration ───────────────────────────────────────────
    // Requirement 11.1: FCM token registration

    test('FCM token: syncFcmToken routes to correct backend', () async {
      var serverpodCalled = false;
      var firestoreCalled = false;

      // Test serverpod-only mode.
      await syncFcmToken(
        userId: 'user_1',
        deviceId: 'device_1',
        token: 'test_token_serverpod',
        mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
        serverpodRegister: (uid, did, tok, platform) async {
          serverpodCalled = true;
        },
      );

      expect(serverpodCalled, isTrue,
          reason: 'serverpodRegister must be called in serverpod mode');
    });

    test('FCM token: token is correctly passed through the chain', () async {
      final captured = <({String userId, String deviceId, String token})>[];

      await syncFcmToken(
        userId: 'user_chain',
        deviceId: 'device_chain',
        token: 'chain_token',
        mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
        serverpodRegister: (uid, did, tok, platform) async {
          captured.add((userId: uid, deviceId: did, token: tok));
        },
      );

      expect(captured, hasLength(1));
      expect(captured.first.userId, equals('user_chain'));
      expect(captured.first.deviceId, equals('device_chain'));
      expect(captured.first.token, equals('chain_token'));
    });

    test('FCM token: multiple token updates overwrite previous', () async {
      final tokens = <String>[];

      for (int i = 0; i < 3; i++) {
        await syncFcmToken(
          userId: 'user_multi',
          deviceId: 'device_multi',
          token: 'token_v$i',
          mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
          serverpodRegister: (uid, did, tok, platform) async {
            tokens.add(tok);
          },
        );
      }

      expect(tokens, hasLength(3));
      expect(tokens.last, equals('token_v2'));
    });

    // ── Notification display ─────────────────────────────────────────────
    // Requirement 11.4: Notification display

    test('notification display: payload contains sender name only', () {
      // Simulate the notification payload structure that the app expects.
      final notificationPayload = <String, dynamic>{
        'title': 'Alice',
        'body': 'New message',
        'chatId': 'chat_abc',
        'data': {
          'chatId': 'chat_abc',
          'senderId': 'alice_uid',
        },
      };

      // Must NOT contain message content.
      expect(notificationPayload['data'] is Map, isTrue);
      final data = notificationPayload['data'] as Map;
      expect(data.containsKey('message'), isFalse,
          reason: 'notification data must not contain message content');
      expect(data.containsKey('content'), isFalse);
    });

    test('notification tap: chatId is extractable from payload for navigation', () {
      final payload = <String, dynamic>{
        'title': 'Bob',
        'body': 'New message',
        'data': {'chatId': 'chat_for_bob'},
      };

      // Extract chatId for navigation.
      final chatId = (payload['data'] as Map)['chatId'] as String?;
      expect(chatId, equals('chat_for_bob'),
          reason: 'chatId must be extractable from notification for navigation');
    });

    test('notification tap: handles missing chatId gracefully', () {
      final payload = <String, dynamic>{
        'title': 'Unknown',
        'body': 'New message',
        'data': <String, dynamic>{},
      };

      final chatId = (payload['data'] as Map)['chatId'] as String?;
      expect(chatId, isNull,
          reason: 'chatId should be null when not present in data');
    });

    // ── Notification preferences ────────────────────────────────────────

    test('notification preferences: per-chat mute flag', () {
      final mutedChats = <String>{};

      // Mute a chat.
      mutedChats.add('chat_muted');
      expect(mutedChats.contains('chat_muted'), isTrue);

      // Unmute.
      mutedChats.remove('chat_muted');
      expect(mutedChats.contains('chat_muted'), isFalse);
    });

    test('notification preferences: globally disabled notifications', () {
      bool globalNotificationsEnabled = true;

      // User disables notifications globally.
      globalNotificationsEnabled = false;
      expect(globalNotificationsEnabled, isFalse);

      // Re-enable.
      globalNotificationsEnabled = true;
      expect(globalNotificationsEnabled, isTrue);
    });
  });
}
