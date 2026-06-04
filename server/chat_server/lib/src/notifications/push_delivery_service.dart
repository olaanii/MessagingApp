import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/messaging.dart';
import 'package:serverpod/serverpod.dart';

/// Sends privacy-safe push notifications to chat recipients.
///
/// Uses application-default credentials so deployments can provide a service
/// account via `GOOGLE_APPLICATION_CREDENTIALS`.
final class PushDeliveryService {
  PushDeliveryService._();

  static final PushDeliveryService instance = PushDeliveryService._();

  FirebaseAdminApp? _app;
  Messaging? _messaging;

  Future<void> notifyNewMessage({
    required Session session,
    required String chatId,
    required String senderAuthUserId,
    required String messageId,
  }) async {
    try {
      final recipientTokens = await _loadRecipientTokens(
        session,
        chatId: chatId,
        senderAuthUserId: senderAuthUserId,
      );
      if (recipientTokens.isEmpty) {
        return;
      }

      final messaging = await _messagingClient();
      for (final token in recipientTokens) {
        try {
          await messaging.send(
            TokenMessage(
              token: token,
              notification: Notification(
                title: 'New message',
                body: 'Open the chat to read it.',
              ),
              data: <String, String>{
                'type': 'message',
                'chatId': chatId,
                'senderId': senderAuthUserId,
                'messageId': messageId,
              },
            ),
          );
        } catch (e, st) {
          session.log('push delivery failed for token=$token: $e\n$st');
        }
      }
    } catch (e, st) {
      session.log('push fan-out error: $e\n$st');
    }
  }

  Future<Messaging> _messagingClient() async {
    _app ??= FirebaseAdminApp.initializeApp(
      'chat-server',
      Credential.fromApplicationDefaultCredentials(),
    );
    _messaging ??= Messaging(_app!);
    return _messaging!;
  }

  Future<List<String>> _loadRecipientTokens(
    Session session, {
    required String chatId,
    required String senderAuthUserId,
  }) async {
    final rows = await session.db.unsafeQuery(
      'SELECT DISTINCT pt.token '
      'FROM push_tokens pt '
      'JOIN chat_member cm ON cm."memberAuthUserId" = pt."authUserId" '
      'WHERE cm."chatId" = @chatId::uuid '
      'AND pt.token IS NOT NULL '
      "AND pt.token <> '' "
      'AND pt."authUserId" <> @sender::uuid',
      parameters: QueryParameters.named({
        'chatId': chatId,
        'sender': senderAuthUserId,
      }),
    );
    return rows
        .map((row) => row[0] as String)
        .where((token) => token.trim().isNotEmpty)
        .toList();
  }
}
