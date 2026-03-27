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

abstract class ChatMemberRow implements _i1.SerializableModel {
  ChatMemberRow._({
    this.id,
    required this.chatId,
    required this.memberAuthUserId,
    required this.role,
    DateTime? joinedAt,
    int? lastReadSeq,
  }) : joinedAt = joinedAt ?? DateTime.now(),
       lastReadSeq = lastReadSeq ?? 0;

  factory ChatMemberRow({
    int? id,
    required _i1.UuidValue chatId,
    required _i1.UuidValue memberAuthUserId,
    required String role,
    DateTime? joinedAt,
    int? lastReadSeq,
  }) = _ChatMemberRowImpl;

  factory ChatMemberRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMemberRow(
      id: jsonSerialization['id'] as int?,
      chatId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['chatId']),
      memberAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['memberAuthUserId'],
      ),
      role: jsonSerialization['role'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      lastReadSeq: jsonSerialization['lastReadSeq'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue chatId;

  _i1.UuidValue memberAuthUserId;

  String role;

  DateTime joinedAt;

  int lastReadSeq;

  /// Returns a shallow copy of this [ChatMemberRow]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMemberRow copyWith({
    int? id,
    _i1.UuidValue? chatId,
    _i1.UuidValue? memberAuthUserId,
    String? role,
    DateTime? joinedAt,
    int? lastReadSeq,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMemberRow',
      if (id != null) 'id': id,
      'chatId': chatId.toJson(),
      'memberAuthUserId': memberAuthUserId.toJson(),
      'role': role,
      'joinedAt': joinedAt.toJson(),
      'lastReadSeq': lastReadSeq,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMemberRowImpl extends ChatMemberRow {
  _ChatMemberRowImpl({
    int? id,
    required _i1.UuidValue chatId,
    required _i1.UuidValue memberAuthUserId,
    required String role,
    DateTime? joinedAt,
    int? lastReadSeq,
  }) : super._(
         id: id,
         chatId: chatId,
         memberAuthUserId: memberAuthUserId,
         role: role,
         joinedAt: joinedAt,
         lastReadSeq: lastReadSeq,
       );

  /// Returns a shallow copy of this [ChatMemberRow]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMemberRow copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? chatId,
    _i1.UuidValue? memberAuthUserId,
    String? role,
    DateTime? joinedAt,
    int? lastReadSeq,
  }) {
    return ChatMemberRow(
      id: id is int? ? id : this.id,
      chatId: chatId ?? this.chatId,
      memberAuthUserId: memberAuthUserId ?? this.memberAuthUserId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      lastReadSeq: lastReadSeq ?? this.lastReadSeq,
    );
  }
}
