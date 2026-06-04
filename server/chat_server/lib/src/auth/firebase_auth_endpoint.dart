import 'package:chat_server/src/security/security_guards.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/firebase.dart';

/// Firebase phone/email sign-in endpoint for the chat server.
///
/// Verifies the Firebase ID token via the Serverpod Firebase IdP and issues a
/// Serverpod auth token pair. Configure `firebaseServiceAccountKey` in
/// `config/passwords.yaml` to enable token verification.
class FirebaseAuthEndpoint extends FirebaseIdpBaseEndpoint {
  @override
  Future<AuthSuccess> login(Session session, {required String idToken}) async {
    SecurityGuards.requireAuthRefreshAllowed(session);
    return super.login(session, idToken: idToken);
  }
}
