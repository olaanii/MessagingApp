import 'package:serverpod_auth_idp_server/providers/firebase.dart';

/// Firebase phone/email sign-in endpoint for the chat server.
///
/// Delegates to [FirebaseIdpBaseEndpoint.login] which:
///   1. Verifies the Firebase ID token via the Firebase Admin SDK.
///   2. Upserts the user in `serverpod_auth_core_user` and
///      `serverpod_auth_idp_firebase_account`.
///   3. Creates a Serverpod session and returns an [AuthSuccess] containing
///      the access token and refresh token.
///
/// Configure `firebaseServiceAccountKey` in `config/passwords.yaml` to enable
/// token verification (see ADR-0003).
///
/// Requirements: 2.1
class FirebaseAuthEndpoint extends FirebaseIdpBaseEndpoint {}
