import 'package:uuid/uuid.dart';

/// Ephemeral story model (client-side representation).
///
/// The server stores `encryptedPayload` + `nonce`; the client decrypts
/// via [E2eeEngine] after download.
class StoryModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String mediaType; // "image", "video", "text"
  final String encryptedPayload;
  final String nonce;
  final String? thumbnailCiphertext;
  final String privacy; // "all_contacts", "selected", "public"
  final DateTime expiresAt;
  final DateTime createdAt;
  bool isViewed;
  int viewCount;

  StoryModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.mediaType,
    required this.encryptedPayload,
    required this.nonce,
    this.thumbnailCiphertext,
    this.privacy = 'all_contacts',
    required this.expiresAt,
    required this.createdAt,
    this.isViewed = false,
    this.viewCount = 0,
  });

  factory StoryModel.fromServerJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      authorId: json['authorId'] as String? ?? json['authorAuthUserId'] as String,
      authorName: json['authorName'] as String? ?? 'Unknown',
      authorAvatarUrl: json['authorAvatarUrl'] as String? ?? '',
      mediaType: json['mediaType'] as String,
      encryptedPayload: json['encryptedPayload'] as String,
      nonce: json['nonce'] as String,
      thumbnailCiphertext: json['thumbnailCiphertext'] as String?,
      privacy: json['privacy'] as String? ?? 'all_contacts',
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatarUrl': authorAvatarUrl,
        'mediaType': mediaType,
        'encryptedPayload': encryptedPayload,
        'nonce': nonce,
        'thumbnailCiphertext': thumbnailCiphertext,
        'privacy': privacy,
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  bool get expired => DateTime.now().toUtc().isAfter(expiresAt);

  bool get isMe => false; // Set by the notifier based on auth user ID

  StoryModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? mediaType,
    String? encryptedPayload,
    String? nonce,
    String? thumbnailCiphertext,
    String? privacy,
    DateTime? expiresAt,
    DateTime? createdAt,
    bool? isViewed,
    int? viewCount,
  }) {
    return StoryModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      mediaType: mediaType ?? this.mediaType,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      nonce: nonce ?? this.nonce,
      thumbnailCiphertext: thumbnailCiphertext ?? this.thumbnailCiphertext,
      privacy: privacy ?? this.privacy,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      isViewed: isViewed ?? this.isViewed,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}

/// Aggregated stories feed – groups stories by author.
class StoryFeedItem {
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final List<StoryModel> stories;
  bool get hasUnviewed => stories.any((s) => !s.isViewed);
  DateTime get latestTimestamp =>
      stories.map((s) => s.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);

  const StoryFeedItem({
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.stories,
  });
}
