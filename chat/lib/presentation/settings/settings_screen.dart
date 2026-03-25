import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../chat/chat_provider.dart';
import '../core/shadow_background.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _buildCircularAction(
              LucideIcons.chevronLeft,
              onPressed: () => context.pop(),
            ),
          ),
          actions: [
            _buildCircularAction(LucideIcons.moreHorizontal),
            const SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final user = auth.currentUser;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  children: [
                    _buildProfileHeader(user?.name ?? 'Khadija Dubois', user?.avatarUrl),
                    const SizedBox(height: 32),
                    _buildStatsRow(),
                    const SizedBox(height: 32),
                    _buildMediaSection(context),
                    const SizedBox(height: 32),
                    _buildSettingsList(context, auth),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircularAction(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
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
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.1),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          _buildSimplifiedTile(LucideIcons.bell, 'Notification'),
          _divider(),
          _buildSimplifiedTile(LucideIcons.image, 'Media visibility'),
          _divider(),
          _buildSimplifiedTile(LucideIcons.bookmark, 'Bookmarked'),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.lock,
            'Lock Chat',
            trailing: Switch(
              value: false,
              onChanged: (v) {},
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.white24,
            ),
          ),
          _divider(),
          _buildSimplifiedTile(
            LucideIcons.logOut,
            'Logout',
            color: Colors.redAccent,
            onPressed: () {
              auth.logOut();
              Provider.of<ChatProvider>(context, listen: false).reset();
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

  Widget _buildSimplifiedTile(IconData icon, String title, {Widget? trailing, Color? color, VoidCallback? onPressed}) {
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
