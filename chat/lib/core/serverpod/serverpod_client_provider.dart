import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_client/chat_client.dart';
import '../config/environment.dart';
import 'serverpod_auth_key_manager.dart';

/// Provider for application environment configuration
final appEnvironmentProvider = Provider<AppEnvironment>((ref) {
  // Default to development environment
  // This can be overridden in main.dart based on .env or build configuration
  return AppEnvironment.development;
});

/// Provider for Flutter secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider for Serverpod auth key manager
final serverpodAuthKeyManagerProvider = Provider<ServerpodAuthKeyManager>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ServerpodAuthKeyManager(storage);
});

/// Provider for Serverpod client instance
final serverpodClientProvider = Provider<Client>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final config = environment.serverpodConfig;
  final authKeyManager = ref.watch(serverpodAuthKeyManagerProvider);

  final client = Client(config.apiUrl);
  client.authKeyProvider = authKeyManager;

  // Log configuration in debug mode
  environment.logConfig();

  return client;
});

/// Provider for streaming connection (if needed)
final serverpodStreamingProvider = Provider<bool>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return environment.serverpodConfig.streaming;
});

/// Helper to get the current Serverpod API URL
final serverpodApiUrlProvider = Provider<String>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return environment.serverpodConfig.apiUrl;
});

/// Helper to get the current Serverpod streaming URL
final serverpodStreamingUrlProvider = Provider<String>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return environment.serverpodConfig.streamingUrl;
});
