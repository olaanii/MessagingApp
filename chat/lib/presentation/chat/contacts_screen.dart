import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/contacts/contacts_permission_state.dart';
import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';
import '../providers/app_providers.dart';
import 'chat_provider.dart';
import 'widgets/contacts_access_prompt.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider).syncContacts();
    });
  }

  Future<void> _onRefresh() async {
    final chat = ref.read(chatNotifierProvider);
    await chat.syncContacts();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatNotifierProvider);
    return ShadowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Contacts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: 'Sync contacts',
              icon: const Icon(LucideIcons.rotateCcw, size: 20),
              onPressed: chat.isLoading ? null : () => chat.syncContacts(),
            ),
          ],
        ),
        body: SafeArea(
          child: ResponsiveBody(
            child: _buildBody(context, chat),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatProvider chat) {
    final perm = chat.contactsPermissionState;

    if (perm == ContactsPermissionState.unsupported) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Contacts are not available in this browser. Use the mobile app to find friends from your address book.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ),
      );
    }

    // Need live provider for prompt buttons — use actual chat from closure.
    if (perm != ContactsPermissionState.granted) {
      return RefreshIndicator(
        color: Colors.orange,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Center(
              child: ContactsAccessPrompt(chat: chat),
            ),
          ),
        ),
      );
    }

    if (chat.error != null &&
        chat.discoveredContacts.isEmpty &&
        !chat.isLoading) {
      return RefreshIndicator(
        color: Colors.orange,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: AppErrorState(
              message: chat.error ?? 'Something went wrong',
              onRetry: () {
                chat.setError(null);
                chat.syncContacts();
              },
            ),
          ),
        ),
      );
    }

    if (chat.isLoading && chat.discoveredContacts.isEmpty) {
      return const AppLoadingState(message: 'Syncing contacts…');
    }

    final discovered = chat.discoveredContacts.where((c) => c.isOnApp).toList();
    final invited = chat.discoveredContacts.where((c) => !c.isOnApp).toList();

    if (discovered.isEmpty && invited.isEmpty) {
      return RefreshIndicator(
        color: Colors.orange,
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
            AppEmptyState(
              title: 'No phone numbers found',
              subtitle:
                  'Add phone numbers to your contacts, or pull down to sync again.',
              icon: LucideIcons.userPlus,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.orange,
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (discovered.isNotEmpty) ...[
            _buildSectionHeader('ON THE APP'),
            ...discovered.map((c) => _buildContactTile(context, c)),
            const SizedBox(height: 24),
          ],
          if (invited.isNotEmpty) ...[
            _buildSectionHeader('INVITE TO APP'),
            ...invited.map(
              (c) => _buildContactTile(context, c, isInvite: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.orange,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    dynamic contact, {
    bool isInvite = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          backgroundImage:
              contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
                  ? NetworkImage(contact.avatarUrl!)
                  : null,
          child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
              ? Text(
                  contact.displayName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          contact.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          contact.phoneNumber,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        trailing: isInvite
            ? TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invite ${contact.displayName} to the app'),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'Share',
                        onPressed: () {
                          // TODO: Implement share functionality
                        },
                      ),
                    ),
                  );
                },
                child: const Text(
                  'INVITE',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              )
            : const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: Colors.white24,
              ),
        onTap: isInvite
            ? null
            : () {
                if (contact.uid != null) {
                  context.push('/chat/${contact.uid}');
                }
              },
      ),
    );
  }
}

