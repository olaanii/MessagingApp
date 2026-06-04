import 'package:chat_server/src/security/security_guards.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// [EmailIdpBaseEndpoint] with ADR-0007 IP + per-email throttles on hot paths.
class ThrottledEmailIdpEndpoint extends EmailIdpBaseEndpoint {
  @override
  Future<AuthSuccess> login(
    Session session, {
    required String email,
    required String password,
  }) async {
    SecurityGuards.requireEmailLoginAllowed(session, email);
    return super.login(session, email: email, password: password);
  }

  @override
  Future<UuidValue> startRegistration(
    Session session, {
    required String email,
  }) async {
    SecurityGuards.requireEmailRegistrationAllowed(session);
    return super.startRegistration(session, email: email);
  }

  @override
  Future<UuidValue> startPasswordReset(
    Session session, {
    required String email,
  }) async {
    SecurityGuards.requireEmailPasswordResetAllowed(session);
    return super.startPasswordReset(session, email: email);
  }
}
