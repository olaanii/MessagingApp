import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';
import '../core/widgets.dart';

/// Backup / restore entry point (E2EE key backup will plug in here).
class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

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
          title: const Text('Backup & restore'),
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
                        'Encrypted backup',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MVP will export recovery material for your keys using the crypto module; '
                        'nothing is uploaded until you confirm.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Backup flow not wired yet.'),
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.upload),
                        label: const Text('Back up'),
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
                        'Restore',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Restore from a file or recovery phrase after E2EE recovery ships.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Restore flow not wired yet.'),
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.download),
                        label: const Text('Restore'),
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
}
