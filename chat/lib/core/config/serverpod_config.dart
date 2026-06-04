/// Serverpod connection configuration for different environments
class ServerpodConfig {
  final String host;
  final int port;
  final String scheme;
  final bool streaming;

  const ServerpodConfig({
    required this.host,
    required this.port,
    required this.scheme,
    this.streaming = true,
  });

  /// Full API URL for Serverpod connection
  String get apiUrl => '$scheme://$host:$port/';

  /// WebSocket URL for streaming endpoints
  String get streamingUrl {
    final wsScheme = scheme == 'https' ? 'wss' : 'ws';
    return '$wsScheme://$host:$port/';
  }

  /// Development environment configuration
  static const development = ServerpodConfig(
    host: 'localhost',
    port: 8080,
    scheme: 'http',
    streaming: true,
  );

  /// Staging environment configuration
  static const staging = ServerpodConfig(
    host: 'api-staging.example.com',
    port: 443,
    scheme: 'https',
    streaming: true,
  );

  /// Production environment configuration
  static const production = ServerpodConfig(
    host: 'api.example.com',
    port: 443,
    scheme: 'https',
    streaming: true,
  );

  /// Get configuration based on environment variable or default to development
  static ServerpodConfig fromEnvironment(String? env) {
    switch (env?.toLowerCase()) {
      case 'staging':
        return staging;
      case 'production':
        return production;
      case 'development':
      default:
        return development;
    }
  }

  /// Create configuration from environment variables
  static ServerpodConfig fromEnvVars({
    String? host,
    String? port,
    String? scheme,
    String? streaming,
  }) {
    return ServerpodConfig(
      host: host ?? development.host,
      port: port != null ? int.tryParse(port) ?? development.port : development.port,
      scheme: scheme ?? development.scheme,
      streaming: streaming?.toLowerCase() == 'true' || streaming == null,
    );
  }

  @override
  String toString() => 'ServerpodConfig(apiUrl: $apiUrl, streaming: $streaming)';
}
