import 'package:cryptography/cryptography.dart';

import '../../../core/crypto/e2ee_engine.dart';
import 'chat_key_store.dart';

// ── Interface ─────────────────────────────────────────────────────────────────

/// Bootstraps per-chat symmetric keys and distributes wrapped copies to chat
/// members via `KeyEndpoint`.
///
/// Requirements: 6.1, 6.2
abstract interface class KeyExchangeService {
  /// Generate a new [chatKey] for [chatId], wrap it for each member's
  /// [PublicKeyBundle], upload the wrapped envelopes via
  /// `KeyEndpoint.uploadWrappedKeys`, and store the own key in [ChatKeyStore].
  ///
  /// [memberBundles] must include the caller's own bundle so the caller can
  /// also decrypt messages in the chat.
  Future<void> bootstrapChat({
    required String chatId,
    required List<PublicKeyBundle> memberBundles,
  });

  /// Unwrap a [WrappedChatKeyEnvelope] received from the server using the
  /// device's private key, then store the resulting [chatKey] in [ChatKeyStore].
  Future<void> receiveWrappedKey({
    required String chatId,
    required WrappedChatKeyEnvelope envelope,
  });
}

// ── Implementation ────────────────────────────────────────────────────────────

/// Callback type for uploading wrapped key envelopes to the server.
///
/// Matches the signature of `KeyEndpoint.uploadWrappedKeys` so the real
/// client and test fakes can both be injected.
typedef UploadWrappedKeysFn = Future<void> Function(
  String chatId,
  List<WrappedChatKeyEnvelope> envelopes,
);

/// Concrete [KeyExchangeService] backed by [E2eeEngine] and [ChatKeyStore].
///
/// Requirements: 6.1, 6.2
final class KeyExchangeServiceImpl implements KeyExchangeService {
  KeyExchangeServiceImpl({
    required E2eeEngine engine,
    required ChatKeyStore keyStore,
    required SimpleKeyPairData deviceIdentity,
    required UploadWrappedKeysFn uploadWrappedKeys,
  })  : _engine = engine,
        _keyStore = keyStore,
        _deviceIdentity = deviceIdentity,
        _uploadWrappedKeys = uploadWrappedKeys;

  final E2eeEngine _engine;
  final ChatKeyStore _keyStore;
  final SimpleKeyPairData _deviceIdentity;
  final UploadWrappedKeysFn _uploadWrappedKeys;

  // ── bootstrapChat ─────────────────────────────────────────────────────────

  /// Requirement 6.1: generate chatKey, wrap for each member, upload, store own.
  @override
  Future<void> bootstrapChat({
    required String chatId,
    required List<PublicKeyBundle> memberBundles,
  }) async {
    // 1. Generate a fresh symmetric key for this chat.
    final chatKey = await _engine.newChatKey();

    // 2. Wrap the chat key for every member's public key.
    final envelopes = <WrappedChatKeyEnvelope>[];
    for (final bundle in memberBundles) {
      final recipientPublic = _engine.parseIdentityPublic(bundle.x25519Public);
      final wrapped = await _engine.wrapChatKey(
        chatKey: chatKey,
        recipientPublic: recipientPublic,
      );
      envelopes.add(wrapped);
    }

    // 3. Upload all wrapped envelopes to the server.
    await _uploadWrappedKeys(chatId, envelopes);

    // 4. Store the plaintext chat key locally for our own use.
    await _keyStore.storeChatKey(chatId, chatKey);
  }

  // ── receiveWrappedKey ─────────────────────────────────────────────────────

  /// Requirement 6.2: unwrap envelope with device private key; store in store.
  @override
  Future<void> receiveWrappedKey({
    required String chatId,
    required WrappedChatKeyEnvelope envelope,
  }) async {
    final chatKey = await _engine.unwrapChatKey(
      envelope: envelope,
      recipientIdentity: _deviceIdentity,
    );
    await _keyStore.storeChatKey(chatId, chatKey);
  }
}
