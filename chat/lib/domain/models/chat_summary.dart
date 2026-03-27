/// Inbox row shown in the chat list — pure Dart, no persistence imports.
class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.type,
    this.title,
    this.lastPreview,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final String type;
  final String? title;
  final String? lastPreview;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatSummary copyWith({
    String? id,
    String? type,
    String? title,
    String? lastPreview,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return ChatSummary(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      lastPreview: lastPreview ?? this.lastPreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
