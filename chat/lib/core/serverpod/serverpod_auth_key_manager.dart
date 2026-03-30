import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:serverpod_client/serverpod_client.dart';

const String _kAccessToken = 'sp_access_token';
const String _kRefreshToken = 'sp_refresh_token';

/// Manages Serverpod session tokens in [FlutterSecureStorage].
///
/// Implements [AuthenticationKeyManager] so the generated [Client] can
/// automatically attach the bearer token to every outgoing RPC request.
final class ServerpodAuthKeyManager extends AuthenticationKeyManager {
  ServerpodAuthKeyManager(this._storage);

  final FlutterSecureStorage _storage;

  // ── AuthenticationKeyManager ──────────────────────────────────────────────

  /// Returns the stored access token, or `null` if none is present.
  @override
  Future<String?> get() async => _storage.read(key: _kAccessToken);

  /// Persists [key] as the access token.
  @override
  Future<void> put(String key) async =>
      _storage.write(key: _kAccessToken, value: key);

  /// Deletes the access token from secure storage.
  @override
  Future<void> remove() async => _storage.delete(key: _kAccessToken);

  /// Converts [key] to a Bearer authorization header value.
  ///
  /// Returns `null` when [key] is null (no active session).
  @override
  Future<String?> toHeaderValue(String? key) async {
    if (key == null) return null;
    return wrapAsBearerAuthHeaderValue(key);
  }

  // ── Refresh-token helpers ─────────────────────────────────────────────────

  /// Persists [token] as the refresh token under key `sp_refresh_token`.
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
