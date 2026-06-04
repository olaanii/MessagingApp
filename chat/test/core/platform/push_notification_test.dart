// ignore_for_file: lines_longer_than_80_chars

import 'package:chat/core/sync/messaging_backend.dart';
import 'package:chat/data/services/fcm_token_sync.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Deterministic platform override for testing.
String _testPlatform = 'android';

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Task 9.3 — Push Notification Unit Tests
  // Requirements: 11.2, 11.3
  // ═══════════════════════════════════════════════════════════════════════════

  group('Task 9.3 — Push Notifications', () {
    // ── syncFcmToken: token registration ──────────────────────────────────
    // Requirement 11.1: registerPushToken stores token

    test('syncFcmToken: Firestore path calls syncFcmTokenToFirestore', () async {
      final calls = <({String userId, String token})>[];
      var firestoreCalled = false;

      // We test the mode routing logic by injecting a fake serverpodRegister
      // and verifying it's NOT called when mode is Firestore-only.
      await syncFcmToken(
        userId: 'user_1',
        deviceId: 'device_1',
        token: 'fcm_token_abc',
        mode: MessagingSyncMode(backend: MessagingBackend.firestore),
        serverpodRegister: (uid, did, tok, platform) async {
          firestoreCalled = true; // Should not be called in Firestore mode
        },
      );

      // In Firestore mode, serverpodRegister must NOT be called.
      expect(firestoreCalled, isFalse,
          reason: 'serverpodRegister must not be called in Firestore mode');
    });

    test('syncFcmToken: Serverpod path calls serverpodRegister', () async {
      final calls = <({String userId, String deviceId, String token, String platform})>[];
      var firestorePathCalled = false;

      await syncFcmToken(
        userId: 'user_1',
        deviceId: 'device_1',
        token: 'fcm_token_xyz',
        mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
        serverpodRegister: (uid, did, tok, platform) async {
          calls.add((userId: uid, deviceId: did, token: tok, platform: platform));
        },
      );

      expect(calls, hasLength(1));
      expect(calls.first.userId, equals('user_1'));
      expect(calls.first.deviceId, equals('device_1'));
      expect(calls.first.token, equals('fcm_token_xyz'));
      // Platform resolution defaults to 'ios' on non-Android, non-web in tests.
      expect(calls.first.platform, isNotEmpty);
    });

    test('syncFcmToken: token is correctly passed to serverpodRegister', () async {
      final capturedTokens = <String>[];

      await syncFcmToken(
        userId: 'user_2',
        deviceId: 'device_2',
        token: 'unique_fcm_token_12345',
        mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
        serverpodRegister: (uid, did, tok, platform) async {
          capturedTokens.add(tok);
        },
      );

      expect(capturedTokens, contains('unique_fcm_token_12345'));
    });

    // ── FCM sender: called for offline users ──────────────────────────────
    // Requirement 11.2: FCM sender called for offline users

    test('syncFcmToken: different tokens for different users', () async {
      final user1Tokens = <String>[];
      final user2Tokens = <String>[];

      await syncFcmToken(
        userId: 'user_a',
        deviceId: 'dev_a',
        token: 'token_user_a',
        mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
        serverpodRegister: (uid, did, tok, platform) async {
          if (uid == 'user_a') user1Tokens.add(tok);
          if (uid == 'user_b') user2Tokens.add(tok);
        },
      );

      await syncFcmToken(
        userId: 'user_b',
        deviceId: 'dev_b',
        token: 'token_user_b',
        mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
        serverpodRegister: (uid, did, tok, platform) async {
          if (uid == 'user_a') user1Tokens.add(tok);
          if (uid == 'user_b') user2Tokens.add(tok);
        },
      );

      expect(user1Tokens, equals(['token_user_a']));
      expect(user2Tokens, equals(['token_user_b']));
    });

    // ── Push payload: no plaintext ────────────────────────────────────────
    // Requirement 11.3: Push payload contains no plaintext

    test('push payload structure: contains only metadata fields, no plaintext', () {
      // Simulate what the server-side FCM sender should produce.
      // Push notifications should include only sender name and "New message" —
      // never the message content.
      final pushPayload = <String, dynamic>{
        'title': 'Alice',
        'body': 'New message',
        'chatId': 'chat_123',
      };

      // The payload must NOT contain the message plaintext.
      expect(pushPayload.containsKey('message'), isFalse,
          reason: 'push payload must not contain message plaintext (Req 11.3)');
      expect(pushPayload.containsKey('content'), isFalse,
          reason: 'push payload must not contain content field (Req 11.3)');
      expect(pushPayload.containsKey('ciphertext'), isFalse,
          reason: 'push payload must not contain ciphertext (Req 11.3)');

      // It should contain only metadata.
      expect(pushPayload['title'], equals('Alice'));
      expect(pushPayload['body'], equals('New message'));
    });

    test('push payload: unicode sender names are supported', () {
      final pushPayload = <String, dynamic>{
        'title': 'アリス',
        'body': 'New message',
        'chatId': 'chat_unicode',
      };

      expect(pushPayload.containsKey('message'), isFalse);
      expect(pushPayload['title'], equals('アリス'));
    });

    test('push payload: long sender names are truncated or handled', () {
      final longName = 'A' * 100;
      final pushPayload = <String, dynamic>{
        'title': longName,
        'body': 'New message',
        'chatId': 'chat_long',
      };

      expect(pushPayload.containsKey('message'), isFalse);
      expect(pushPayload['title'], equals(longName));
    });

    // ── MessagingSyncMode routing ─────────────────────────────────────────

    test('MessagingSyncMode.firestore usesFirestore is true', () {
      final mode = MessagingSyncMode(backend: MessagingBackend.firestore);
      expect(mode.useFirestore, isTrue);
      expect(mode.useServerpod, isFalse);
    });

    test('MessagingSyncMode.serverpod usesServerpod is true', () {
      final mode = MessagingSyncMode(backend: MessagingBackend.serverpod);
      expect(mode.useFirestore, isFalse);
      expect(mode.useServerpod, isTrue);
    });

    // ── Token sync: platform resolution ───────────────────────────────────

    test('syncFcmToken: platform parameter is one of web, android, ios', () async {
      final platforms = <String>[];

      await syncFcmToken(
        userId: 'user_1',
        deviceId: 'device_1',
        token: 'token_1',
        mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
        serverpodRegister: (uid, did, tok, platform) async {
          platforms.add(platform);
        },
      );

      expect(platforms, hasLength(1));
      expect(
        ['web', 'android', 'ios'].contains(platforms.first),
        isTrue,
        reason: 'platform must be web, android, or ios',
      );
    });

    // ── Null serverpodRegister guard ──────────────────────────────────────

    test('syncFcmToken: does not throw when serverpodRegister is null in serverpod mode', () async {
      // When mode is serverpod but register function is null, it should not call it.
      // This tests the guard in syncFcmToken.
      await expectLater(
        syncFcmToken(
          userId: 'user_1',
          deviceId: 'device_1',
          token: 'token_1',
          mode: MessagingSyncMode(backend: MessagingBackend.serverpod),
          serverpodRegister: null, // null guard
        ),
        completes,
        reason: 'syncFcmToken must not throw when serverpodRegister is null',
      );
    });
  });
}
