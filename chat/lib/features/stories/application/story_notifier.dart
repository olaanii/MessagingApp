import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/story_model.dart';
import '../../../core/crypto/e2ee_engine.dart';
import '../../../core/device/device_id_service.dart';
import '../../../core/serverpod/serverpod_client_provider.dart';
import '../data/story_repository.dart';

// ── Feed state ────────────────────────────────────────────────────────────────

sealed class StoriesFeedState {
  const StoriesFeedState();
}

class StoriesFeedLoading extends StoriesFeedState {
  const StoriesFeedLoading();
}

class StoriesFeedLoaded extends StoriesFeedState {
  const StoriesFeedLoaded(this.feedItems, this.myStories);
  final List<StoryFeedItem> feedItems;
  final List<StoryModel> myStories;
}

class StoriesFeedError extends StoriesFeedState {
  const StoriesFeedError(this.message);
  final String message;
}

// ── StoryNotifier ─────────────────────────────────────────────────────────────

class StoryNotifier extends AsyncNotifier<StoriesFeedState> {
  StoryRepository? _repo;

  @override
  FutureOr<StoriesFeedState> build() async {
    final client = ref.watch(serverpodClientProvider);
    final deviceIdService = ref.watch(deviceIdServiceProvider);
    _repo = ServerpodStoryRepository(
      client: client,
      deviceIdService: deviceIdService,
      crypto: E2eeEngine(),
    );
    return const StoriesFeedLoading();
  }

  /// Fetch the stories feed from the server.
  Future<void> loadStories() async {
    state = const AsyncLoading();
    try {
      final repo = _repo!;
      final stories = await repo.listStories();

      // Separate "my" stories from others
      final myId = await ref.read(deviceIdServiceProvider).getDeviceId();
      final myStories =
          stories.where((s) => s.authorId == myId).toList();
      final othersStories =
          stories.where((s) => s.authorId != myId).toList();

      // Group by author
      final grouped = <String, List<StoryModel>>{};
      for (final s in othersStories) {
        grouped.putIfAbsent(s.authorId, () => []).add(s);
      }

      final feedItems = grouped.entries.map((e) {
        final authorStories = e.value;
        return StoryFeedItem(
          authorId: e.key,
          authorName: authorStories.first.authorName.isEmpty
              ? 'User ${e.key.substring(0, 8)}'
              : authorStories.first.authorName,
          authorAvatarUrl: authorStories.first.authorAvatarUrl,
          stories: authorStories,
        );
      }).toList();

      // Sort by latest story first
      feedItems.sort(
        (a, b) => b.latestTimestamp.compareTo(a.latestTimestamp),
      );

      state = AsyncData(StoriesFeedLoaded(feedItems, myStories));
    } catch (e) {
      state = AsyncError(StoriesFeedError(e.toString()), StackTrace.current);
    }
  }

  /// Create a new story.
  Future<void> createStory({
    required String mediaType,
    required String content,
    String? thumbnailData,
    String privacy = 'all_users',
    List<String>? selectedViewerIds,
  }) async {
    final current = state.value;
    try {
      final repo = _repo!;
      await repo.createStory(
        mediaType: mediaType,
        content: content,
        thumbnailData: thumbnailData,
        privacy: privacy,
        selectedViewerIds: selectedViewerIds,
      );
      // Reload after creating
      await loadStories();
    } catch (e) {
      state = AsyncError(StoriesFeedError(e.toString()), StackTrace.current);
    }
  }

  /// Mark a story as viewed.
  Future<void> viewStory(String storyId) async {
    try {
      final repo = _repo!;
      await repo.viewStory(storyId);
    } catch (_) {
      // Non-critical; silently ignore.
    }
  }

  /// Delete a story (author only).
  Future<void> deleteStory(String storyId) async {
    final current = state.value;
    try {
      final repo = _repo!;
      await repo.deleteStory(storyId);
      await loadStories();
    } catch (e) {
      state = AsyncError(StoriesFeedError(e.toString()), StackTrace.current);
    }
  }
}

final storyNotifierProvider =
    AsyncNotifierProvider.autoDispose<StoryNotifier, StoriesFeedState>(
  StoryNotifier.new,
);
