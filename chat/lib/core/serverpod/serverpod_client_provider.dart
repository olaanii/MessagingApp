import 'package:chat_client/chat_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../env/env.dart';
import 'serverpod_auth_key_manager.dart';

/// Provides the [ServerpodAuthKeyManager] backed by [FlutterSecureStorage].
///
/// Created once per [ProviderScope]; no disposal needed (stateless wrapper).
final authKeyManagerProvider = Provider<ServerpodAuthKeyManager>((ref) {
  return ServerpodAuthKeyManager(const FlutterSecureStorage());
});

/// Provides the generated Serverpod [Client], configured with:
/// - [ServerpodAuthKeyManager] so every RPC carries the bearer token.
/// - `disconnectStreamsOnLostInternetConnection: true` (Requirement 1.6).
///
/// Created exactly once per [ProviderScope]; closed on teardown (Requirement 1.1).
final serverpodClientProvider = Provider<Client>((ref) {
  final manager = ref.watch(authKeyManagerProvider);
  final client = Client(
    Env.serverpodApiUrl,
    // ignore: deprecated_member_use
    authenticationKeyManager: manager,
    disconnectStreamsOnLostInternetConnection: true,
  );
  ref.onDispose(client.close);
  return client;
});
