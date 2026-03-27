import 'package:chat_server/src/generated/safety/safety_block.dart';
import 'package:chat_server/src/generated/safety/safety_report.dart';
import 'package:chat_server/src/security/security_audit.dart';
import 'package:chat_server/src/security/security_guards.dart';
import 'package:serverpod/serverpod.dart';

/// Store compliance: report + block (ADR-0007). Requires authenticated Serverpod user.
class SafetyEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// At least one of [targetUserId], [targetChatId], [targetMessageId] must be set.
  /// [reason] is user-facing category + short text; max 2000 chars server-side.
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

    final hasTarget = (targetUserId != null && targetUserId.isNotEmpty) ||
        (targetChatId != null && targetChatId.isNotEmpty) ||
        (targetMessageId != null && targetMessageId.isNotEmpty);
    if (!hasTarget) {
      throw ArgumentError('Report requires at least one target reference');
    }

    final reporterRaw = session.authenticated!.userIdentifier;
    final reporterId = UuidValueJsonExtension.fromJson(reporterRaw);

    final row = SafetyReport(
      reporterAuthUserId: reporterId,
      targetUserId: _optionalUuid(targetUserId),
      targetChatId: _emptyToNull(targetChatId),
      targetMessageId: _emptyToNull(targetMessageId),
      reason: trimmed,
    );

    final inserted = await SafetyReport.db.insertRow(session, row);
    SecurityAudit.log(
      session,
      event: 'safety_report',
      outcome: 'stored',
      userIdPrefix: SecurityAudit.authenticatedUserPrefix(session),
    );
    return inserted;
  }

  /// Idempotent block row; [blockedAuthUserId] is Serverpod auth user UUID string.
  Future<void> blockUser(Session session, String blockedAuthUserId) async {
    SecurityGuards.requireRpcAllowed(session);

    final blockerRaw = session.authenticated!.userIdentifier;
    final blockerId = UuidValueJsonExtension.fromJson(blockerRaw);
    final blockedId = UuidValueJsonExtension.fromJson(blockedAuthUserId.trim());

    if (blockerId == blockedId) {
      throw ArgumentError('Cannot block yourself');
    }

    final existing = await SafetyBlock.db.findFirstRow(
      session,
      where: (t) =>
          t.blockerAuthUserId.equals(blockerId) &
          t.blockedAuthUserId.equals(blockedId),
    );
    if (existing != null) {
      return;
    }

    await SafetyBlock.db.insertRow(
      session,
      SafetyBlock(
        blockerAuthUserId: blockerId,
        blockedAuthUserId: blockedId,
      ),
    );
    SecurityAudit.log(
      session,
      event: 'safety_block',
      outcome: 'stored',
      userIdPrefix: SecurityAudit.authenticatedUserPrefix(session),
    );
  }

  static UuidValue? _optionalUuid(String? raw) {
    final s = raw?.trim();
    if (s == null || s.isEmpty) {
      return null;
    }
    return UuidValueJsonExtension.fromJson(s);
  }

  static String? _emptyToNull(String? raw) {
    final s = raw?.trim();
    if (s == null || s.isEmpty) {
      return null;
    }
    return s;
  }
}
