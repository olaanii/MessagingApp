import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/security_audit.dart';
import '../security/security_guards.dart';

/// Store compliance: report + block (ADR-0007).
class SafetyEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<SafetyReport> submitReport(
    Session session, {
    String? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) async {
    SecurityGuards.requireRpcAllowed(session);
    SecurityGuards.requireReportAllowed(session);

    final trimmed = reason.trim();
    if (trimmed.isEmpty || trimmed.length > 2000) {
      throw ArgumentError('reason must be non-empty and at most 2000 characters');
    }
    final hasTarget = (targetUserId?.isNotEmpty ?? false) ||
        (targetChatId?.isNotEmpty ?? false) ||
        (targetMessageId?.isNotEmpty ?? false);
    if (!hasTarget) {
      throw ArgumentError('Report requires at least one target reference');
    }

    final me = session.authenticated!.userIdentifier;
    final id = const Uuid().v4();

    await session.db.unsafeQuery(
      '''
      INSERT INTO safety_report
             (id, "reporterAuthUserId", "targetUserId", "targetChatId",
              "targetMessageId", "reason", "createdAt")
      VALUES (@id::uuid, @me::uuid,
              @targetUserId::uuid,
              @targetChatId,
              @targetMessageId,
              @reason,
              now())
      ''',
      parameters: QueryParameters.named({
        'id': id,
        'me': me,
        'targetUserId': targetUserId?.trim().isEmpty ?? true
            ? null
            : targetUserId!.trim(),
        'targetChatId': targetChatId?.trim().isEmpty ?? true
            ? null
            : targetChatId!.trim(),
        'targetMessageId': targetMessageId?.trim().isEmpty ?? true
            ? null
            : targetMessageId!.trim(),
        'reason': trimmed,
      }),
    );

    SecurityAudit.log(
      session,
      event: 'safety_report',
      outcome: 'stored',
      userIdPrefix: SecurityAudit.authenticatedUserPrefix(session),
    );

    final row = await session.db.unsafeQuery(
      'SELECT id, "reporterAuthUserId", "targetUserId", "targetChatId", '
      '"targetMessageId", "reason", "createdAt" '
      'FROM safety_report WHERE id = @id::uuid',
      parameters: QueryParameters.named({'id': id}),
    );
    return _reportFromRow(row.first);
  }

  Future<void> blockUser(Session session, String blockedAuthUserId) async {
    SecurityGuards.requireRpcAllowed(session);

    final me = session.authenticated!.userIdentifier;
    final other = blockedAuthUserId.trim();
    if (me == other) throw ArgumentError('Cannot block yourself');

    await session.db.unsafeQuery(
      '''
      INSERT INTO safety_block
             (id, "blockerAuthUserId", "blockedAuthUserId", "createdAt")
      VALUES (gen_random_uuid_v7(), @me::uuid, @other::uuid, now())
      ON CONFLICT ("blockerAuthUserId", "blockedAuthUserId") DO NOTHING
      ''',
      parameters: QueryParameters.named({'me': me, 'other': other}),
    );

    SecurityAudit.log(
      session,
      event: 'safety_block',
      outcome: 'stored',
      userIdPrefix: SecurityAudit.authenticatedUserPrefix(session),
    );
  }

  Future<void> unblockUser(Session session, String blockedAuthUserId) async {
    SecurityGuards.requireRpcAllowed(session);

    final me = session.authenticated!.userIdentifier;
    final other = blockedAuthUserId.trim();
    if (other.isEmpty) throw ArgumentError('blockedAuthUserId is required');

    await session.db.unsafeQuery(
      '''
      DELETE FROM safety_block
      WHERE "blockerAuthUserId" = @me::uuid
        AND "blockedAuthUserId" = @other::uuid
      ''',
      parameters: QueryParameters.named({'me': me, 'other': other}),
    );

    SecurityAudit.log(
      session,
      event: 'safety_unblock',
      outcome: 'stored',
      userIdPrefix: SecurityAudit.authenticatedUserPrefix(session),
    );
  }

  static SafetyReport _reportFromRow(dynamic row) {
    final c = (row as DatabaseResultRow).toColumnMap();
    return SafetyReport(
      id: UuidValue.fromString(c['id'].toString()),
      reporterAuthUserId: UuidValue.fromString(c['reporterAuthUserId'].toString()),
      targetUserId: c['targetUserId'] == null
          ? null
          : UuidValue.fromString(c['targetUserId'].toString()),
      targetChatId: c['targetChatId'] as String?,
      targetMessageId: c['targetMessageId'] as String?,
      reason: c['reason'] as String,
      createdAt: (c['createdAt'] as DateTime).toUtc(),
    );
  }
}
