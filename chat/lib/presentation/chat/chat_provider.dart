import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/messaging_service.dart';
import '../../data/services/media_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../domain/models/message_model.dart';
import '../../domain/models/moment_model.dart';
import '../../domain/models/user_model.dart';
import '../../data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/contacts/contacts_permission_state.dart';
import '../../domain/models/contact_model.dart';
import '../../data/services/contact_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatProvider extends ChangeNotifier {
  final MessagingService _messagingService = MessagingService();
  final MediaService _mediaService = MediaService();
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final ContactService _contactService = ContactService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;
  List<MessageModel> _messages = [];
  List<Map<String, dynamic>> _recentChats = [];
  List<ContactModel> _discoveredContacts = [];
  List<MomentModel> _moments = [];
  UserModel? _otherUser;
  Map<String, bool> _typingUsers = {};
  String? _currentChatId;
  ContactsPermissionState _contactsPermissionState =
      ContactsPermissionState.notDetermined;

  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _recentChatsSubscription;
  StreamSubscription<List<MomentModel>>? _momentsSubscription;
  StreamSubscription<Map<String, bool>>? _typingSubscription;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MessageModel> get messages => _messages;
  List<Map<String, dynamic>> get recentChats => _recentChats;
  List<ContactModel> get discoveredContacts => _discoveredContacts;
  List<MomentModel> get moments => _moments;
  UserModel? get otherUser => _otherUser;
  bool get isOtherUserTyping => _typingUsers[_otherUser?.id] ?? false;
  ContactsPermissionState get contactsPermissionState =>
      _contactsPermissionState;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void init() {
    _connectivityService.init();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Initialized the provider and starts listening to the message stream for a specific chat.
  Future<void> initChat(String chatId, String currentUserId) async {
    setLoading(true);
    setError(null);
    _otherUser = null;
    _currentChatId = chatId;

    await _messagingService.init();

    // Extract other user ID from chatId (assuming uid1_uid2 format)
    final ids = chatId.split('_');
    final otherUid = ids.first == currentUserId ? ids.last : ids.first;
    _otherUser = await _authService.getUser(otherUid);

    _messagesSubscription?.cancel();
    _messagesSubscription = _messagingService
        .getMessagesStream(chatId)
        .listen(
          (newMessages) {
            _messages = newMessages;
            setLoading(false);
            notifyListeners();
          },
          onError: (err) {
            setError(err.toString());
            setLoading(false);
          },
        );

    _typingSubscription?.cancel();
    _typingSubscription = _messagingService.getTypingStream(chatId).listen((
      typingMap,
    ) {
      _typingUsers = typingMap;
      notifyListeners();
    }, onError: (err) => setError(err.toString()));
  }

  Future<void> updateTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    await _messagingService.setTypingStatus(chatId, userId, isTyping);
  }

  /// Listen to the active moments (stories).
  void listenToMoments() {
    _momentsSubscription?.cancel();
    _momentsSubscription = _messagingService.getMomentsStream().listen((
      newMoments,
    ) {
      _moments = newMoments;
      notifyListeners();
    }, onError: (err) => setError(err.toString()));
  }

  /// Listen to the user's recent chats for the Inbox screen.
  void listenToRecentChats(String userId) {
    setLoading(true);
    _recentChatsSubscription?.cancel();
    _recentChatsSubscription = _messagingService
        .getRecentChats(userId)
        .listen(
          (chats) {
            _recentChats = chats;
            setLoading(false);
            notifyListeners();
          },
          onError: (err) {
            setError(err.toString());
            setLoading(false);
          },
        );
  }

  /// Sends a message with an optimistic update.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    final optimisticMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      status: 'sending',
      isOffline: false,
    );

    _messages.insert(0, optimisticMessage);
    notifyListeners();

    try {
      await _messagingService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        imageUrl: imageUrl,
      );
    } catch (e) {
      setError('Failed to send message: ${e.toString()}');
    }
  }

  /// Handles media picking, compression, upload, and sending.
  Future<void> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required ImageSource source,
  }) async {
    setLoading(true);
    try {
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
  }) async {
    setLoading(true);
    try {
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
        imageUrl: videoUrl, // Reusing imageUrl field for video URL for MVP
      );
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
      notifyListeners();
    } catch (e) {
      setError('Failed to block user: ${e.toString()}');
    }
  }

  Future<void> reportUser(String otherUserId, String reason) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      final chatId =
          _currentChatId ?? 'reported_${DateTime.now().millisecondsSinceEpoch}';

      await _authService.reportContent(
        reporterId: currentUserId,
        reportedUserId: otherUserId,
        chatId: chatId,
        reason: reason,
      );
      notifyListeners();
    } catch (e) {
      setError('Failed to report user: ${e.toString()}');
    }
  }

  /// Resets the provider state, typically used on logout.
  void reset() {
    _messagesSubscription?.cancel();
    _recentChatsSubscription?.cancel();
    _momentsSubscription?.cancel();
    _typingSubscription?.cancel();
    _messages = [];
    _recentChats = [];
    _discoveredContacts = [];
    _moments = [];
    _otherUser = null;
    _currentChatId = null;
    _typingUsers = {};
    _error = null;
    _contactsPermissionState = ContactsPermissionState.notDetermined;
    notifyListeners();
  }

  Future<void> refreshContactsPermissionStatus() async {
    _contactsPermissionState =
        await _contactService.readContactsPermissionState();
    notifyListeners();
  }

  /// In-app rationale should be shown before calling this (see [ContactsAccessPrompt]).
  Future<void> requestContactsAccessAndSync() async {
    setLoading(true);
    setError(null);
    try {
      _contactsPermissionState =
          await _contactService.requestContactsAccess();
      notifyListeners();
      if (_contactsPermissionState == ContactsPermissionState.granted) {
        await _syncContactsFromDevice();
      } else {
        _discoveredContacts = [];
        notifyListeners();
      }
    } catch (e) {
      setError('Contacts permission failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> openContactsPermissionSettings() => openAppSettings();

  /// Reloads address book and matches against Firestore. No-op if permission not granted.
  Future<void> syncContacts() async {
    setLoading(true);
    setError(null);
    try {
      await refreshContactsPermissionStatus();
      if (_contactsPermissionState != ContactsPermissionState.granted) {
        _discoveredContacts = [];
        notifyListeners();
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
    _discoveredContacts = await _contactService.syncWithFirestore(
      localContacts,
    );
    notifyListeners();
  }

  Future<String?> createGroup(String name, List<String> participantIds) async {
    setLoading(true);
    try {
      final groupId = await _messagingService.createGroup(
        name: name,
        participantIds: participantIds,
      );
      setLoading(false);
      return groupId;
    } catch (e) {
      setError('Failed to create group: ${e.toString()}');
      setLoading(false);
      return null;
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _recentChatsSubscription?.cancel();
    _momentsSubscription?.cancel();
    _typingSubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
}
