import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'chat_provider.dart';
import '../core/shadow_background.dart';
import 'package:go_router/go_router.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).syncContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(LucideIcons.rotateCcw, size: 20),
              onPressed: () => Provider.of<ChatProvider>(context, listen: false).syncContacts(),
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<ChatProvider>(
            builder: (context, chat, _) {
              if (chat.isLoading && chat.discoveredContacts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final discovered = chat.discoveredContacts.where((c) => c.isOnApp).toList();
              final invited = chat.discoveredContacts.where((c) => !c.isOnApp).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (discovered.isNotEmpty) ...[
                    _buildSectionHeader('ON THE APP'),
                    ...discovered.map((c) => _buildContactTile(context, c)),
                    const SizedBox(height: 24),
                  ],
                  if (invited.isNotEmpty) ...[
                    _buildSectionHeader('INVITE TO APP'),
                    ...invited.map((c) => _buildContactTile(context, c, isInvite: true)),
                  ],
                  if (discovered.isEmpty && invited.isEmpty && !chat.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No contacts found. Make sure you have granted permission.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
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

  Widget _buildContactTile(BuildContext context, dynamic contact, {bool isInvite = false}) {
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
          backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
              ? NetworkImage(contact.avatarUrl!)
              : null,
          child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
              ? Text(
                  contact.displayName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          contact.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          contact.phoneNumber,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
        ),
        trailing: isInvite
            ? TextButton(
                onPressed: () {}, // Implement share/invite logic
                child: const Text('INVITE', style: TextStyle(color: Colors.orange, fontSize: 12)),
              )
            : const Icon(LucideIcons.chevronRight, size: 18, color: Colors.white24),
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
