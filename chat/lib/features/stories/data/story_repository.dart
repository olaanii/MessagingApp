import 'dart:convert';

import 'package:chat_client/chat_client.dart';

import '../../../core/crypto/e2ee_engine.dart';
import '../../../core/device/device_id_service.dart';
import '../../../domain/models/story_model.dart';

/// Repository for stories / posts CRUD (Serverpod-backed).
///
/// Requirements: 7.1, 7.4, 7.5, 7.9
abstract class StoryRepository {
  Future<List<StoryModel>> listStories({String? forUserId});
  Future<StoryModel> createStory({
    required String mediaType,
    required String content,
    String? thumbnailData,
    String privacy,
    List<String>? selectedViewerIds,
  });
  Future<void> viewStory(String storyId);
  Future<List<String>> getViewers(String storyId);
  Future<void> deleteStory(String storyId);
}

/// Serverpod-backed [StoryRepository].
class ServerpodStoryRepository implements StoryRepository {
  ServerpodStoryRepository({
    required this.client,
    required this.deviceIdService,
    required this.crypto,
  });

  final Client client;
  final DeviceIdService deviceIdService;
  final E2eeEngine crypto;

  @override
  Future<List<StoryModel>> listStories({String? forUserId}) async {
    final result = await client.story.listStories(
      forAuthUserId: forUserId,
      limit: 50,
    );
    return result.map((s) => _mapServerStory(s)).toList();
  }

  @override
  Future<StoryModel> createStory({
    required String mediaType,
    required String content,
    String? thumbnailData,
    String privacy = 'all_contacts',
    List<String>? selectedViewerIds,
  }) async {
    // Encrypt the story content via E2EE module (the server never sees plaintext).
    final encryptedPayload = await _encryptContent(content);
    final nonce = _generateNonce();

    String? encryptedThumbnail;
    if (thumbnailData != null) {
      encryptedThumbnail = await _encryptContent(thumbnailData);
    }

    final result = await client.story.createStory(
      mediaType: mediaType,
      encryptedPayload: encryptedPayload,
      nonce: nonce,
      thumbnailCiphertext: encryptedThumbnail,
      privacy: privacy,
      selectedViewerIds: selectedViewerIds?.join(','),
    );

    return _mapServerStory(result);
  }

  @override
  Future<void> viewStory(String storyId) async {
    await client.story.viewStory(storyId: storyId);
  }

  @override
  Future<List<String>> getViewers(String storyId) async {
    return await client.story.getViewers(storyId: storyId);
  }

  @override
  Future<void> deleteStory(String storyId) async {
    await client.story.deleteStory(storyId: storyId);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<String> _encryptContent(String plaintext) async {
    // Use the existing E2eeEngine for content encryption.
    // The key is derived from the story author's identity key.
    final deviceId = await deviceIdService.getDeviceId();
    return crypto.encrypt(
      plaintext: plaintext,
      recipientDeviceId: deviceId,
    );
  }

  String _generateNonce() {
    final bytes = List<int>.generate(24, (_) => DateTime.now().microsecond % 256);
    return base64Encode(bytes);
  }

  StoryModel _mapServerStory(dynamic s) {
    // Map from the Story model returned by Serverpod client.
    return StoryModel(
      id: s.id.uuid,
      authorId: s.authorAuthUserId.uuid,
      authorName: '',
      authorAvatarUrl: '',
      mediaType: s.mediaType,
      encryptedPayload: s.encryptedPayload,
      nonce: s.nonce,
      thumbnailCiphertext: s.thumbnailCiphertext,
      privacy: s.privacy,
      expiresAt: s.expiresAt,
      createdAt: s.createdAt,
    );
  }
}
