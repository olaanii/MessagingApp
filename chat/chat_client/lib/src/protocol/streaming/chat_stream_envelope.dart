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

abstract class ChatStreamEnvelope implements _i1.SerializableModel {
  ChatStreamEnvelope._({
    required this.type,
    this.idempotencyKey,
    required this.deviceId,
    this.chatId,
    this.ts,
    this.payloadJson,
    this.errorCode,
    this.errorMessage,
    this.requestId,
    this.serverSeq,
    this.messageId,
  });

  factory ChatStreamEnvelope({
    required String type,
    String? idempotencyKey,
    required String deviceId,
    String? chatId,
    DateTime? ts,
    String? payloadJson,
    String? errorCode,
    String? errorMessage,
    String? requestId,
    int? serverSeq,
    String? messageId,
  }) = _ChatStreamEnvelopeImpl;

  factory ChatStreamEnvelope.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatStreamEnvelope(
      type: jsonSerialization['type'] as String,
      idempotencyKey: jsonSerialization['idempotencyKey'] as String?,
      deviceId: jsonSerialization['deviceId'] as String,
      chatId: jsonSerialization['chatId'] as String?,
      ts: jsonSerialization['ts'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['ts']),
      payloadJson: jsonSerialization['payloadJson'] as String?,
      errorCode: jsonSerialization['errorCode'] as String?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
      requestId: jsonSerialization['requestId'] as String?,
      serverSeq: jsonSerialization['serverSeq'] as int?,
      messageId: jsonSerialization['messageId'] as String?,
    );
  }

  /// Event name: send_message | message | message_ack | typing | presence | sync_hint | error
  String type;

  String? idempotencyKey;

  String deviceId;

  String? chatId;

  DateTime? ts;

  /// Opaque JSON string for event-specific fields (e.g. ciphertext handles).
  String? payloadJson;

  String? errorCode;

  String? errorMessage;

  String? requestId;

  int? serverSeq;

  String? messageId;

  /// Returns a shallow copy of this [ChatStreamEnvelope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatStreamEnvelope copyWith({
    String? type,
    String? idempotencyKey,
    String? deviceId,
    String? chatId,
    DateTime? ts,
    String? payloadJson,
    String? errorCode,
    String? errorMessage,
    String? requestId,
    int? serverSeq,
    String? messageId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatStreamEnvelope',
      'type': type,
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      'deviceId': deviceId,
      if (chatId != null) 'chatId': chatId,
      if (ts != null) 'ts': ts?.toJson(),
      if (payloadJson != null) 'payloadJson': payloadJson,
      if (errorCode != null) 'errorCode': errorCode,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (requestId != null) 'requestId': requestId,
      if (serverSeq != null) 'serverSeq': serverSeq,
      if (messageId != null) 'messageId': messageId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatStreamEnvelopeImpl extends ChatStreamEnvelope {
  _ChatStreamEnvelopeImpl({
    required String type,
    String? idempotencyKey,
    required String deviceId,
    String? chatId,
    DateTime? ts,
    String? payloadJson,
    String? errorCode,
    String? errorMessage,
    String? requestId,
    int? serverSeq,
    String? messageId,
  }) : super._(
         type: type,
         idempotencyKey: idempotencyKey,
         deviceId: deviceId,
         chatId: chatId,
         ts: ts,
         payloadJson: payloadJson,
         errorCode: errorCode,
         errorMessage: errorMessage,
         requestId: requestId,
         serverSeq: serverSeq,
         messageId: messageId,
       );

  /// Returns a shallow copy of this [ChatStreamEnvelope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatStreamEnvelope copyWith({
    String? type,
    Object? idempotencyKey = _Undefined,
    String? deviceId,
    Object? chatId = _Undefined,
    Object? ts = _Undefined,
    Object? payloadJson = _Undefined,
    Object? errorCode = _Undefined,
    Object? errorMessage = _Undefined,
    Object? requestId = _Undefined,
    Object? serverSeq = _Undefined,
    Object? messageId = _Undefined,
  }) {
    return ChatStreamEnvelope(
      type: type ?? this.type,
      idempotencyKey: idempotencyKey is String?
          ? idempotencyKey
          : this.idempotencyKey,
      deviceId: deviceId ?? this.deviceId,
      chatId: chatId is String? ? chatId : this.chatId,
      ts: ts is DateTime? ? ts : this.ts,
      payloadJson: payloadJson is String? ? payloadJson : this.payloadJson,
      errorCode: errorCode is String? ? errorCode : this.errorCode,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      requestId: requestId is String? ? requestId : this.requestId,
      serverSeq: serverSeq is int? ? serverSeq : this.serverSeq,
      messageId: messageId is String? ? messageId : this.messageId,
    );
  }
}
