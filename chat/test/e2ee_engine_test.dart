import 'dart:typed_data';

import 'package:chat/core/crypto/e2ee_engine.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('E2eeEngine', () {
    test('message encrypt/decrypt roundtrip', () async {
      final engine = E2eeEngine();
      final chatKey = await engine.newChatKey();
      const text = 'hello e2ee';
      final env = await engine.encryptUtf8Message(text, chatKey);
      expect(env.schemaVersion, 1);
      expect(env.nonce.length, 12);
      expect(env.ciphertextWithMac.isNotEmpty, true);
      final out = await engine.decryptUtf8Message(env, chatKey);
      expect(out, text);
    });

    test('tampered ciphertext fails decrypt', () async {
      final engine = E2eeEngine();
      final chatKey = await engine.newChatKey();
      final env = await engine.encryptUtf8Message('x', chatKey);
      final bad = Uint8List.fromList(env.ciphertextWithMac);
      bad[bad.length - 1] ^= 0xff;
      final tampered = MessageCryptoEnvelope(
        schemaVersion: env.schemaVersion,
        nonce: env.nonce,
        ciphertextWithMac: bad,
      );
      await expectLater(
        engine.decryptUtf8Message(tampered, chatKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('wrap / unwrap chat key', () async {
      final engine = E2eeEngine();
      final alice = await engine.newIdentityKeyPair();
      final bob = await engine.newIdentityKeyPair();
      final chatKey = await engine.newChatKey();
      final wrapped = await engine.wrapChatKey(
        chatKey: chatKey,
        recipientPublic: bob.publicKey,
      );
      expect(wrapped.ephemeralPublic.length, 32);
      final unwrapped = await engine.unwrapChatKey(
        envelope: wrapped,
        recipientIdentity: bob,
      );
      final a = await chatKey.extractBytes();
      final b = await unwrapped.extractBytes();
      expect(b, a);
      alice.destroy();
    });

    /// Deterministic inputs (tests only). Stable across `package:cryptography` patch releases for CI.
    test('deterministic ciphertext for fixed key and nonce', () async {
      final engine = E2eeEngine();
      final chatKey = await Chacha20.poly1305Aead().newSecretKeyFromBytes(
        List<int>.generate(32, (i) => i),
      );
      final nonce = List<int>.generate(12, (i) => i + 1);
      final env = await engine.encryptUtf8Message(
        'vector',
        chatKey,
        nonce12: nonce,
      );
      final env2 = await engine.encryptUtf8Message(
        'vector',
        chatKey,
        nonce12: nonce,
      );
      expect(env.ciphertextWithMac, env2.ciphertextWithMac);
      expect(await engine.decryptUtf8Message(env, chatKey), 'vector');
    });
  });
}
