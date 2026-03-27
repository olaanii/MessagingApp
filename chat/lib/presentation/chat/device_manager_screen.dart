import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';
import '../core/widgets.dart';

/// Signed-in device list and session management (API wiring comes with Serverpod).
class DeviceManagerScreen extends StatelessWidget {
  const DeviceManagerScreen({super.key});

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
          title: const Text('Devices'),
        ),
        body: SafeArea(
          child: ResponsiveBody(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Where you’re signed in',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Review linked devices and sign out remotely when Serverpod session APIs are enabled.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                GlassCard(
                  child: Semantics(
                    label: 'This device, active session',
                    child: const ListTile(
                      leading: Icon(LucideIcons.smartphone),
                      title: Text('This device'),
                      subtitle: Text('Active · current session'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: ListTile(
                    leading: const Icon(LucideIcons.monitor, color: Colors.white54),
                    title: Text(
                      'Other sessions',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    subtitle: const Text(
                      'No other devices yet — server sync pending.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
