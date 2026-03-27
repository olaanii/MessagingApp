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

abstract class ChatMessage implements _i1.SerializableModel {
  ChatMessage._({
    _i1.UuidValue? id,
    required this.chatId,
    required this.senderAuthUserId,
    this.senderDeviceId,
    required this.serverSeq,
    required this.clientMsgId,
    required this.ciphertext,
    required this.nonce,
    required this.schemaVersion,
    DateTime? createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory ChatMessage({
    _i1.UuidValue? id,
    required _i1.UuidValue chatId,
    required _i1.UuidValue senderAuthUserId,
    _i1.UuidValue? senderDeviceId,
    required int serverSeq,
    required String clientMsgId,
    required String ciphertext,
    required String nonce,
    required int schemaVersion,
    DateTime? createdAt,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      chatId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['chatId']),
      senderAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['senderAuthUserId'],
      ),
      senderDeviceId: jsonSerialization['senderDeviceId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['senderDeviceId'],
            ),
      serverSeq: jsonSerialization['serverSeq'] as int,
      clientMsgId: jsonSerialization['clientMsgId'] as String,
      ciphertext: jsonSerialization['ciphertext'] as String,
      nonce: jsonSerialization['nonce'] as String,
      schemaVersion: jsonSerialization['schemaVersion'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue chatId;

  _i1.UuidValue senderAuthUserId;

  _i1.UuidValue? senderDeviceId;

  int serverSeq;

  String clientMsgId;

  String ciphertext;

  String nonce;

  int schemaVersion;

  DateTime createdAt;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? chatId,
    _i1.UuidValue? senderAuthUserId,
    _i1.UuidValue? senderDeviceId,
    int? serverSeq,
    String? clientMsgId,
    String? ciphertext,
    String? nonce,
    int? schemaVersion,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMessage',
      'id': id.toJson(),
      'chatId': chatId.toJson(),
      'senderAuthUserId': senderAuthUserId.toJson(),
      if (senderDeviceId != null) 'senderDeviceId': senderDeviceId?.toJson(),
      'serverSeq': serverSeq,
      'clientMsgId': clientMsgId,
      'ciphertext': ciphertext,
      'nonce': nonce,
      'schemaVersion': schemaVersion,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue chatId,
    required _i1.UuidValue senderAuthUserId,
    _i1.UuidValue? senderDeviceId,
    required int serverSeq,
    required String clientMsgId,
    required String ciphertext,
    required String nonce,
    required int schemaVersion,
    DateTime? createdAt,
  }) : super._(
         id: id,
         chatId: chatId,
         senderAuthUserId: senderAuthUserId,
         senderDeviceId: senderDeviceId,
         serverSeq: serverSeq,
         clientMsgId: clientMsgId,
         ciphertext: ciphertext,
         nonce: nonce,
         schemaVersion: schemaVersion,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? chatId,
    _i1.UuidValue? senderAuthUserId,
    Object? senderDeviceId = _Undefined,
    int? serverSeq,
    String? clientMsgId,
    String? ciphertext,
    String? nonce,
    int? schemaVersion,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderAuthUserId: senderAuthUserId ?? this.senderAuthUserId,
      senderDeviceId: senderDeviceId is _i1.UuidValue?
          ? senderDeviceId
          : this.senderDeviceId,
      serverSeq: serverSeq ?? this.serverSeq,
      clientMsgId: clientMsgId ?? this.clientMsgId,
      ciphertext: ciphertext ?? this.ciphertext,
      nonce: nonce ?? this.nonce,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
