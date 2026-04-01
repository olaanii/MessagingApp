import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';
import '../core/widgets.dart';

class MediaVisibilityScreen extends StatefulWidget {
  const MediaVisibilityScreen({super.key});

  @override
  State<MediaVisibilityScreen> createState() => _MediaVisibilityScreenState();
}

class _MediaVisibilityScreenState extends State<MediaVisibilityScreen> {
  bool _showMediaInGallery = true;
  bool _autoDownloadPhotos = true;
  bool _autoDownloadVideos = false;
  bool _autoDownloadDocuments = false;

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
          title: const Text('Media visibility'),
        ),
        body: SafeArea(
          child: ResponsiveBody(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media visibility',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Control whether media from chats appears in your device gallery',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildSwitchTile(
                        'Show media in gallery',
                        'Media will be visible in your device gallery',
                        _showMediaInGallery,
                        (v) => setState(() => _showMediaInGallery = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-download',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Automatically download media when connected to WiFi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildSwitchTile(
                        'Photos',
                        'Auto-download photos',
                        _autoDownloadPhotos,
                        (v) => setState(() => _autoDownloadPhotos = v),
                      ),
                      _buildSwitchTile(
                        'Videos',
                        'Auto-download videos',
                        _autoDownloadVideos,
                        (v) => setState(() => _autoDownloadVideos = v),
                      ),
                      _buildSwitchTile(
                        'Documents',
                        'Auto-download documents',
                        _autoDownloadDocuments,
                        (v) => setState(() => _autoDownloadDocuments = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.orange.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
