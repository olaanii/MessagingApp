import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../domain/models/story_model.dart';
import '../../features/stories/application/story_notifier.dart';

/// Full-screen story viewer with swipe navigation between stories.
///
/// Requirements: 7.4, 7.5, 7.10
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.feedItem,
    required this.initialIndex,
  });

  final StoryFeedItem feedItem;
  final int initialIndex;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _progressTimer;
  double _progress = 0;
  static const Duration _storyDisplayDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.feedItem.stories.length - 1,
    );
    _pageController = PageController(initialPage: _currentIndex);
    _startProgressTimer();
    _markViewed();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startProgressTimer() {
    _progress = 0;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) {
        setState(() {
          _progress += 0.05 / _storyDisplayDuration.inSeconds;
          if (_progress >= 1.0) {
            _progress = 1.0;
            _progressTimer?.cancel();
            _nextStory();
          }
        });
      },
    );
  }

  void _markViewed() {
    final story = widget.feedItem.stories[_currentIndex];
    if (!story.isViewed) {
      ref.read(storyNotifierProvider.notifier).viewStory(story.id);
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.feedItem.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last story – close viewer
      if (mounted) context.pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stories = widget.feedItem.stories;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story content
          GestureDetector(
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 2) {
                _previousStory();
              } else {
                _nextStory();
              }
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: stories.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _startProgressTimer();
                _markViewed();
              },
              itemBuilder: (context, index) {
                final story = stories[index];
                return _buildStoryContent(story);
              },
            ),
          ),

          // Progress indicators
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: List.generate(
                stories.length,
                (i) => Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: LinearProgressIndicator(
                      value: i < _currentIndex
                          ? 1.0
                          : i == _currentIndex
                              ? _progress
                              : 0.0,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 8,
            right: 8,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[800],
                  backgroundImage:
                      widget.feedItem.authorAvatarUrl.isNotEmpty
                          ? NetworkImage(widget.feedItem.authorAvatarUrl)
                          : null,
                  child: widget.feedItem.authorAvatarUrl.isEmpty
                      ? Text(
                          widget.feedItem.authorName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.feedItem.authorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatTime(stories[_currentIndex].createdAt),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),

          // Swipe area indicators (transparent taps)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _previousStory,
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextStory,
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(StoryModel story) {
    if (story.mediaType == 'text') {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Text(
            'Text story\n(Encrypted – decrypt on device)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          LucideIcons.image,
          color: Colors.white24,
          size: 80,
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}';
  }
}
