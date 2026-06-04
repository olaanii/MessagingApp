import 'package:flutter/foundation.dart';
import 'environment.dart';

/// Configuration loader that reads from environment variables
/// 
/// This class provides methods to load configuration from environment variables
/// which can be set via .env files or build-time configuration.
class ConfigLoader {
  /// Load application environment from environment variables
  /// 
  /// Reads the following environment variables:
  /// - APP_ENV: Environment name (development, staging, production)
  /// - SERVERPOD_HOST: Serverpod server host
  /// - SERVERPOD_PORT: Serverpod server port
  /// - SERVERPOD_SCHEME: Connection scheme (http, https)
  /// - SERVERPOD_STREAMING: Enable streaming (true, false)
  /// 
  /// Falls back to development configuration if variables are not set.
  static AppEnvironment loadEnvironment() {
    // In Flutter, environment variables can be accessed via:
    // 1. const String.fromEnvironment() for compile-time constants
    // 2. Platform.environment for runtime environment variables
    // 3. .env files loaded via packages like flutter_dotenv
    
    const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'development');
    const serverpodHost = String.fromEnvironment('SERVERPOD_HOST', defaultValue: '');
    const serverpodPort = String.fromEnvironment('SERVERPOD_PORT', defaultValue: '');
    const serverpodScheme = String.fromEnvironment('SERVERPOD_SCHEME', defaultValue: '');
    const serverpodStreaming = String.fromEnvironment('SERVERPOD_STREAMING', defaultValue: '');

    final environment = AppEnvironment.fromEnvVars(
      appEnv: appEnv.isEmpty ? null : appEnv,
      serverpodHost: serverpodHost.isEmpty ? null : serverpodHost,
      serverpodPort: serverpodPort.isEmpty ? null : serverpodPort,
      serverpodScheme: serverpodScheme.isEmpty ? null : serverpodScheme,
      serverpodStreaming: serverpodStreaming.isEmpty ? null : serverpodStreaming,
    );

    if (kDebugMode) {
      print('Loaded configuration from environment variables');
      environment.logConfig();
    }

    return environment;
  }

  /// Load environment from explicit values (useful for testing or custom initialization)
  static AppEnvironment loadFromValues({
    required String environment,
    required String host,
    required int port,
    required String scheme,
    bool streaming = true,
  }) {
    return AppEnvironment.fromEnvVars(
      appEnv: environment,
      serverpodHost: host,
      serverpodPort: port.toString(),
      serverpodScheme: scheme,
      serverpodStreaming: streaming.toString(),
    );
  }
}
