import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'chat_provider.dart';
import '../auth/auth_provider.dart';
import '../core/shadow_background.dart';
import 'package:go_router/go_router.dart';

class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedUserIds = {};

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
          title: const Text('New Group', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Consumer2<ChatProvider, AuthProvider>(
            builder: (context, chat, auth, _) {
              final contacts = chat.discoveredContacts.where((c) => c.isOnApp).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Group Name',
                        hintStyle: const TextStyle(color: Colors.white30),
                        prefixIcon: const Icon(LucideIcons.users, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (_selectedUserIds.isNotEmpty) _buildSelectedUsersList(contacts),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ADD MEMBERS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        final isSelected = _selectedUserIds.contains(contact.uid);
                        return _buildMemberTile(contact, isSelected);
                      },
                    ),
                  ),
                  _buildCreateButton(chat, auth),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedUsersList(List<dynamic> contacts) {
    final selectedContacts = contacts.where((c) => _selectedUserIds.contains(c.uid)).toList();
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: selectedContacts.length,
        itemBuilder: (context, index) {
          final c = selectedContacts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white10,
                      backgroundImage: c.avatarUrl != null && c.avatarUrl!.isNotEmpty
                          ? NetworkImage(c.avatarUrl!)
                          : null,
                      child: c.avatarUrl == null || c.avatarUrl!.isEmpty
                          ? Text(c.displayName[0])
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedUserIds.remove(c.uid)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  c.displayName.split(' ')[0],
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberTile(dynamic contact, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.orange.withValues(alpha: 0.3) : Colors.transparent,
          width: 0.5,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedUserIds.remove(contact.uid);
            } else {
              _selectedUserIds.add(contact.uid!);
            }
          });
        },
        leading: CircleAvatar(
          backgroundColor: Colors.white10,
          backgroundImage: contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty
              ? NetworkImage(contact.avatarUrl!)
              : null,
          child: contact.avatarUrl == null || contact.avatarUrl!.isEmpty
              ? Text(contact.displayName[0])
              : null,
        ),
        title: Text(contact.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact.phoneNumber, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isSelected ? Colors.orange : Colors.white24, width: 2),
            color: isSelected ? Colors.orange : Colors.transparent,
          ),
          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
        ),
      ),
    );
  }

  Widget _buildCreateButton(ChatProvider chat, AuthProvider auth) {
    final canCreate = _selectedUserIds.isNotEmpty && _nameController.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canCreate
              ? () async {
                  final participantIds = _selectedUserIds.toList();
                  participantIds.add(auth.currentUser!.id);
                  final groupId = await chat.createGroup(_nameController.text, participantIds);
                  if (groupId != null && mounted) {
                    context.replace('/chat/$groupId');
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: Colors.orange.withValues(alpha: 0.4),
          ),
          child: chat.isLoading
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text('CREATE GROUP', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ),
      ),
    );
  }
}
