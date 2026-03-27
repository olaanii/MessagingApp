import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/async_state_widgets.dart';
import '../core/shadow_background.dart';
import '../providers/app_providers.dart';

/// Full-screen chat search; uses the same recent-chats source as inbox (no new backend calls in UI).
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authNotifierProvider);
      final uid = auth.currentUser?.id;
      if (uid != null) {
        ref.read(chatNotifierProvider).listenToRecentChats(uid);
      }
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatNotifierProvider);
    final auth = ref.watch(authNotifierProvider);
    final q = _query.text.trim().toLowerCase();

    final filtered = chat.recentChats.where((c) {
      final title = (c['name'] ?? c['id']).toString().toLowerCase();
      return q.isEmpty || title.contains(q);
    }).toList();

    return ShadowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () => context.pop(),
          ),
          title: Semantics(
            label: 'Search chats',
            textField: true,
            child: TextField(
              controller: _query,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search chats',
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        body: SafeArea(
          child: ResponsiveBody(
            maxWidth: 720,
            child: Builder(
              builder: (context) {
                if (chat.error != null &&
                    filtered.isEmpty &&
                    !chat.isLoading) {
                  return AppErrorState(
                    message: chat.error!,
                    onRetry: () {
                      chat.setError(null);
                      final uid = auth.currentUser?.id;
                      if (uid != null) chat.listenToRecentChats(uid);
                    },
                  );
                }
                if (chat.isLoading && filtered.isEmpty) {
                  return const AppLoadingState(message: 'Loading chats…');
                }
                if (filtered.isEmpty) {
                  return AppEmptyState(
                    title: q.isEmpty ? 'Type to search' : 'No matches',
                    subtitle: q.isEmpty
                        ? 'Find conversations by name'
                        : 'Try a different search term',
                    icon: LucideIcons.search,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final idStr = c['id'].toString();
                    final shortId =
                        idStr.length > 4 ? idStr.substring(0, 4) : idStr;
                    final title = c['name'] ?? 'User $shortId';
                    final subtitle =
                        (c['lastMessage'] ?? 'No messages yet').toString();
                    return Semantics(
                      label: 'Chat $title. Last message $subtitle',
                      button: true,
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(LucideIcons.messageSquare),
                        ),
                        title: Text(title),
                        subtitle: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => context.push('/chat/${c['id']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
