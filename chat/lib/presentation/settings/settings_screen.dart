import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../auth/auth_provider.dart';
import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';
import '../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.currentUser;

    return ShadowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _buildCircularAction(
              context,
              LucideIcons.chevronLeft,
              onPressed: () => context.pop(),
              tooltip: 'Back',
            ),
          ),
          actions: [
            _buildCircularAction(context, LucideIcons.moreHorizontal),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: ResponsiveBody(
            maxWidth: 640,
            child: auth.isLoading && user == null
                ? const AppLoadingState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      children: [
                        _buildProfileHeader(
                          user?.name ?? 'Khadija Dubois',
                          user?.avatarUrl,
                        ),
                        const SizedBox(height: 32),
                        _buildStatsRow(),
                        const SizedBox(height: 32),
                        _buildMediaSection(context),
                        const SizedBox(height: 32),
                        _buildSettingsList(context, ref, auth),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularAction(
    BuildContext context,
    IconData icon, {
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 20, color: Colors.white),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  Widget _buildProfileHeader(String name, String? avatarUrl) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10, width: 1),
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: Colors.grey[900],
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : const NetworkImage('https://picsum.photos/200'),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '+12-6541-1234',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(label: 'MESSAGE', value: '12,145'),
          _StatColumn(label: 'GROUP', value: '94'),
          _StatColumn(label: 'SPACES', value: '48'),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Media and photos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(child: _buildMediaCell(LucideIcons.image)),
              Expanded(child: _buildMediaCell(LucideIcons.bookOpen)),
              Expanded(child: _buildMediaCell(LucideIcons.treePine)),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(24),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '+42',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaCell(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.1), size: 32),
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    WidgetRef ref,
    AuthProvider auth,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          _buildSimplifiedTile(
            LucideIcons.search,
            'Search chats',
            onPressed: () => context.push('/search'),
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.smartphone,
            'Devices',
            onPressed: () => context.push('/settings/devices'),
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.database,
            'Backup & restore',
            onPressed: () => context.push('/settings/backup'),
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.shieldAlert,
            'Safety: report & block',
            subtitle: 'Uses More menu inside a chat for now.',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Report or block'),
                  content: const Text(
                    'Open a conversation, tap ···, then choose Block or Report. '
                    'Server-backed moderation arrives with Serverpod.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.bell,
            'Notification',
            onPressed: () => context.push('/settings/notifications'),
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.image,
            'Media visibility',
            onPressed: () => context.push('/settings/media-visibility'),
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.bookmark,
            'Bookmarked',
            onPressed: () => context.push('/settings/bookmarked'),
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.lock,
            'Lock Chat',
            trailing: Switch(
              value: false,
              onChanged: (v) {
                if (v) {
                  context.push('/settings/lock-chat');
                }
              },
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.white24,
            ),
            onPressed: () => context.push('/settings/lock-chat'),
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.logOut,
            'Logout',
            color: Colors.redAccent,
            onPressed: () {
              ref.read(authNotifierProvider).logOut();
              ref.read(chatNotifierProvider).reset();
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }

  Widget _buildSimplifiedTile(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            LucideIcons.chevronRight,
            color: Colors.white.withValues(alpha: 0.2),
            size: 20,
          ),
      onTap: onPressed ?? () {},
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.3),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
