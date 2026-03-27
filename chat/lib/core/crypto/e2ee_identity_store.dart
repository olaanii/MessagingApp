import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'e2ee_constants.dart';
import 'e2ee_engine.dart';

/// Loads or creates a device identity seed in [FlutterSecureStorage].
///
/// Private material never leaves secure storage except briefly in memory for DH/AEAD.
final class E2eeIdentityStore {
  E2eeIdentityStore({
    FlutterSecureStorage? storage,
    E2eeEngine? engine,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _engine = engine ?? E2eeEngine();

  final FlutterSecureStorage _storage;
  final E2eeEngine _engine;

  /// Returns existing identity or generates one and persists the seed.
  Future<SimpleKeyPairData> loadOrCreateIdentity() async {
    final existing = await _storage.read(key: kSecureStorageIdentityX25519Seed);
    if (existing != null && existing.isNotEmpty) {
      final seed = base64Decode(existing);
      return _engine.identityFromSeed(seed);
    }
    final pair = await _engine.newIdentityKeyPair();
    final seed = pair.bytes;
    await _storage.write(
      key: kSecureStorageIdentityX25519Seed,
      value: base64Encode(seed),
    );
    return pair;
  }

  Future<void> clearIdentity() async {
    await _storage.delete(key: kSecureStorageIdentityX25519Seed);
  }

  PublicKeyBundle publicBundleFor(SimpleKeyPairData identity) {
    return PublicKeyBundle(
      schemaVersion: kE2eeSchemaVersion,
      x25519Public: Uint8List.fromList(identity.publicKey.bytes),
    );
  }
}
