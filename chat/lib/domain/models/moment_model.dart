class MomentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String imageUrl;
  final DateTime timestamp;
  final bool isMe;

  MomentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.imageUrl,
    required this.timestamp,
    this.isMe = false,
  });

  factory MomentModel.fromJson(Map<String, dynamic> json) {
    return MomentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userImageUrl: json['userImageUrl'] as String?,
      imageUrl: json['imageUrl'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
