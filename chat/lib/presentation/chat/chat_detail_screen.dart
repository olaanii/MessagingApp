import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_provider.dart';
import '../auth/auth_provider.dart';
import '../../domain/models/message_model.dart';
import '../core/shadow_background.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.init(); // Initialize connectivity sync
        chatProvider.initChat(widget.chatId, auth.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = authProvider.currentUser?.id ?? 'me';
    final receiverId = chatProvider.otherUser?.id ?? 'other';

    chatProvider.sendMessage(
      chatId: widget.chatId,
      senderId: currentUserId,
      receiverId: receiverId,
      content: _messageController.text.trim(),
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _pickMedia(ImageSource source) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? 'me';
    final receiverId = chatProvider.otherUser?.id ?? 'other';

    chatProvider.sendMediaMessage(
      chatId: widget.chatId,
      senderId: currentUserId,
      receiverId: receiverId,
      source: source,
    );
    context.pop();
  }

  void _pickVideo(ImageSource source) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? 'me';
    final receiverId = chatProvider.otherUser?.id ?? 'other';

    chatProvider.sendVideoMessage(
      chatId: widget.chatId,
      senderId: currentUserId,
      receiverId: receiverId,
      source: source,
    );
    context.pop();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id ?? 'me';

    return ShadowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chat, _) {
                    if (chat.isLoading && chat.messages.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      reverse: true,
                      itemCount: chat.messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == chat.messages.length) {
                          return const _DateSeparator(label: 'TODAY');
                        }

                        final message = chat.messages[index];
                        final isMe = message.senderId == currentUserId;

                        return _MessageBubble(message: message, isMe: isMe);
                      },
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, size: 24),
        onPressed: () => context.pop(),
      ),
      title: Consumer<ChatProvider>(
        builder: (context, chat, _) {
          final user = chat.otherUser;
          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: user?.avatarUrl.isNotEmpty == true
                      ? DecorationImage(
                          image: NetworkImage(user!.avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[900],
                  border: Border.all(color: Colors.white10, width: 0.5),
                ),
                child: user?.avatarUrl.isEmpty == true
                    ? const Icon(LucideIcons.user, color: Colors.white30)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Loading...',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    chat.isOtherUserTyping ? 'Typing...' : (user?.status ?? 'Offline'),
                    style: TextStyle(
                      fontSize: 10,
                      color: chat.isOtherUserTyping ? Colors.greenAccent : Colors.grey,
                      fontStyle: chat.isOtherUserTyping ? FontStyle.italic : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        _buildCircularHeaderAction(LucideIcons.video),
        _buildCircularHeaderAction(LucideIcons.phone),
        Consumer<ChatProvider>(
          builder: (context, chat, _) => _buildCircularHeaderAction(
            LucideIcons.moreHorizontal,
            onPressed: () => _showMoreOptions(context, chat),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCircularHeaderAction(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.white),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  void _showMoreOptions(BuildContext context, ChatProvider chat) {
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
              leading: const Icon(LucideIcons.ban, color: Colors.redAccent),
              title: const Text('Block User', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                final user = chat.otherUser;
                if (user != null) {
                  await chat.blockUser(user.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User blocked')),
                    );
                    context.pop(); // Go back to inbox
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.flag, color: Colors.orangeAccent),
              title: const Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context, chat);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, ChatProvider chat) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Report User'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Reason for reporting...',
            hintStyle: TextStyle(color: Colors.white30),
          ),
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = chat.otherUser;
              if (user != null && reasonController.text.isNotEmpty) {
                await chat.reportUser(user.id, reasonController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted')),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }


  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.smile, color: Colors.grey, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Type here',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final chat = Provider.of<ChatProvider>(context, listen: false);
                        if (auth.currentUser != null) {
                          chat.updateTypingStatus(
                            widget.chatId,
                            auth.currentUser!.id,
                            val.isNotEmpty,
                          );
                        }
                      },
                      onSubmitted: (_) {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final chat = Provider.of<ChatProvider>(context, listen: false);
                        if (auth.currentUser != null) {
                          chat.updateTypingStatus(
                            widget.chatId,
                            auth.currentUser!.id,
                            false,
                          );
                        }
                        _sendMessage();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, color: Colors.grey, size: 22),
                    onPressed: () => _showAttachmentOptions(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(LucideIcons.send, color: Colors.white, size: 22),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.image, color: Colors.white),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.camera, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.video, color: Colors.white),
                title: const Text('Video', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 4),
              child: Consumer<ChatProvider>(
                builder: (context, chat, _) => Text(
                  chat.otherUser?.name ?? 'Other User',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Consumer<ChatProvider>(
                  builder: (context, chat, _) {
                    final avatarUrl = chat.otherUser?.avatarUrl;
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: avatarUrl != null && avatarUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[900],
                      ),
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? const Icon(LucideIcons.user, size: 16, color: Colors.white30)
                          : null,
                    );
                  },
                ),
              if (!isMe) const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Text(
          '8:16 PM',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.3),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
