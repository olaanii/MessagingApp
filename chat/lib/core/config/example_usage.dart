// Example usage of Serverpod configuration in main.dart
// This file is for documentation purposes only and should not be imported

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/config_loader.dart';
import 'core/serverpod/serverpod_client_provider.dart';

void main() {
  // Option 1: Use default development environment
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  // Option 2: Load environment from compile-time constants
  final environment = ConfigLoader.loadEnvironment();
  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(environment),
      ],
      child: const MyApp(),
    ),
  );

  // Option 3: Load from explicit values (useful for testing)
  final customEnvironment = ConfigLoader.loadFromValues(
    environment: 'staging',
    host: 'api-staging.example.com',
    port: 443,
    scheme: 'https',
  );
  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(customEnvironment),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access Serverpod client anywhere in the app
    final client = ref.watch(serverpodClientProvider);
    final apiUrl = ref.watch(serverpodApiUrlProvider);
    
    return MaterialApp(
      title: 'Chat App',
      home: HomeScreen(),
    );
  }
}

// Example: Using Serverpod client in a repository
class ChatRepository {
  ChatRepository(this.ref);
  
  final Ref ref;
  
  Future<void> sendMessage(String chatId, String message) async {
    final client = ref.read(serverpodClientProvider);
    
    // Call Serverpod endpoint
    // await client.chat.sendMessage(...);
  }
}

// Example: Using in a Riverpod provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref);
});
*/
