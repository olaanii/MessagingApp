import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/chat/application/chat_ui_notifier.dart';
import '../../core/contacts/contacts_permission_state.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/message_model.dart';
import '../../domain/models/moment_model.dart';
import '../../domain/models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._ref);

  final Ref _ref;

  ChatUiState _state = const ChatUiState();

  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  List<MessageModel> get messages => _state.messages;
  List<Map<String, dynamic>> get recentChats => _state.recentChats;
  List<ContactModel> get discoveredContacts => _state.discoveredContacts;
  List<MomentModel> get moments => _state.moments;
  UserModel? get otherUser => _state.otherUser;
  bool get isOtherUserTyping => _state.isOtherUserTyping;
  ContactsPermissionState get contactsPermissionState =>
      _state.contactsPermissionState;

  void syncState(ChatUiState state) {
    _state = state;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _ref.read(chatUiNotifierProvider.notifier).setLoading(loading);
  }

  void init() {
    _ref.read(chatUiNotifierProvider.notifier).init();
  }

  void setError(String? error) {
    _ref.read(chatUiNotifierProvider.notifier).setError(error);
  }

  Future<void> initChat(String chatId, String currentUserId) {
    return _ref
        .read(chatUiNotifierProvider.notifier)
        .initChat(chatId, currentUserId);
  }

  Future<void> updateTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) {
    return _ref
        .read(chatUiNotifierProvider.notifier)
        .updateTypingStatus(chatId, userId, isTyping);
  }

  void listenToMoments() {
    _ref.read(chatUiNotifierProvider.notifier).listenToMoments();
  }

  void listenToRecentChats(String userId) {
    _ref.read(chatUiNotifierProvider.notifier).listenToRecentChats(userId);
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) {
    return _ref.read(chatUiNotifierProvider.notifier).sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
          imageUrl: imageUrl,
        );
  }

  Future<void> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required ImageSource source,
    void Function(double progress)? onProgress,
  }) {
    return _ref.read(chatUiNotifierProvider.notifier).sendMediaMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          source: source,
          onProgress: onProgress,
        );
  }

  Future<void> sendVideoMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required ImageSource source,
    void Function(double progress)? onProgress,
  }) {
    return _ref.read(chatUiNotifierProvider.notifier).sendVideoMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          source: source,
          onProgress: onProgress,
        );
  }

  Future<void> blockUser(String otherUserId) {
    return _ref.read(chatUiNotifierProvider.notifier).blockUser(otherUserId);
  }

  Future<void> reportUser(String otherUserId, String reason) {
    return _ref.read(chatUiNotifierProvider.notifier).reportUser(
          otherUserId,
          reason,
        );
  }

  void reset() {
    _ref.read(chatUiNotifierProvider.notifier).reset();
  }

  Future<void> refreshContactsPermissionStatus() {
    return _ref.read(chatUiNotifierProvider.notifier).refreshContactsPermissionStatus();
  }

  Future<void> requestContactsAccessAndSync() {
    return _ref.read(chatUiNotifierProvider.notifier).requestContactsAccessAndSync();
  }

  Future<void> openContactsPermissionSettings() {
    return _ref.read(chatUiNotifierProvider.notifier).openContactsPermissionSettings();
  }

  Future<void> syncContacts() {
    return _ref.read(chatUiNotifierProvider.notifier).syncContacts();
  }

  Future<String?> createGroup(String name, List<String> participantIds) {
    return _ref.read(chatUiNotifierProvider.notifier).createGroup(
          name,
          participantIds,
        );
  }
}
