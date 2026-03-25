class MessageModel {
  final String id;
  final String? chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final String status; // 'sent', 'delivered', 'read'
  final bool isOffline;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.status = 'sent',
    this.isOffline = false,
    this.chatId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'sent',
      isOffline: json['isOffline'] as bool? ?? false,
      chatId: json['chatId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'isOffline': isOffline,
      'chatId': chatId,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    String? imageUrl,
    DateTime? timestamp,
    String? status,
    bool? isOffline,
    String? chatId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isOffline: isOffline ?? this.isOffline,
      chatId: chatId ?? this.chatId,
    );
  }
}
