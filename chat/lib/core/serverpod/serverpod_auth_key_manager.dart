import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:serverpod_client/serverpod_client.dart';

const String _kAccessToken = 'sp_access_token';
const String _kRefreshToken = 'sp_refresh_token';

/// Manages Serverpod session tokens in [FlutterSecureStorage].
///
/// Implements [ClientAuthKeyProvider] so the generated [Client] can
/// automatically attach the bearer token to every outgoing RPC request.
final class ServerpodAuthKeyManager implements ClientAuthKeyProvider {
  ServerpodAuthKeyManager(this._storage);

  final FlutterSecureStorage _storage;

  // ── ClientAuthKeyProvider ─────────────────────────────────────────────────

  @override
  Future<String?> get authHeaderValue async {
    final token = await _storage.read(key: _kAccessToken);
    if (token == null) return null;
    return wrapAsBearerAuthHeaderValue(token);
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

  /// Returns the stored access token, or `null` if none is present.
  Future<String?> get() async => _storage.read(key: _kAccessToken);

  /// Persists [token] as the access token.
  Future<void> put(String token) async =>
      _storage.write(key: _kAccessToken, value: token);

  /// Deletes the access token from secure storage.
  Future<void> remove() async => _storage.delete(key: _kAccessToken);

  /// Persists [token] as the refresh token.
  Future<void> storeRefreshToken(String token) async =>
      _storage.write(key: _kRefreshToken, value: token);

  /// Returns the stored refresh token, or `null` if none is present.
  Future<String?> readRefreshToken() async =>
      _storage.read(key: _kRefreshToken);

  /// Deletes both the access token and the refresh token from secure storage.
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
  }
}
