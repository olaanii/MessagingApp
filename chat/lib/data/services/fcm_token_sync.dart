import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/sync/messaging_backend.dart';

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

/// Synchronises the FCM [token] for [userId] to the appropriate backend(s)
/// based on [mode].
///
/// - [MessagingBackend.firestore]: writes to Firestore via [syncFcmTokenToFirestore].
/// - [MessagingBackend.serverpod]: calls [serverpodRegister] with the resolved
///   platform string (`'android'`, `'ios'`, or `'web'`).
/// - Dual-write (both active): calls both paths.
///
/// [serverpodRegister] is injected by the caller so this function does not
/// import `chat_client` directly, keeping it testable without a live client.
///
/// Requirements: 9.1, 9.2, 9.3, 9.4
Future<void> syncFcmToken({
  required String userId,
  required String token,
  required MessagingSyncMode mode,
  Future<void> Function(String userId, String token, String platform)?
      serverpodRegister,
}) async {
  final platform = _resolvePlatform();

  if (mode.useFirestore) {
    await syncFcmTokenToFirestore(userId: userId, token: token);
  }

  if (mode.useServerpod) {
    if (serverpodRegister != null) {
      await serverpodRegister(userId, token, platform);
    }
  }
}

/// Resolves the current platform string for push token registration.
///
/// Returns `'web'`, `'android'`, or `'ios'`.
String _resolvePlatform() {
  if (kIsWeb) return 'web';
  if (Platform.isAndroid) return 'android';
  return 'ios';
}
