import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/message_model.dart';
import '../../domain/models/moment_model.dart';
import '../local/hive_storage.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HiveStorage _hiveStorage = HiveStorage();
  final Uuid _uuid = const Uuid();

  Future<void> init() async {
    await _hiveStorage.init();
    // In a real scenario, we'd also listen for connectivity changes
    // to trigger syncOfflineMessages().
  }

  /// Exposes a stream of messages for a specific chat (either 1-on-1 or group).
  /// chatId is typically constructed by combining the two user IDs or a unique group ID.
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Exposes a stream of recent chats for a user.
  Stream<List<Map<String, dynamic>>> getRecentChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Exposes a stream of active moments (stories).
  Stream<List<MomentModel>> getMomentsStream() {
    // For MVP, we'll just fetch all moments from the last 24 hours.
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    return _firestore
        .collection('moments')
        .where('timestamp', isGreaterThan: yesterday.toIso8601String())
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MomentModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Sets the typing status for a user in a specific chat.
  Future<void> setTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(userId)
        .set({'isTyping': isTyping, 'timestamp': FieldValue.serverTimestamp()});
  }

  /// Stream of user IDs to their typing status.
  Stream<Map<String, bool>> getTypingStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
          final Map<String, bool> typingMap = {};
          for (final doc in snapshot.docs) {
            typingMap[doc.id] = doc.data()['isTyping'] ?? false;
          }
          return typingMap;
        });
  }

  /// Sends a message. If internet is unavailable, saves to offline Hive storage.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    final message = MessageModel(
      id: _uuid.v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      status: 'sent',
      isOffline: false,
    );

    try {
      // Try writing to Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson())
          .timeout(const Duration(seconds: 5)); // Fail fast if offline

      // Update the chat's general metadata (last message, etc)
      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': content,
        'lastMessageTimestamp': message.timestamp.toIso8601String(),
        'participants': [senderId, receiverId],
      }, SetOptions(merge: true));
    } catch (e) {
      // If we fail (likely offline), store locally
      await _hiveStorage.saveOfflineMessage(message.copyWith(isOffline: true));
    }
  }

  /// Attempts to upload ANY messages that were saved locally while offline.
  Future<void> syncAllOfflineMessages() async {
    final offlineMessages = await _hiveStorage.getOfflineMessages();
    if (offlineMessages.isEmpty) return;

    for (var msg in offlineMessages) {
      try {
        final onlineMsg = msg.copyWith(isOffline: false);
        // Derive chatId for 1-on-1 chats
        final ids = [onlineMsg.senderId, onlineMsg.receiverId]..sort();
        final chatId = ids.join('_');

        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(onlineMsg.id)
            .set(onlineMsg.toJson());

        await _hiveStorage.removeOfflineMessage(onlineMsg.id);
      } catch (e) {
        continue;
      }
    }
  }

  /// Attempts to upload any messages that were saved locally while offline for a specific chat.
  Future<void> syncOfflineMessages(String chatId) async {
    final offlineMessages = await _hiveStorage.getOfflineMessages();
    if (offlineMessages.isEmpty) return;

    for (var msg in offlineMessages) {
      try {
        final onlineMsg = msg.copyWith(isOffline: false);
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(onlineMsg.id)
            .set(onlineMsg.toJson());

        // Remove from local storage after successful sync
        await _hiveStorage.removeOfflineMessage(onlineMsg.id);
      } catch (e) {
        // Failed again, leave it in Hive for next time
        continue;
      }
    }
  }

  /// Creates a new group chat.
  Future<String> createGroup({
    required String name,
    required List<String> participantIds,
    String? imageUrl,
  }) async {
    final groupId = _uuid.v4();
    await _firestore.collection('chats').doc(groupId).set({
      'name': name,
      'isGroup': true,
      'participants': participantIds,
      'imageUrl': imageUrl,
      'lastMessage': 'Group created',
      'lastMessageTimestamp': DateTime.now().toIso8601String(),
    });
    return groupId;
  }
}
