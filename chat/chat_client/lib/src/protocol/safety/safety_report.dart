/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// User-generated safety report (opaque message ids only; no ciphertext). ADR-0007.
abstract class SafetyReport implements _i1.SerializableModel {
  SafetyReport._({
    this.id,
    required this.reporterAuthUserId,
    this.targetUserId,
    this.targetChatId,
    this.targetMessageId,
    required this.reason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SafetyReport({
    _i1.UuidValue? id,
    required _i1.UuidValue reporterAuthUserId,
    _i1.UuidValue? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
    DateTime? createdAt,
  }) = _SafetyReportImpl;

  factory SafetyReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return SafetyReport(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      reporterAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['reporterAuthUserId'],
      ),
      targetUserId: jsonSerialization['targetUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['targetUserId'],
            ),
      targetChatId: jsonSerialization['targetChatId'] as String?,
      targetMessageId: jsonSerialization['targetMessageId'] as String?,
      reason: jsonSerialization['reason'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue reporterAuthUserId;

  _i1.UuidValue? targetUserId;

  String? targetChatId;

  String? targetMessageId;

  String reason;

  DateTime createdAt;

  /// Returns a shallow copy of this [SafetyReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SafetyReport copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? reporterAuthUserId,
    _i1.UuidValue? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    String? reason,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SafetyReport',
      if (id != null) 'id': id?.toJson(),
      'reporterAuthUserId': reporterAuthUserId.toJson(),
      if (targetUserId != null) 'targetUserId': targetUserId?.toJson(),
      if (targetChatId != null) 'targetChatId': targetChatId,
      if (targetMessageId != null) 'targetMessageId': targetMessageId,
      'reason': reason,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SafetyReportImpl extends SafetyReport {
  _SafetyReportImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue reporterAuthUserId,
    _i1.UuidValue? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
    DateTime? createdAt,
  }) : super._(
         id: id,
         reporterAuthUserId: reporterAuthUserId,
         targetUserId: targetUserId,
         targetChatId: targetChatId,
         targetMessageId: targetMessageId,
         reason: reason,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SafetyReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SafetyReport copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? reporterAuthUserId,
    Object? targetUserId = _Undefined,
    Object? targetChatId = _Undefined,
    Object? targetMessageId = _Undefined,
    String? reason,
    DateTime? createdAt,
  }) {
    return SafetyReport(
      id: id is _i1.UuidValue? ? id : this.id,
      reporterAuthUserId: reporterAuthUserId ?? this.reporterAuthUserId,
      targetUserId: targetUserId is _i1.UuidValue?
          ? targetUserId
          : this.targetUserId,
      targetChatId: targetChatId is String? ? targetChatId : this.targetChatId,
      targetMessageId: targetMessageId is String?
          ? targetMessageId
          : this.targetMessageId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
