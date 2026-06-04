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

abstract class WrappedChatKey implements _i1.SerializableModel {
  WrappedChatKey._({
    this.id,
    required this.chatId,
    required this.recipientAuthUserId,
    required this.envelopeJson,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory WrappedChatKey({
    int? id,
    required String chatId,
    required _i1.UuidValue recipientAuthUserId,
    required String envelopeJson,
    DateTime? createdAt,
  }) = _WrappedChatKeyImpl;

  factory WrappedChatKey.fromJson(Map<String, dynamic> jsonSerialization) {
    return WrappedChatKey(
      id: jsonSerialization['id'] as int?,
      chatId: jsonSerialization['chatId'] as String,
      recipientAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['recipientAuthUserId'],
      ),
      envelopeJson: jsonSerialization['envelopeJson'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String chatId;

  _i1.UuidValue recipientAuthUserId;

  String envelopeJson;

  DateTime createdAt;

  /// Returns a shallow copy of this [WrappedChatKey]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WrappedChatKey copyWith({
    int? id,
    String? chatId,
    _i1.UuidValue? recipientAuthUserId,
    String? envelopeJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WrappedChatKey',
      if (id != null) 'id': id,
      'chatId': chatId,
      'recipientAuthUserId': recipientAuthUserId.toJson(),
      'envelopeJson': envelopeJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WrappedChatKeyImpl extends WrappedChatKey {
  _WrappedChatKeyImpl({
    int? id,
    required String chatId,
    required _i1.UuidValue recipientAuthUserId,
    required String envelopeJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         chatId: chatId,
         recipientAuthUserId: recipientAuthUserId,
         envelopeJson: envelopeJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [WrappedChatKey]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WrappedChatKey copyWith({
    Object? id = _Undefined,
    String? chatId,
    _i1.UuidValue? recipientAuthUserId,
    String? envelopeJson,
    DateTime? createdAt,
  }) {
    return WrappedChatKey(
      id: id is int? ? id : this.id,
      chatId: chatId ?? this.chatId,
      recipientAuthUserId: recipientAuthUserId ?? this.recipientAuthUserId,
      envelopeJson: envelopeJson ?? this.envelopeJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
