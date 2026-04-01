import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';
import '../core/widgets.dart';

class LockChatScreen extends StatefulWidget {
  const LockChatScreen({super.key});

  @override
  State<LockChatScreen> createState() => _LockChatScreenState();
}

class _LockChatScreenState extends State<LockChatScreen> {
  bool _lockEnabled = false;
  bool _useBiometric = false;
  bool _lockOnExit = true;

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
          title: const Text('Lock Chat'),
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
                        'App lock',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure your chats with a PIN or biometric authentication',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildSwitchTile(
                        'Enable lock',
                        'Require authentication to open the app',
                        _lockEnabled,
                        (v) => setState(() => _lockEnabled = v),
                      ),
                      if (_lockEnabled) ...[
                        _buildSwitchTile(
                          'Use biometric',
                          'Use fingerprint or face recognition',
                          _useBiometric,
                          (v) => setState(() => _useBiometric = v),
                        ),
                        _buildSwitchTile(
                          'Lock on exit',
                          'Lock immediately when app is closed',
                          _lockOnExit,
                          (v) => setState(() => _lockOnExit = v),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_lockEnabled) ...[
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change PIN',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update your security PIN',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PIN change coming soon'),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.lock),
                          label: const Text('Change PIN'),
                        ),
                      ],
                    ),
                  ),
                ],
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
