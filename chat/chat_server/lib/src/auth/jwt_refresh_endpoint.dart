import 'package:chat_server/src/security/security_guards.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// JWT refresh with ADR-0007 per-IP throttling.
class JwtRefreshEndpoint extends RefreshJwtTokensEndpoint {
  @override
  @unauthenticatedClientCall
  Future<AuthSuccess> refreshAccessToken(
    Session session, {
    required String refreshToken,
  }) async {
    SecurityGuards.requireAuthRefreshAllowed(session);
    return jwt.refreshAccessToken(
      session,
      refreshToken: refreshToken,
    );
  }
}
