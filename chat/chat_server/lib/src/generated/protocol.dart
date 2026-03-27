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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'greetings/greeting.dart' as _i5;
import 'media/media_finalize_result.dart' as _i6;
import 'media/media_upload_request.dart' as _i7;
import 'media/media_upload_slot.dart' as _i8;
import 'safety/safety_block.dart' as _i9;
import 'safety/safety_report.dart' as _i10;
import 'security/rate_limit_exception.dart' as _i11;
import 'streaming/chat_stream_envelope.dart' as _i12;
export 'greetings/greeting.dart';
export 'media/media_finalize_result.dart';
export 'media/media_upload_request.dart';
export 'media/media_upload_slot.dart';
export 'safety/safety_block.dart';
export 'safety/safety_report.dart';
export 'security/rate_limit_exception.dart';
export 'streaming/chat_stream_envelope.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'safety_block',
      dartName: 'SafetyBlock',
      schema: 'public',
      module: 'chat',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'blockerAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'blockedAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'safety_block_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'safety_block_pair_unique',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'blockerAuthUserId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'blockedAuthUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'safety_report',
      dartName: 'SafetyReport',
      schema: 'public',
      module: 'chat',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'reporterAuthUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'targetUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'targetChatId',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'targetMessageId',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'reason',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'safety_report_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'safety_report_reporter_time',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'reporterAuthUserId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.Greeting) {
      return _i5.Greeting.fromJson(data) as T;
    }
    if (t == _i6.MediaFinalizeResult) {
      return _i6.MediaFinalizeResult.fromJson(data) as T;
    }
    if (t == _i7.MediaUploadRequest) {
      return _i7.MediaUploadRequest.fromJson(data) as T;
    }
    if (t == _i8.MediaUploadSlot) {
      return _i8.MediaUploadSlot.fromJson(data) as T;
    }
    if (t == _i9.SafetyBlock) {
      return _i9.SafetyBlock.fromJson(data) as T;
    }
    if (t == _i10.SafetyReport) {
      return _i10.SafetyReport.fromJson(data) as T;
    }
    if (t == _i11.RateLimitException) {
      return _i11.RateLimitException.fromJson(data) as T;
    }
    if (t == _i12.ChatStreamEnvelope) {
      return _i12.ChatStreamEnvelope.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.Greeting?>()) {
      return (data != null ? _i5.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.MediaFinalizeResult?>()) {
      return (data != null ? _i6.MediaFinalizeResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.MediaUploadRequest?>()) {
      return (data != null ? _i7.MediaUploadRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MediaUploadSlot?>()) {
      return (data != null ? _i8.MediaUploadSlot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.SafetyBlock?>()) {
      return (data != null ? _i9.SafetyBlock.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.SafetyReport?>()) {
      return (data != null ? _i10.SafetyReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.RateLimitException?>()) {
      return (data != null ? _i11.RateLimitException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.ChatStreamEnvelope?>()) {
      return (data != null ? _i12.ChatStreamEnvelope.fromJson(data) : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.Greeting => 'Greeting',
      _i6.MediaFinalizeResult => 'MediaFinalizeResult',
      _i7.MediaUploadRequest => 'MediaUploadRequest',
      _i8.MediaUploadSlot => 'MediaUploadSlot',
      _i9.SafetyBlock => 'SafetyBlock',
      _i10.SafetyReport => 'SafetyReport',
      _i11.RateLimitException => 'RateLimitException',
      _i12.ChatStreamEnvelope => 'ChatStreamEnvelope',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('chat.', '');
    }

    switch (data) {
      case _i5.Greeting():
        return 'Greeting';
      case _i6.MediaFinalizeResult():
        return 'MediaFinalizeResult';
      case _i7.MediaUploadRequest():
        return 'MediaUploadRequest';
      case _i8.MediaUploadSlot():
        return 'MediaUploadSlot';
      case _i9.SafetyBlock():
        return 'SafetyBlock';
      case _i10.SafetyReport():
        return 'SafetyReport';
      case _i11.RateLimitException():
        return 'RateLimitException';
      case _i12.ChatStreamEnvelope():
        return 'ChatStreamEnvelope';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i5.Greeting>(data['data']);
    }
    if (dataClassName == 'MediaFinalizeResult') {
      return deserialize<_i6.MediaFinalizeResult>(data['data']);
    }
    if (dataClassName == 'MediaUploadRequest') {
      return deserialize<_i7.MediaUploadRequest>(data['data']);
    }
    if (dataClassName == 'MediaUploadSlot') {
      return deserialize<_i8.MediaUploadSlot>(data['data']);
    }
    if (dataClassName == 'SafetyBlock') {
      return deserialize<_i9.SafetyBlock>(data['data']);
    }
    if (dataClassName == 'SafetyReport') {
      return deserialize<_i10.SafetyReport>(data['data']);
    }
    if (dataClassName == 'RateLimitException') {
      return deserialize<_i11.RateLimitException>(data['data']);
    }
    if (dataClassName == 'ChatStreamEnvelope') {
      return deserialize<_i12.ChatStreamEnvelope>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i9.SafetyBlock:
        return _i9.SafetyBlock.t;
      case _i10.SafetyReport:
        return _i10.SafetyReport.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'chat';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
