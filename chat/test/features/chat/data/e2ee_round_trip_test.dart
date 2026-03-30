// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:chat/core/crypto/e2ee_engine.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Property 1: E2EE Round-Trip ──────────────────────────────────────────────
// decrypt(encrypt(plaintext, key), key) == plaintext for arbitrary plaintext
// and key.
// **Validates: Requirements 6.1, 6.2**

final _engine = E2eeEngine();

/// Generate a list of arbitrary byte arrays to use as plaintext inputs.
/// Covers empty, short, medium, long, and binary (non-UTF-8-safe) content.
List<List<int>> _arbitraryByteInputs() {
  final rng = math.Random(42); // fixed seed for reproducibility
  return [
    // Empty
    <int>[],
    // Single byte
    [0x00],
    [0xff],
    // Short ASCII
    utf8.encode('hello world'),
    // Unicode
    utf8.encode('こんにちは 🔑'),
    // Medium length
    utf8.encode('a' * 256),
    // Long (1 KB)
    utf8.encode('x' * 1024),
    // Large (64 KB)
    utf8.encode('y' * 65536),
    // Random binary bytes (may not be valid UTF-8 — we test byte round-trip)
    List<int>.generate(128, (_) => rng.nextInt(256)),
    List<int>.generate(512, (_) => rng.nextInt(256)),
    // All-zero bytes
    List<int>.filled(32, 0),
    // All-max bytes
    List<int>.filled(32, 0xff),
  ];
}

/// Encrypt raw bytes by treating them as a UTF-8 string where possible,
/// or encoding them as base64 for binary content.
///
/// The property is: encode → encrypt → decrypt → decode == original bytes.
Future<void> _assertRoundTrip(List<int> plainBytes, SecretKey key) async {
  // Encode bytes to a string for the engine (which works on UTF-8 strings).
  // We use base64 to ensure any byte sequence is representable.
  final encoded = base64Encode(plainBytes);

  final envelope = await _engine.encryptUtf8Message(encoded, key);
  final decrypted = await _engine.decryptUtf8Message(envelope, key);

  expect(
    decrypted,
    equals(encoded),
    reason: 'decrypt(encrypt(plaintext, key), key) must equal plaintext',
  );

  // Also verify the decoded bytes match the original.
  final decodedBytes = base64Decode(decrypted);
  expect(
    Uint8List.fromList(decodedBytes),
    equals(Uint8List.fromList(plainBytes)),
    reason: 'decoded bytes must equal original bytes',
  );
}

void main() {
  group('Property 1: E2EE Round-Trip', () {
    late SecretKey chatKey;

    setUp(() async {
      chatKey = await _engine.newChatKey();
    });

    test('round-trip holds for all arbitrary byte inputs with a single key', () async {
      final inputs = _arbitraryByteInputs();
      for (final bytes in inputs) {
        await _assertRoundTrip(bytes, chatKey);
      }
    });

    test('round-trip holds across multiple independently generated keys', () async {
      final inputs = [
        utf8.encode('test message'),
        utf8.encode('another message with unicode 🔐'),
        List<int>.generate(64, (i) => i),
      ];

      for (int k = 0; k < 5; k++) {
        final key = await _engine.newChatKey();
        for (final bytes in inputs) {
          await _assertRoundTrip(bytes, key);
        }
      }
    });

    test('different keys produce different ciphertexts for same plaintext', () async {
      const plaintext = 'same plaintext';
      final key1 = await _engine.newChatKey();
      final key2 = await _engine.newChatKey();

      final env1 = await _engine.encryptUtf8Message(plaintext, key1);
      final env2 = await _engine.encryptUtf8Message(plaintext, key2);

      // Ciphertexts should differ (different keys → different output).
      expect(
        env1.ciphertextWithMac,
        isNot(equals(env2.ciphertextWithMac)),
        reason: 'different keys must produce different ciphertexts',
      );

      // But each decrypts correctly with its own key.
      expect(await _engine.decryptUtf8Message(env1, key1), equals(plaintext));
      expect(await _engine.decryptUtf8Message(env2, key2), equals(plaintext));
    });

    test('wrong key cannot decrypt ciphertext', () async {
      const plaintext = 'secret message';
      final correctKey = await _engine.newChatKey();
      final wrongKey = await _engine.newChatKey();

      final envelope = await _engine.encryptUtf8Message(plaintext, correctKey);

      await expectLater(
        _engine.decryptUtf8Message(envelope, wrongKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
        reason: 'decryption with wrong key must fail with auth error',
      );
    });

    test('tampered ciphertext fails authentication', () async {
      const plaintext = 'tamper test';
      final key = await _engine.newChatKey();
      final envelope = await _engine.encryptUtf8Message(plaintext, key);

      // Flip the last byte of the ciphertext+MAC.
      final tampered = Uint8List.fromList(envelope.ciphertextWithMac);
      tampered[tampered.length - 1] ^= 0xff;

      final tamperedEnvelope = MessageCryptoEnvelope(
        schemaVersion: envelope.schemaVersion,
        nonce: envelope.nonce,
        ciphertextWithMac: tampered,
      );

      await expectLater(
        _engine.decryptUtf8Message(tamperedEnvelope, key),
        throwsA(isA<SecretBoxAuthenticationError>()),
        reason: 'tampered ciphertext must fail authentication',
      );
    });

    test('nonce is unique across multiple encryptions of same plaintext', () async {
      const plaintext = 'repeated message';
      final key = await _engine.newChatKey();

      final nonces = <String>{};
      for (int i = 0; i < 20; i++) {
        final env = await _engine.encryptUtf8Message(plaintext, key);
        final nonceHex = env.nonce.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
        nonces.add(nonceHex);
      }

      // All 20 nonces should be unique (probability of collision is negligible).
      expect(
        nonces.length,
        equals(20),
        reason: 'each encryption must use a unique nonce',
      );
    });

    test('empty plaintext round-trips correctly', () async {
      const plaintext = '';
      final key = await _engine.newChatKey();
      final envelope = await _engine.encryptUtf8Message(plaintext, key);
      final decrypted = await _engine.decryptUtf8Message(envelope, key);
      expect(decrypted, equals(plaintext));
    });

    test('very long plaintext round-trips correctly', () async {
      final plaintext = 'a' * 100000; // 100 KB
      final key = await _engine.newChatKey();
      final envelope = await _engine.encryptUtf8Message(plaintext, key);
      final decrypted = await _engine.decryptUtf8Message(envelope, key);
      expect(decrypted, equals(plaintext));
    });
  });
}
