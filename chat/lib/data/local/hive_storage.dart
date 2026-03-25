import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/message_model.dart';
import 'package:path_provider/path_provider.dart';

class HiveStorage {
  static const String _messagesBox = 'offline_messages';

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.openBox<Map<dynamic, dynamic>>(_messagesBox);
  }

  Future<void> saveOfflineMessage(MessageModel message) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_messagesBox);
    await box.put(message.id, message.toJson());
  }

  Future<List<MessageModel>> getOfflineMessages() async {
    final box = Hive.box<Map<dynamic, dynamic>>(_messagesBox);
    return box.values.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['isOffline'] = true; // explicitly mark as offline
      return MessageModel.fromJson(map);
    }).toList();
  }

  Future<void> removeOfflineMessage(String messageId) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_messagesBox);
    await box.delete(messageId);
  }

  Future<void> clearAll() async {
    final box = Hive.box<Map<dynamic, dynamic>>(_messagesBox);
    await box.clear();
  }
}
