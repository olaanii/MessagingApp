import 'package:chat/data/local/db/app_database.dart';
import 'package:chat/data/local/hive_storage.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// One-way migration from Hive to Drift.
///
/// Steps:
/// 1. Initialize Hive.
/// 2. Read all messages from 'offline_messages' box.
/// 3. For each message, insert into Drift 'local_messages' table.
/// 4. If all succeed, delete Hive box content.
///
/// Requirements: 13.3
final class HiveToDriftMigrator {
  const HiveToDriftMigrator({
    required HiveStorage hive,
    required AppDatabase drift,
  })  : _hive = hive,
        _drift = drift;

  final HiveStorage _hive;
  final AppDatabase _drift;

  /// Performs the migration if Hive has data.
  Future<void> migrate() async {
    try {
      final messages = await _hive.getOfflineMessages();
      if (messages.isEmpty) {
        debugPrint('HiveToDrift: No messages in Hive, skipping migration.');
        return;
      }

      debugPrint('HiveToDrift: Migrating ${messages.length} messages to Drift...');

      // Use a transaction for atomicity.
      await _drift.transaction(() async {
        for (final m in messages) {
          final chatId = m.chatId;
          if (chatId == null) continue; // cannot migrate without a chatId
          final receiver = m.receiverId;
          await _drift.into(_drift.localMessages).insertOnConflictUpdate(
                LocalMessagesCompanion.insert(
                  id: m.id,
                  chatId: chatId,
                  senderId: m.senderId,
                  receiverId: receiver.isEmpty
                      ? const Value.absent()
                      : Value(receiver),
                  body: m.content,
                  imageUrl: Value(m.imageUrl),
                  status: Value(m.status),
                  createdAt: m.timestamp,
                  isPendingDelivery: const Value(true), // Hive only stored pending ones
                ),
              );
        }
      });

      // Clear Hive box after successful Drift write.
      await _hive.clearAll();
      debugPrint('HiveToDrift: Migration successful.');
    } catch (e, stack) {
      debugPrint('HiveToDrift: Migration failed: $e\n$stack');
      // Do NOT clear Hive on failure so we can retry.
    }
  }
}
