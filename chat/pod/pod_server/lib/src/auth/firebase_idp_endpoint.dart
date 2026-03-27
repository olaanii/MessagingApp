import 'package:serverpod_auth_idp_server/providers/firebase.dart';

/// Firebase phone/email sign-in per ADR-0003. Call `login` with Firebase ID token;
/// configure `firebaseServiceAccountKey` in `config/passwords.yaml`.
class FirebaseIdpEndpoint extends FirebaseIdpBaseEndpoint {}
