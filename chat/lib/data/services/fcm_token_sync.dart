import 'package:cloud_firestore/cloud_firestore.dart';

/// Persists the FCM token on the user document (legacy path during Firestore
/// cutover). When Serverpod `push_tokens` is authoritative, **add** a call to
/// the generated client here without removing this until the flag flips.
Future<void> syncFcmTokenToFirestore({
  required String userId,
  required String token,
}) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'fcmToken': token,
    'lastActive': FieldValue.serverTimestamp(),
  });
}
