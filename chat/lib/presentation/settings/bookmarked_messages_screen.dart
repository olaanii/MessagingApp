import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';

class BookmarkedMessagesScreen extends StatelessWidget {
  const BookmarkedMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () => context.pop(),
          ),
          title: const Text('Bookmarked'),
        ),
        body: SafeArea(
          child: ResponsiveBody(
            child: Center(
              child: AppEmptyState(
                title: 'No bookmarked messages',
                subtitle: 'Bookmark important messages to find them easily later',
                icon: LucideIcons.bookmark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
