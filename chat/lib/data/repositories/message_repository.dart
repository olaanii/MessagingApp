import '../../domain/models/message_model.dart';

/// Chat thread persistence — encrypt/decrypt stays outside this interface (E2EE ADR).
abstract class MessageRepository {
  Stream<List<MessageModel>> watchMessagesForChat(
    String chatId, {
    int limit = 200,
  });

  Future<void> upsertLocalMessage(
    MessageModel message, {
    required String effectiveChatId,
    String? clientMsgId,
    int? serverSeq,
  });

  Future<void> tombstoneMessage(String messageId, DateTime deletedAt);

  /// Idempotent apply of a server page (cursor/sync ADR).
  /// When Serverpod rows include `server_seq`, extend the domain DTO or map before calling [upsertLocalMessage].
  Future<void> mergeServerMessages(String chatId, List<MessageModel> messages);
}
