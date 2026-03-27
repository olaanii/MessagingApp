import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/contacts/contacts_permission_state.dart';
import '../chat_provider.dart';

/// Shown before the system contacts dialog so users understand why access is requested.
class ContactsAccessPrompt extends StatelessWidget {
  const ContactsAccessPrompt({
    super.key,
    required this.chat,
    this.compact = false,
  });

  final ChatProvider chat;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = chat.contactsPermissionState;
    final theme = Theme.of(context);

    if (state == ContactsPermissionState.unsupported) {
      return Padding(
        padding: EdgeInsets.all(compact ? 16 : 24),
        child: Text(
          'Contacts are not available in this browser. Use the mobile app to find friends from your address book.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
          ),
        ),
      );
    }

    final title = state == ContactsPermissionState.permanentlyDenied
        ? 'Contacts access is off'
        : 'Find people you know';
    final body = state == ContactsPermissionState.permanentlyDenied
        ? 'To start chats or add group members from your address book, enable Contacts for this app in Settings.'
        : 'Allow access to your contacts to see who is already here and invite others. '
            'We only read names and phone numbers on your device to match accounts; '
            'nothing is uploaded as a contact list.';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: compact ? 12 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.contact,
            size: compact ? 40 : 56,
            color: Colors.orange.withValues(alpha: 0.9),
          ),
          SizedBox(height: compact ? 12 : 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          SizedBox(height: compact ? 16 : 28),
          if (state == ContactsPermissionState.permanentlyDenied) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: chat.isLoading
                    ? null
                    : () => chat.openContactsPermissionSettings(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Open Settings'),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: chat.isLoading
                    ? null
                    : () => chat.requestContactsAccessAndSync(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                child: chat.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Allow contacts access'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
