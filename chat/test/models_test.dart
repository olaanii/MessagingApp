import 'package:flutter_test/flutter_test.dart';
import 'package:chat/domain/models/user_model.dart';
import 'package:chat/domain/models/message_model.dart';

void main() {
  group('UserModel Serialization', () {
    test('toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final user = UserModel(
        id: '123',
        name: 'Test Agent',
        avatarUrl: 'https://example.com/avatar.png',
        lastSeen: now,
        status: 'online',
      );

      final json = user.toJson();
      final reconstructedUser = UserModel.fromJson(json);

      expect(reconstructedUser.id, user.id);
      expect(reconstructedUser.name, user.name);
      expect(reconstructedUser.avatarUrl, user.avatarUrl);
      // toIso8601String truncates microseconds in some cases, so compare string representation if needed
      // or compare difference in milliseconds.
      expect(
        reconstructedUser.lastSeen.toIso8601String(),
        user.lastSeen.toIso8601String(),
      );
      expect(reconstructedUser.status, user.status);
    });
  });

  group('MessageModel Serialization', () {
    test('toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final message = MessageModel(
        id: 'msg_1',
        senderId: 'user_1',
        receiverId: 'user_2',
        content: 'Hello, Agent!',
        timestamp: now,
        status: 'delivered',
        isOffline: true,
      );

      final json = message.toJson();
      final reconstructed = MessageModel.fromJson(json);

      expect(reconstructed.id, message.id);
      expect(reconstructed.senderId, message.senderId);
      expect(reconstructed.receiverId, message.receiverId);
      expect(reconstructed.content, message.content);
      expect(reconstructed.status, message.status);
      expect(reconstructed.isOffline, message.isOffline);
    });
  });
}
