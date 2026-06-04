# Serverpod Configuration

This directory contains the configuration management system for Serverpod client integration.

## Overview

The configuration system supports multiple environments (development, staging, production) and provides flexible ways to configure the Serverpod connection settings.

## Files

- **`serverpod_config.dart`**: Defines Serverpod connection configuration (host, port, scheme, streaming)
- **`environment.dart`**: Manages application environment and provides environment-specific configurations
- **`config_loader.dart`**: Loads configuration from environment variables
- **`serverpod_client_provider.dart`**: Riverpod providers for Serverpod client instances

## Usage

### 1. Basic Setup (Development)

By default, the app uses development configuration connecting to `http://localhost:8080/`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/serverpod/serverpod_client_provider.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Using Environment Variables

Set environment variables in your `.env` file:

```env
APP_ENV=development
SERVERPOD_HOST=localhost
SERVERPOD_PORT=8080
SERVERPOD_SCHEME=http
SERVERPOD_STREAMING=true
```

Load them in your app:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/config_loader.dart';
import 'core/serverpod/serverpod_client_provider.dart';

void main() {
  final environment = ConfigLoader.loadEnvironment();
  
  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(environment),
      ],
      child: MyApp(),
    ),
  );
}
```

### 3. Environment-Specific Configuration

#### Development
```dart
final environment = AppEnvironment.development;
// Connects to http://localhost:8080/
```

#### Staging
```dart
final environment = AppEnvironment.staging;
// Connects to https://api-staging.example.com:443/
```

#### Production
```dart
final environment = AppEnvironment.production;
// Connects to https://api.example.com:443/
```

### 4. Using Serverpod Client in Your Code

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_client/chat_client.dart';
import 'core/serverpod/serverpod_client_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(serverpodClientProvider);
    
    // Use the client to call Serverpod endpoints
    // Example: await client.auth.exchangeFirebaseToken(...);
    
    return Container();
  }
}
```

### 5. Build-Time Configuration

You can also pass environment variables at build time:

```bash
# Development build
flutter run --dart-define=APP_ENV=development

# Staging build
flutter build apk --dart-define=APP_ENV=staging \
  --dart-define=SERVERPOD_HOST=api-staging.example.com \
  --dart-define=SERVERPOD_PORT=443 \
  --dart-define=SERVERPOD_SCHEME=https

# Production build
flutter build apk --dart-define=APP_ENV=production \
  --dart-define=SERVERPOD_HOST=api.example.com \
  --dart-define=SERVERPOD_PORT=443 \
  --dart-define=SERVERPOD_SCHEME=https
```

## Configuration Options

### ServerpodConfig

| Property | Type | Description |
|----------|------|-------------|
| `host` | String | Serverpod server hostname |
| `port` | int | Serverpod server port |
| `scheme` | String | Connection scheme (http/https) |
| `streaming` | bool | Enable WebSocket streaming |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_ENV` | Environment name (development/staging/production) | development |
| `SERVERPOD_HOST` | Serverpod server host | localhost |
| `SERVERPOD_PORT` | Serverpod server port | 8080 |
| `SERVERPOD_SCHEME` | Connection scheme (http/https) | http |
| `SERVERPOD_STREAMING` | Enable streaming (true/false) | true |

## Predefined Environments

### Development
- Host: `localhost`
- Port: `8080`
- Scheme: `http`
- Streaming: `true`

### Staging
- Host: `api-staging.example.com`
- Port: `443`
- Scheme: `https`
- Streaming: `true`

### Production
- Host: `api.example.com`
- Port: `443`
- Scheme: `https`
- Streaming: `true`

## Security Notes

1. **Never commit `.env` files** with production credentials to version control
2. Use `.env.example` as a template for required environment variables
3. Store production secrets in secure secret management systems
4. Use HTTPS (`scheme: 'https'`) for staging and production environments
5. Consider implementing certificate pinning for production builds

## Testing

You can override the environment configuration in tests:

```dart
testWidgets('Test with custom environment', (tester) async {
  final testEnvironment = ConfigLoader.loadFromValues(
    environment: 'development',
    host: 'localhost',
    port: 8080,
    scheme: 'http',
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(testEnvironment),
      ],
      child: MyApp(),
    ),
  );

  // Your test code...
});
```

## Troubleshooting

### Connection Issues

1. **Check server is running**: Ensure Serverpod server is running on the configured host/port
2. **Verify configuration**: Check that `APP_ENV` and Serverpod variables are set correctly
3. **Network access**: Ensure device/emulator can reach the server (use `10.0.2.2` for Android emulator instead of `localhost`)
4. **CORS settings**: For web builds, ensure Serverpod server has proper CORS configuration

### Environment Not Loading

1. Verify `.env` file exists and is in the correct location
2. Check that environment variables are being loaded before app initialization
3. Use `environment.logConfig()` to debug loaded configuration
4. Ensure `--dart-define` flags are passed correctly in build commands

## Related Documentation

- [Serverpod Client Documentation](https://docs.serverpod.dev/client)
- [Flutter Environment Variables](https://docs.flutter.dev/deployment/flavors)
- [Riverpod Documentation](https://riverpod.dev/)
