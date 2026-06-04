import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:go_router/go_router.dart';

import '../../domain/models/story_model.dart';
import '../../features/stories/application/story_notifier.dart';
import 'story_viewer_screen.dart';

/// Horizontal stories feed widget that replaces the old "moments" section.
///
/// Requirements: 7.4, 7.10
class StoriesFeedWidget extends ConsumerWidget {
  const StoriesFeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storyNotifierProvider);

    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _itemCount(storiesAsync) + 1, // +1 for "add story" button
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              children: [
                _buildAddStoryTile(context),
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ],
            );
          }

          final storiesFeed = storiesAsync.value;
          if (storiesFeed is StoriesFeedLoaded) {
            final feedItems = storiesFeed.feedItems;
            final actualIndex = index - 1;
            if (actualIndex < feedItems.length) {
              return _buildStoryThumbnail(context, ref, feedItems[actualIndex]);
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  int _itemCount(AsyncValue<StoriesFeedState> storiesAsync) {
    final feed = storiesAsync.value;
    if (feed is StoriesFeedLoaded) return feed.feedItems.length;
    return 0;
  }

  Widget _buildAddStoryTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () => _navigateToComposer(context),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[900],
                ),
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white60,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Story',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryThumbnail(
    BuildContext context,
    WidgetRef ref,
    StoryFeedItem feedItem,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          // Find first unviewed story index, or default to 0
          int initialIdx = 0;
          for (int i = 0; i < feedItem.stories.length; i++) {
            if (!feedItem.stories[i].isViewed) {
              initialIdx = i;
              break;
            }
          }
          _navigateToViewer(context, feedItem, initialIdx);
        },
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: feedItem.hasUnviewed
                          ? Colors.orange.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: feedItem.authorAvatarUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(feedItem.authorAvatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[900],
                    ),
                    child: feedItem.authorAvatarUrl.isEmpty
                        ? Center(
                            child: Text(
                              feedItem.authorName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 20,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _truncate(feedItem.authorName, 8),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToComposer(BuildContext context) {
    context.push('/stories/compose');
  }

  void _navigateToViewer(
    BuildContext context,
    StoryFeedItem feedItem,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(
          feedItem: feedItem,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  String _truncate(String s, int maxLen) =>
      s.length > maxLen ? '${s.substring(0, maxLen)}…' : s;
}
