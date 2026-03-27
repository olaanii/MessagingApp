import 'package:firebase_messaging/firebase_messaging.dart';

/// Data keys the **server** should include on FCM payloads for deep links.
///
/// Align with Serverpod / Admin FCM send: use one of these in the `data` map
/// (not only `notification`, so taps work in background/terminated).
abstract final class FcmDataKeys {
  static const chatId = 'chatId';
  static const chatIdSnake = 'chat_id';
}

String? parseChatIdFromRemoteMessage(RemoteMessage message) {
  final data = message.data;
  final raw = data[FcmDataKeys.chatId] ?? data[FcmDataKeys.chatIdSnake];
  if (raw is String && raw.isNotEmpty) {
    return raw;
  }
  return null;
}
