import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/contacts/contacts_permission_state.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/contact_service.dart';
import '../../../data/services/media_service.dart';
import '../../../data/services/messaging_service.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../domain/models/contact_model.dart';
import '../../../domain/models/message_model.dart';
import '../../../domain/models/moment_model.dart';
import '../../../domain/models/user_model.dart';
import 'package:uuid/uuid.dart';
import 'messaging_sync_mode_provider.dart';
import 'chat_notifier.dart' show mediaUploadServiceProvider;

const Object _unset = Object();

@immutable
final class ChatUiState {
  const ChatUiState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.recentChats = const [],
    this.discoveredContacts = const [],
    this.moments = const [],
    this.otherUser,
    this.typingUsers = const {},
    this.currentChatId,
    this.contactsPermissionState = ContactsPermissionState.notDetermined,
  });

  final bool isLoading;
  final String? error;
  final List<MessageModel> messages;
  final List<Map<String, dynamic>> recentChats;
  final List<ContactModel> discoveredContacts;
  final List<MomentModel> moments;
  final UserModel? otherUser;
  final Map<String, bool> typingUsers;
  final String? currentChatId;
  final ContactsPermissionState contactsPermissionState;

  bool get isOtherUserTyping => typingUsers[otherUser?.id] ?? false;

  ChatUiState copyWith({
    bool? isLoading,
    Object? error = _unset,
    List<MessageModel>? messages,
    List<Map<String, dynamic>>? recentChats,
    List<ContactModel>? discoveredContacts,
    List<MomentModel>? moments,
    Object? otherUser = _unset,
    Map<String, bool>? typingUsers,
    Object? currentChatId = _unset,
    ContactsPermissionState? contactsPermissionState,
  }) {
    return ChatUiState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      messages: messages ?? this.messages,
      recentChats: recentChats ?? this.recentChats,
      discoveredContacts: discoveredContacts ?? this.discoveredContacts,
      moments: moments ?? this.moments,
      otherUser: identical(otherUser, _unset)
          ? this.otherUser
          : otherUser as UserModel?,
      typingUsers: typingUsers ?? this.typingUsers,
      currentChatId: identical(currentChatId, _unset)
          ? this.currentChatId
          : currentChatId as String?,
      contactsPermissionState:
          contactsPermissionState ?? this.contactsPermissionState,
    );
  }
}

final chatUiNotifierProvider =
    NotifierProvider<ChatUiNotifier, ChatUiState>(ChatUiNotifier.new);

final class ChatUiNotifier extends Notifier<ChatUiState> {
  final MessagingService _messagingService = MessagingService();
  final MediaService _mediaService = MediaService();
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final ContactService _contactService = ContactService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _recentChatsSubscription;
  StreamSubscription<List<MomentModel>>? _momentsSubscription;
  StreamSubscription<Map<String, bool>>? _typingSubscription;

  @override
  ChatUiState build() {
    ref.onDispose(_dispose);
    return const ChatUiState();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void init() {
    _connectivityService.init();
  }

  Future<void> initChat(String chatId, String currentUserId) async {
    setLoading(true);
    setError(null);
    state = state.copyWith(
      otherUser: null,
      currentChatId: chatId,
      messages: const [],
      typingUsers: const {},
    );

    await _messagingService.init();

    final ids = chatId.split('_');
    final otherUid = ids.first == currentUserId ? ids.last : ids.first;
    final otherUser = await _authService.getUser(otherUid);
    state = state.copyWith(otherUser: otherUser);

    await _messagesSubscription?.cancel();
    _messagesSubscription = _messagingService.getMessagesStream(chatId).listen(
      (newMessages) {
        state = state.copyWith(messages: newMessages, isLoading: false);
      },
      onError: (Object err) {
        setError(err.toString());
        setLoading(false);
      },
    );

    await _typingSubscription?.cancel();
    _typingSubscription = _messagingService.getTypingStream(chatId).listen(
      (typingMap) {
        state = state.copyWith(typingUsers: typingMap);
      },
      onError: (Object err) => setError(err.toString()),
    );
  }

  Future<void> updateTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    await _messagingService.setTypingStatus(chatId, userId, isTyping);
  }

  void listenToMoments() {
    _momentsSubscription?.cancel();
    _momentsSubscription = _messagingService.getMomentsStream().listen(
      (newMoments) {
        state = state.copyWith(moments: newMoments);
      },
      onError: (Object err) => setError(err.toString()),
    );
  }

  void listenToRecentChats(String userId) {
    setLoading(true);
    _recentChatsSubscription?.cancel();
    _recentChatsSubscription = _messagingService.getRecentChats(userId).listen(
      (chats) {
        state = state.copyWith(recentChats: chats, isLoading: false);
      },
      onError: (Object err) {
        setError(err.toString());
        setLoading(false);
      },
    );
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    final optimisticMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      status: 'sending',
      isOffline: false,
    );

    state = state.copyWith(messages: [optimisticMessage, ...state.messages]);

    try {
      final syncMode = ref.read(messagingSyncModeProvider);
      if (syncMode.useServerpod) {
        await _sendServerpod(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
          imageUrl: imageUrl,
        );
      } else {
        await _messagingService.sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      setError('Failed to send message: ${e.toString()}');
    }
  }

  Future<void> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required ImageSource source,
    void Function(double progress)? onProgress,
  }) async {
    setLoading(true);
    try {
      final syncMode = ref.read(messagingSyncModeProvider);
      if (syncMode.useServerpod) {
        final mediaService = ref.read(mediaUploadServiceProvider);
        if (mediaService == null) {
          throw StateError('mediaUploadServiceProvider is not configured');
        }

        final pickedFile = await _mediaService.pickImage(source);
        if (pickedFile == null) {
          setLoading(false);
          return;
        }

        final compressedFile = await _mediaService.compressImage(pickedFile);
        if (compressedFile == null) {
          setLoading(false);
          return;
        }

        onProgress?.call(0.5);

        final imageUrl = await mediaService.uploadMedia(
          chatId: chatId,
          file: compressedFile,
          mimeType: 'image/jpeg',
          onProgress: onProgress == null
              ? null
              : (value) => onProgress(0.5 + (value * 0.5)),
        );

        await sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          content: '📷 Photo',
          imageUrl: imageUrl,
        );
      } else {
        final pickedFile = await _mediaService.pickImage(source);
        if (pickedFile == null) {
          setLoading(false);
          return;
        }

        final compressedFile = await _mediaService.compressImage(pickedFile);
        if (compressedFile == null) {
          setLoading(false);
          return;
        }

        final storagePath =
            'chats/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final imageUrl = await _mediaService.uploadFile(
          compressedFile,
          storagePath,
        );

        await sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          content: '📷 Photo',
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      setError('Media upload failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> sendVideoMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required ImageSource source,
    void Function(double progress)? onProgress,
  }) async {
    setLoading(true);
    try {
      final syncMode = ref.read(messagingSyncModeProvider);
      if (syncMode.useServerpod) {
        final mediaService = ref.read(mediaUploadServiceProvider);
        if (mediaService == null) {
          throw StateError('mediaUploadServiceProvider is not configured');
        }

        final pickedFile = await _mediaService.pickVideo(source);
        if (pickedFile == null) {
          setLoading(false);
          return;
        }

        final compressedFile = await _mediaService.compressVideo(pickedFile);
        if (compressedFile == null) {
          setLoading(false);
          return;
        }

        onProgress?.call(0.5);

        final videoUrl = await mediaService.uploadMedia(
          chatId: chatId,
          file: compressedFile,
          mimeType: 'video/mp4',
          onProgress: onProgress == null
              ? null
              : (value) => onProgress(0.5 + (value * 0.5)),
        );

        await sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          content: '🎥 Video',
          imageUrl: videoUrl,
        );
      } else {
        final pickedFile = await _mediaService.pickVideo(source);
        if (pickedFile == null) {
          setLoading(false);
          return;
        }

        final compressedFile = await _mediaService.compressVideo(pickedFile);
        if (compressedFile == null) {
          setLoading(false);
          return;
        }

        final storagePath =
            'chats/$chatId/${DateTime.now().millisecondsSinceEpoch}.mp4';
        final videoUrl = await _mediaService.uploadFile(
          compressedFile,
          storagePath,
        );

        await sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          content: '🎥 Video',
          imageUrl: videoUrl,
        );
      }
    } catch (e) {
      setError('Video upload failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> blockUser(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;
      await _authService.blockUser(currentUserId, otherUserId);
    } catch (e) {
      setError('Failed to block user: ${e.toString()}');
    }
  }

  Future<void> reportUser(String otherUserId, String reason) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final chatId =
          state.currentChatId ??
          'reported_${DateTime.now().millisecondsSinceEpoch}';

      await _authService.reportContent(
        reporterId: currentUserId,
        reportedUserId: otherUserId,
        chatId: chatId,
        reason: reason,
      );
    } catch (e) {
      setError('Failed to report user: ${e.toString()}');
    }
  }

  Future<void> _sendServerpod({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    final syncRepo = ref.read(syncRepositoryProvider);
    final clientMsgId = const Uuid().v4();

    final payload = {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'imageUrl': imageUrl ?? '',
    };

    await syncRepo.enqueueOperation(
      clientMsgId: clientMsgId,
      chatId: chatId,
      payloadJson: _encodePayload(payload),
      operation: 'sendMessage',
    );
  }

  String _encodePayload(Map<String, String> map) {
    final entries = map.entries
        .map((e) => '"${_escape(e.key)}":"${_escape(e.value)}"')
        .join(',');
    return '{$entries}';
  }

  String _escape(String s) => s.replaceAll(r'\', r'\\').replaceAll('"', r'\"');

  void reset() {
    _messagesSubscription?.cancel();
    _recentChatsSubscription?.cancel();
    _momentsSubscription?.cancel();
    _typingSubscription?.cancel();
    state = const ChatUiState();
  }

  Future<void> refreshContactsPermissionStatus() async {
    state = state.copyWith(
      contactsPermissionState:
          await _contactService.readContactsPermissionState(),
    );
  }

  Future<void> requestContactsAccessAndSync() async {
    setLoading(true);
    setError(null);
    try {
      final permissionState = await _contactService.requestContactsAccess();
      state = state.copyWith(contactsPermissionState: permissionState);
      if (permissionState == ContactsPermissionState.granted) {
        await _syncContactsFromDevice();
      } else {
        state = state.copyWith(discoveredContacts: const []);
      }
    } catch (e) {
      setError('Contacts permission failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> openContactsPermissionSettings() => openAppSettings();

  Future<void> syncContacts() async {
    setLoading(true);
    setError(null);
    try {
      await refreshContactsPermissionStatus();
      if (state.contactsPermissionState != ContactsPermissionState.granted) {
        state = state.copyWith(discoveredContacts: const []);
        return;
      }
      await _syncContactsFromDevice();
    } catch (e) {
      setError('Contact sync failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _syncContactsFromDevice() async {
    final localContacts = await _contactService.getLocalContacts();
    final syncedContacts = await _contactService.syncWithFirestore(
      localContacts,
    );
    state = state.copyWith(discoveredContacts: syncedContacts);
  }

  Future<String?> createGroup(String name, List<String> participantIds) async {
    setLoading(true);
    try {
      final groupId = await _messagingService.createGroup(
        name: name,
        participantIds: participantIds,
      );
      return groupId;
    } catch (e) {
      setError('Failed to create group: ${e.toString()}');
      return null;
    } finally {
      setLoading(false);
    }
  }

  void _dispose() {
    _messagesSubscription?.cancel();
    _recentChatsSubscription?.cancel();
    _momentsSubscription?.cancel();
    _typingSubscription?.cancel();
    _connectivityService.dispose();
  }
}
