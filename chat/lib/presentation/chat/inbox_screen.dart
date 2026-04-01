import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';
import '../providers/app_providers.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  int _selectedFilterIndex = 0;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authNotifierProvider);
      if (auth.currentUser != null) {
        final chat = ref.read(chatNotifierProvider);
        chat.listenToRecentChats(auth.currentUser!.id);
        chat.listenToMoments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShadowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: _buildAppBar(),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildMomentsSection(),
              _buildRecentChatsFilter(),
              Expanded(
                child: ResponsiveBody(
                  maxWidth: 720,
                  child: _buildChatList(),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Chats',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
        ),
      ),
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      actions: [
        _buildCircularAction(
          LucideIcons.search,
          onPressed: () => context.push('/search'),
          tooltip: 'Search chats',
        ),
        const SizedBox(width: 8),
        _buildCircularAction(
          LucideIcons.users,
          onPressed: () => context.push('/contacts'),
          tooltip: 'Contacts',
        ),
        const SizedBox(width: 8),
        _buildCircularAction(
          LucideIcons.moreVertical,
          onPressed: () => context.push('/settings'),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildCircularAction(
    IconData icon, {
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 20, color: Colors.white),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  Widget _buildMomentsSection() {
    final chat = ref.watch(chatNotifierProvider);
    final moments = chat.moments;
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: moments.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              children: [
                _buildMomentItem('You', null, isMe: true),
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ],
            );
          }
          final moment = moments[index - 1];
          return _buildMomentItem(
            moment.userName,
            moment.userImageUrl,
            statusCount: 1, // Simplified for MVP
          );
        },
      ),
    );
  }

  Widget _buildMomentItem(
    String name,
    String? imageUrl, {
    bool isMe = false,
    int? statusCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: isMe ? _showAddStoryOptions : null,
        child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[900],
                  ),
                  child: isMe
                      ? const Icon(
                          LucideIcons.plus,
                          color: Colors.white60,
                          size: 24,
                        )
                      : null,
                ),
              ),
              if (statusCount != null)
                Positioned(
                  right: 4,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      statusCount.toString(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showAddStoryOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera, color: Colors.white),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: Colors.white),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.type, color: Colors.white),
              title: const Text('Text Status', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text status feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChatsFilter() {
    final filters = ['All', 'Favorites', 'Work', 'Groups', 'Communities'];
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isActive = index == _selectedFilterIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF4A4A4A)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList() {
    final chat = ref.watch(chatNotifierProvider);
    final auth = ref.watch(authNotifierProvider);
    final chats = chat.recentChats;

    if (chat.error != null && chats.isEmpty && !chat.isLoading) {
      return AppErrorState(
        message: chat.error!,
        onRetry: () {
          chat.setError(null);
          final uid = auth.currentUser?.id;
          if (uid != null) chat.listenToRecentChats(uid);
        },
      );
    }

    if (chat.isLoading && chats.isEmpty) {
      return const AppLoadingState(message: 'Loading chats…');
    }

    if (chats.isEmpty) {
      return AppEmptyState(
        title: 'No chats yet',
        subtitle: 'Start a conversation from the + button',
        icon: LucideIcons.messageSquare,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: chats.length,
      itemBuilder: (context, index) {
            final chatData = chats[index];
            final isPinned = index == 0;
            final unreadCount = index == 0 ? 4 : (index == 4 ? 2 : null);

            final idStr = chatData['id'].toString();
            final shortId = idStr.length > 4 ? idStr.substring(0, 4) : idStr;
            final title = chatData['name'] ?? 'User $shortId';
            final preview =
                (chatData['lastMessage'] ?? 'No messages yet').toString();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Semantics(
                button: true,
                label: 'Chat with $title. $preview',
                child: InkWell(
                  onTap: () => context.push('/chat/${chatData['id']}'),
                  child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: NetworkImage('https://picsum.photos/200'),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.white10,
                              width: 0.5,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          chatData['lastMessageTimestamp'] != null
                              ? _formatTimestamp(
                                  chatData['lastMessageTimestamp'],
                                )
                              : '24 mins',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (isPinned)
                              Icon(
                                LucideIcons.pin,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            if (isPinned) const SizedBox(width: 6),
                            if (unreadCount != null)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
            );
      },
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavItem(
                    LucideIcons.messageSquare,
                    'Chats',
                    _selectedNavIndex == 0,
                    hasNotification: true,
                    onPressed: () => setState(() => _selectedNavIndex = 0),
                  ),
                  const SizedBox(width: 20),
                  _buildNavItem(
                    LucideIcons.phone,
                    'Call',
                    _selectedNavIndex == 1,
                    onPressed: () {
                      setState(() => _selectedNavIndex = 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calls feature coming soon')),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildNavItem(
                    LucideIcons.aperture,
                    'Updates',
                    _selectedNavIndex == 2,
                    onPressed: () {
                      setState(() => _selectedNavIndex = 2);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Updates feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _showNewChatDialog(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChatDialog() {
    final TextEditingController idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter User ID or Phone Number to start a conversation.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                hintText: 'Recipient ID',
                hintStyle: TextStyle(color: Colors.white30),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (idController.text.isNotEmpty) {
                Navigator.pop(context);
                context.push('/chat/${idController.text}');
              }
            },
            child: const Text('Start'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/new-group');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
            child: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    bool hasNotification = false,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
              ),
              if (hasNotification)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E1E1E),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      if (date.day == now.today.day) {
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      return '${date.day}/${date.month}';
    } catch (e) {
      return '24 mins';
    }
  }
}

extension on DateTime {
  DateTime get today => DateTime(year, month, day);
}
