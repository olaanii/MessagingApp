import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'fcm_message_payload.dart';

/// Registered from [main] **before** [runApp]. Runs in a background isolate.
///
/// Keep this function lightweight: no UI, no [GoRouter]. Prefer persisting
/// or logging only; full navigation happens via [getInitialMessage] /
/// [onMessageOpenedApp] on the main isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint(
      'FCM background: id=${message.messageId} '
      'chatId=${parseChatIdFromRemoteMessage(message)}',
    );
  }
}
