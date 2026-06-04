import 'package:flutter/foundation.dart';
import 'serverpod_config.dart';

/// Environment types
enum Environment {
  development,
  staging,
  production;

  /// Get environment from string
  static Environment fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      case 'development':
      default:
        return Environment.development;
    }
  }
}

/// Application environment configuration manager
class AppEnvironment {
  final Environment environment;
  final ServerpodConfig serverpodConfig;

  const AppEnvironment({
    required this.environment,
    required this.serverpodConfig,
  });

  /// Check if running in development mode
  bool get isDevelopment => environment == Environment.development;

  /// Check if running in staging mode
  bool get isStaging => environment == Environment.staging;

  /// Check if running in production mode
  bool get isProduction => environment == Environment.production;

  /// Get environment name
  String get name => environment.name;

  /// Create environment configuration from environment variables
  /// 
  /// Reads from the following environment variables:
  /// - APP_ENV: Environment name (development, staging, production)
  /// - SERVERPOD_HOST: Serverpod server host
  /// - SERVERPOD_PORT: Serverpod server port
  /// - SERVERPOD_SCHEME: Connection scheme (http, https)
  /// - SERVERPOD_STREAMING: Enable streaming (true, false)
  static AppEnvironment fromEnvVars({
    String? appEnv,
    String? serverpodHost,
    String? serverpodPort,
    String? serverpodScheme,
    String? serverpodStreaming,
  }) {
    final env = Environment.fromString(appEnv);
    
    // If specific env vars are provided, use them
    if (serverpodHost != null || serverpodPort != null || serverpodScheme != null) {
      return AppEnvironment(
        environment: env,
        serverpodConfig: ServerpodConfig.fromEnvVars(
          host: serverpodHost,
          port: serverpodPort,
          scheme: serverpodScheme,
          streaming: serverpodStreaming,
        ),
      );
    }
    
    // Otherwise use predefined configurations
    return AppEnvironment(
      environment: env,
      serverpodConfig: ServerpodConfig.fromEnvironment(appEnv),
    );
  }

  /// Default development environment
  static const development = AppEnvironment(
    environment: Environment.development,
    serverpodConfig: ServerpodConfig.development,
  );

  /// Default staging environment
  static const staging = AppEnvironment(
    environment: Environment.staging,
    serverpodConfig: ServerpodConfig.staging,
  );

  /// Default production environment
  static const production = AppEnvironment(
    environment: Environment.production,
    serverpodConfig: ServerpodConfig.production,
  );

  @override
  String toString() => 'AppEnvironment($name, ${serverpodConfig.apiUrl})';

  /// Log environment configuration (for debugging)
  void logConfig() {
    if (kDebugMode) {
      print('=== Environment Configuration ===');
      print('Environment: $name');
      print('Serverpod API URL: ${serverpodConfig.apiUrl}');
      print('Serverpod Streaming URL: ${serverpodConfig.streamingUrl}');
      print('Streaming Enabled: ${serverpodConfig.streaming}');
      print('================================');
    }
  }
}
