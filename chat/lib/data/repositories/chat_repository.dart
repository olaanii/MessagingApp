import '../../domain/models/chat_summary.dart';

/// Local inbox mirror — implemented with Drift (`AppDatabase`).
abstract class ChatRepository {
  Stream<List<ChatSummary>> watchChatsOrdered();

  Future<void> upsertChat(
    ChatSummary chat, {
    required DateTime updatedAt,
  });

  Future<void> deleteChat(String id);
}
