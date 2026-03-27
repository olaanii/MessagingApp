import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'e2ee_constants.dart';

/// MVP E2EE primitives: X25519 + HKDF-SHA256 + ChaCha20-Poly1305.
///
/// Scope matches [ADR-0006](../../../../docs/adr/0006-e2ee-mvp-vs-phase2.md) and
/// [ADR-0008](../../../../docs/adr/0008-e2ee-crypto-suite-key-lifecycle.md).
///
/// Call sites (repositories) encrypt **before** RPC; the server stores ciphertext only.
final class E2eeEngine {
  E2eeEngine()
      : _x25519 = X25519(),
        _aead = Chacha20.poly1305Aead(),
        _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  final X25519 _x25519;
  final Cipher _aead;
  final Hkdf _hkdf;

  /// New X25519 identity key pair (32-byte seed / clamped scalar per library).
  Future<SimpleKeyPairData> newIdentityKeyPair() async {
    final pair = await _x25519.newKeyPair();
    final data = await pair.extract();
    if (data is! SimpleKeyPairData) {
      throw StateError('Expected X25519 SimpleKeyPairData');
    }
    return data;
  }

  /// Restore identity from a stored 32-byte seed.
  Future<SimpleKeyPairData> identityFromSeed(List<int> seed32) async {
    if (seed32.length != 32) {
      throw ArgumentError.value(seed32.length, 'seed32', 'expected 32 bytes');
    }
    final pair = await _x25519.newKeyPairFromSeed(List<int>.from(seed32));
    final data = await pair.extract();
    if (data is! SimpleKeyPairData) {
      throw StateError('Expected X25519 SimpleKeyPairData');
    }
    return data;
  }

  /// Decode uploaded [PublicKeyBundle.x25519Public] bytes to a [SimplePublicKey].
  SimplePublicKey parseIdentityPublic(List<int> raw32) {
    if (raw32.length != 32) {
      throw ArgumentError.value(raw32.length, 'raw32', 'expected 32 bytes');
    }
    return SimplePublicKey(
      Uint8List.fromList(raw32),
      type: KeyPairType.x25519,
    );
  }

  /// Random 32-byte chat symmetric key (ChaCha20-Poly1305 key size).
  Future<SecretKey> newChatKey() => _aead.newSecretKey();

  /// Encrypt a UTF-8 message for storage/RPC. Nonce is random unless [nonce12] is given (tests only).
  Future<MessageCryptoEnvelope> encryptUtf8Message(
    String plaintext,
    SecretKey chatKey, {
    List<int>? nonce12,
  }) async {
    final clear = utf8.encode(plaintext);
    final nonce = nonce12 ?? _aead.newNonce();
    if (nonce.length != _aead.nonceLength) {
      throw ArgumentError.value(nonce.length, 'nonce', 'bad length');
    }
    final box = await _aead.encrypt(
      clear,
      secretKey: chatKey,
      nonce: nonce,
    );
    return MessageCryptoEnvelope(
      schemaVersion: kE2eeSchemaVersion,
      nonce: Uint8List.fromList(box.nonce),
      ciphertextWithMac: _packSecretBox(box),
    );
  }

  /// Decrypt a message envelope to UTF-8 text.
  Future<String> decryptUtf8Message(
    MessageCryptoEnvelope envelope,
    SecretKey chatKey,
  ) async {
    if (envelope.schemaVersion != kE2eeSchemaVersion) {
      throw ArgumentError('unsupported schemaVersion ${envelope.schemaVersion}');
    }
    final box = _unpackSecretBox(envelope.ciphertextWithMac, envelope.nonce);
    final clear = await _aead.decrypt(
      box,
      secretKey: chatKey,
    );
    return utf8.decode(clear);
  }

  /// Wrap [chatKey] for [recipientPublic] using an ephemeral X25519 handshake.
  Future<WrappedChatKeyEnvelope> wrapChatKey({
    required SecretKey chatKey,
    required SimplePublicKey recipientPublic,
  }) async {
    final ephemeral = await _x25519.newKeyPair();
    final extracted = await ephemeral.extract();
    if (extracted is! SimpleKeyPairData) {
      throw StateError('Expected X25519 SimpleKeyPairData');
    }
    final ephemeralData = extracted;
    final ephemeralPub = ephemeralData.publicKey.bytes;
    final shared = await _x25519.sharedSecretKey(
      keyPair: ephemeral,
      remotePublicKey: recipientPublic,
    );
    final wrapSecret = await _hkdf.deriveKey(
      secretKey: shared,
      nonce: const <int>[],
      info: kHkdfInfoChatKeyWrap,
    );
    final chatBytes = await chatKey.extractBytes();
    if (chatBytes.length != 32) {
      throw StateError('unexpected chat key length');
    }
    final nonce = _aead.newNonce();
    final box = await _aead.encrypt(
      chatBytes,
      secretKey: wrapSecret,
      nonce: nonce,
    );
    ephemeralData.destroy();
    return WrappedChatKeyEnvelope(
      schemaVersion: kE2eeSchemaVersion,
      ephemeralPublic: Uint8List.fromList(ephemeralPub),
      nonce: Uint8List.fromList(box.nonce),
      ciphertextWithMac: _packSecretBox(box),
    );
  }

  /// Unwrap a chat key using the recipient's identity private key material.
  Future<SecretKey> unwrapChatKey({
    required WrappedChatKeyEnvelope envelope,
    required SimpleKeyPairData recipientIdentity,
  }) async {
    if (envelope.schemaVersion != kE2eeSchemaVersion) {
      throw ArgumentError('unsupported schemaVersion ${envelope.schemaVersion}');
    }
    final remotePub = parseIdentityPublic(envelope.ephemeralPublic);
    final shared = await _x25519.sharedSecretKey(
      keyPair: recipientIdentity,
      remotePublicKey: remotePub,
    );
    final wrapSecret = await _hkdf.deriveKey(
      secretKey: shared,
      nonce: const <int>[],
      info: kHkdfInfoChatKeyWrap,
    );
    final box = _unpackSecretBox(envelope.ciphertextWithMac, envelope.nonce);
    final keyBytes = await _aead.decrypt(
      box,
      secretKey: wrapSecret,
    );
    if (keyBytes.length != 32) {
      throw StateError('unexpected unwrapped key length');
    }
    return await _aead.newSecretKeyFromBytes(keyBytes);
  }

  Uint8List _packSecretBox(SecretBox box) {
    final macBytes = box.mac.bytes;
    final out = Uint8List(box.cipherText.length + macBytes.length);
    out.setAll(0, box.cipherText);
    out.setAll(box.cipherText.length, macBytes);
    return out;
  }

  SecretBox _unpackSecretBox(Uint8List ciphertextWithMac, Uint8List nonce) {
    if (ciphertextWithMac.length < 16) {
      throw ArgumentError('ciphertext too short');
    }
    final ctLen = ciphertextWithMac.length - 16;
    final ct = Uint8List.sublistView(ciphertextWithMac, 0, ctLen);
    final mac = Mac(Uint8List.sublistView(ciphertextWithMac, ctLen));
    return SecretBox(
      ct,
      nonce: nonce,
      mac: mac,
    );
  }
}

/// Serializable metadata + nonce + `ciphertext || mac` for Serverpod `MessageEndpoint`.
final class MessageCryptoEnvelope {
  const MessageCryptoEnvelope({
    required this.schemaVersion,
    required this.nonce,
    required this.ciphertextWithMac,
  });

  final int schemaVersion;
  final Uint8List nonce;
  final Uint8List ciphertextWithMac;
}

/// Ephemeral X25519 public key + AEAD of the 32-byte chat key, for member bootstrap / device add (MVP).
final class WrappedChatKeyEnvelope {
  const WrappedChatKeyEnvelope({
    required this.schemaVersion,
    required this.ephemeralPublic,
    required this.nonce,
    required this.ciphertextWithMac,
  });

  final int schemaVersion;
  final Uint8List ephemeralPublic;
  final Uint8List nonce;
  final Uint8List ciphertextWithMac;
}

/// Public material uploaded via `KeyEndpoint.uploadBundle` (see `docs/protocol/v1/endpoints.md`).
final class PublicKeyBundle {
  const PublicKeyBundle({
    required this.schemaVersion,
    required this.x25519Public,
  });

  final int schemaVersion;
  final Uint8List x25519Public;
}
