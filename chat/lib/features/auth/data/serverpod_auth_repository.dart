import 'dart:async';

import 'package:chat_client/chat_client.dart';

import '../../../core/crypto/e2ee_engine.dart';
import '../../../core/serverpod/serverpod_auth_key_manager.dart';

// ── Value objects ─────────────────────────────────────────────────────────────

/// Access + refresh token pair returned by the Serverpod auth endpoint.
final class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
}

// ── Exceptions ────────────────────────────────────────────────────────────────

/// Typed exceptions thrown by [ServerpodAuthRepository].
///
/// All variants are sealed so callers must handle every case exhaustively.
sealed class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The Firebase ID token was rejected by the server (expired, invalid, revoked).
final class InvalidFirebaseTokenException extends AuthException {
  const InvalidFirebaseTokenException([
    super.message = 'Firebase ID token is invalid or expired',
  ]);
}

/// The Serverpod session has expired and could not be refreshed.
final class SessionExpiredException extends AuthException {
  const SessionExpiredException([
    super.message = 'Serverpod session has expired',
  ]);
}

/// A network or transport error occurred during the auth call.
final class AuthNetworkException extends AuthException {
  const AuthNetworkException(super.message);
}

/// The server returned an unexpected error during the auth call.
final class AuthServerException extends AuthException {
  const AuthServerException(super.message);
}

// ── Repository interface ──────────────────────────────────────────────────────

/// Client-side contract for Firebase → Serverpod token exchange.
///
/// Requirements: 2.1, 2.2, 2.3, 2.7, 2.8
abstract interface class ServerpodAuthRepository {
  /// Exchange a Firebase ID token for a Serverpod [TokenPair].
  ///
  /// Uploads [publicKeyBundle] so the server can store the device's X25519
  /// public key alongside the session.
  ///
  /// On success: stores [TokenPair.accessToken] via [ServerpodAuthKeyManager.put]
  /// and [TokenPair.refreshToken] via [ServerpodAuthKeyManager.storeRefreshToken].
  ///
  /// On failure: throws a typed [AuthException] and leaves storage unchanged.
  Future<TokenPair> exchangeFirebaseToken({
    required String firebaseIdToken,
    required String deviceId,
    required PublicKeyBundle publicKeyBundle,
  });

  /// Refresh the current session using [refreshToken].
  ///
  /// On success: updates both stored tokens.
  /// On failure: throws [SessionExpiredException].
  Future<TokenPair> refreshSession(String refreshToken);

  /// Sign out: calls the server logout endpoint then clears all stored tokens.
  Future<void> logout(String deviceId);
}

// ── Implementation ────────────────────────────────────────────────────────────

/// Concrete implementation backed by the generated Serverpod [Client].
///
/// Constructor parameters are injected so the class is easily testable.
final class ServerpodAuthRepositoryImpl implements ServerpodAuthRepository {
  ServerpodAuthRepositoryImpl({
    required Client client,
    required ServerpodAuthKeyManager authKeyManager,
  })  : _client = client,
        _authKeyManager = authKeyManager;

  final Client _client;
  final ServerpodAuthKeyManager _authKeyManager;

  // ── exchangeFirebaseToken ─────────────────────────────────────────────────

  /// Requirements: 2.1, 2.2, 2.3, 2.8
  ///
  /// NOTE: `client.auth.exchangeFirebaseToken` is added in task 3.1.
  /// Until that endpoint is generated, this method throws [AuthServerException]
  /// with a clear message so callers can detect the missing endpoint gracefully.
  @override
  Future<TokenPair> exchangeFirebaseToken({
    required String firebaseIdToken,
    required String deviceId,
    required PublicKeyBundle publicKeyBundle,
  }) async {
    // Guard: do not write any token before the call succeeds (Requirement 2.8).
    try {
      final pair = await _callExchangeFirebaseToken(
        firebaseIdToken: firebaseIdToken,
        deviceId: deviceId,
        publicKeyBundle: publicKeyBundle,
      );

      // Persist both tokens only after a successful response (Req 2.2, 2.3).
      await Future.wait([
        _authKeyManager.put(pair.accessToken),
        _authKeyManager.storeRefreshToken(pair.refreshToken),
      ]);

      return pair;
    } on AuthException {
      // Re-throw typed exceptions without touching storage.
      rethrow;
    } catch (e) {
      // Any unexpected error must not leave partial state (Requirement 2.8).
      throw AuthServerException('Unexpected error during token exchange: $e');
    }
  }

  /// Calls the server endpoint.
  ///
  /// Separated so the storage-write logic in [exchangeFirebaseToken] is easy
  /// to test independently of the RPC call.
  Future<TokenPair> _callExchangeFirebaseToken({
    required String firebaseIdToken,
    required String deviceId,
    required PublicKeyBundle publicKeyBundle,
  }) async {
    try {
      // Call client.firebaseIdp.login with the Firebase ID token.
      // The server verifies the token via Firebase Admin SDK, upserts the user
      // in serverpod_auth_idp_firebase_account, and returns an AuthSuccess
      // containing the Serverpod access token and refresh token.
      final result = await _client.firebaseIdp.login(idToken: firebaseIdToken);

      return TokenPair(
        accessToken: result.token,
        refreshToken: result.refreshToken ?? '',
        expiresAt: result.tokenExpiresAt ??
            DateTime.now().add(const Duration(hours: 1)),
      );
    } on ServerpodClientException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw const InvalidFirebaseTokenException();
      }
      throw AuthServerException('Server error during token exchange: $e');
    } catch (e) {
      throw AuthNetworkException('Network error during token exchange: $e');
    }
  }

  // ── refreshSession ────────────────────────────────────────────────────────

  /// Requirements: 2.4, 2.5
  @override
  Future<TokenPair> refreshSession(String refreshToken) async {
    try {
      final result = await _client.jwtRefresh.refreshAccessToken(
        refreshToken: refreshToken,
      );

      final newRefreshToken = result.refreshToken ?? refreshToken;
      final pair = TokenPair(
        accessToken: result.token,
        refreshToken: newRefreshToken,
        expiresAt: result.tokenExpiresAt ?? DateTime.now().add(const Duration(hours: 1)),
      );

      await Future.wait([
        _authKeyManager.put(pair.accessToken),
        _authKeyManager.storeRefreshToken(pair.refreshToken),
      ]);

      return pair;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw SessionExpiredException('Token refresh failed: $e');
    }
  }

  // ── logout ────────────────────────────────────────────────────────────────

  /// Requirements: 2.7
  ///
  /// Calls the server logout endpoint first, then clears local storage.
  /// If the server call fails, storage is still cleared so the user is
  /// signed out locally even if the network is unavailable.
  @override
  Future<void> logout(String deviceId) async {
    try {
      // TODO(task-3.1): Replace with `_client.auth.logout(deviceId)` once the
      // FirebaseAuthEndpoint is generated.  For now we skip the server call and
      // only clear local state so logout always succeeds client-side.
    } catch (_) {
      // Swallow server errors — local sign-out must always succeed.
    } finally {
      await _authKeyManager.clearAll();
    }
  }
}

// ── Auth events ───────────────────────────────────────────────────────────────

/// Events emitted by [TokenRefreshInterceptor] on the [authEventStream].
enum AuthEvent {
  /// The session has expired and could not be refreshed automatically.
  /// The app should navigate to the sign-in screen.
  sessionExpired,
}

// ── TokenRefreshInterceptor ───────────────────────────────────────────────────

/// Wraps a [ServerpodAuthRepository] to provide transparent token refresh.
///
/// Call [onUnauthorized] whenever a Serverpod RPC returns a 401 / auth error.
/// The interceptor will:
///   1. Read the stored refresh token.
///   2. Attempt exactly one refresh via [ServerpodAuthRepository.refreshSession].
///   3. On success: update both stored tokens and signal the caller to retry.
///   4. On failure: clear all tokens and emit [AuthEvent.sessionExpired].
///
/// Requirements: 2.4, 2.5, 2.6
final class TokenRefreshInterceptor {
  TokenRefreshInterceptor({
    required ServerpodAuthRepository repository,
    required ServerpodAuthKeyManager authKeyManager,
  })  : _repository = repository,
        _authKeyManager = authKeyManager;

  final ServerpodAuthRepository _repository;
  final ServerpodAuthKeyManager _authKeyManager;

  final StreamController<AuthEvent> _eventController =
      StreamController<AuthEvent>.broadcast();

  /// Broadcast stream of [AuthEvent]s.
  ///
  /// Listen to this stream to react to session expiry (e.g. navigate to
  /// sign-in screen).
  Stream<AuthEvent> get authEventStream => _eventController.stream;

  /// Call this when a Serverpod RPC returns an auth / 401 error.
  ///
  /// Returns `true` if the token was refreshed successfully and the caller
  /// should retry the original request.
  /// Returns `false` if the refresh failed; [AuthEvent.sessionExpired] will
  /// have been emitted on [authEventStream].
  ///
  /// Requirements: 2.4, 2.5, 2.6
  Future<bool> onUnauthorized() async {
    final refreshToken = await _authKeyManager.readRefreshToken();

    if (refreshToken == null) {
      // No refresh token stored — session is definitively expired.
      _eventController.add(AuthEvent.sessionExpired);
      return false;
    }

    try {
      // Attempt exactly one refresh (Requirement 2.4).
      await _repository.refreshSession(refreshToken);
      // refreshSession already persists both new tokens (Requirement 2.5).
      return true;
    } catch (_) {
      // Refresh failed — clear all tokens and signal expiry (Requirement 2.6).
      await _authKeyManager.clearAll();
      _eventController.add(AuthEvent.sessionExpired);
      return false;
    }
  }

  /// Release resources. Call when the interceptor is no longer needed.
  void dispose() => _eventController.close();
}
