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
import 'greetings/greeting.dart' as _i2;
import 'media/media_finalize_result.dart' as _i3;
import 'media/media_upload_request.dart' as _i4;
import 'media/media_upload_slot.dart' as _i5;
import 'safety/safety_block.dart' as _i6;
import 'safety/safety_report.dart' as _i7;
import 'security/rate_limit_exception.dart' as _i8;
import 'streaming/chat_stream_envelope.dart' as _i9;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i10;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i11;
export 'greetings/greeting.dart';
export 'media/media_finalize_result.dart';
export 'media/media_upload_request.dart';
export 'media/media_upload_slot.dart';
export 'safety/safety_block.dart';
export 'safety/safety_report.dart';
export 'security/rate_limit_exception.dart';
export 'streaming/chat_stream_envelope.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.Greeting) {
      return _i2.Greeting.fromJson(data) as T;
    }
    if (t == _i3.MediaFinalizeResult) {
      return _i3.MediaFinalizeResult.fromJson(data) as T;
    }
    if (t == _i4.MediaUploadRequest) {
      return _i4.MediaUploadRequest.fromJson(data) as T;
    }
    if (t == _i5.MediaUploadSlot) {
      return _i5.MediaUploadSlot.fromJson(data) as T;
    }
    if (t == _i6.SafetyBlock) {
      return _i6.SafetyBlock.fromJson(data) as T;
    }
    if (t == _i7.SafetyReport) {
      return _i7.SafetyReport.fromJson(data) as T;
    }
    if (t == _i8.RateLimitException) {
      return _i8.RateLimitException.fromJson(data) as T;
    }
    if (t == _i9.ChatStreamEnvelope) {
      return _i9.ChatStreamEnvelope.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Greeting?>()) {
      return (data != null ? _i2.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.MediaFinalizeResult?>()) {
      return (data != null ? _i3.MediaFinalizeResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.MediaUploadRequest?>()) {
      return (data != null ? _i4.MediaUploadRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.MediaUploadSlot?>()) {
      return (data != null ? _i5.MediaUploadSlot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.SafetyBlock?>()) {
      return (data != null ? _i6.SafetyBlock.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.SafetyReport?>()) {
      return (data != null ? _i7.SafetyReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.RateLimitException?>()) {
      return (data != null ? _i8.RateLimitException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ChatStreamEnvelope?>()) {
      return (data != null ? _i9.ChatStreamEnvelope.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i10.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i11.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Greeting => 'Greeting',
      _i3.MediaFinalizeResult => 'MediaFinalizeResult',
      _i4.MediaUploadRequest => 'MediaUploadRequest',
      _i5.MediaUploadSlot => 'MediaUploadSlot',
      _i6.SafetyBlock => 'SafetyBlock',
      _i7.SafetyReport => 'SafetyReport',
      _i8.RateLimitException => 'RateLimitException',
      _i9.ChatStreamEnvelope => 'ChatStreamEnvelope',
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
      case _i2.Greeting():
        return 'Greeting';
      case _i3.MediaFinalizeResult():
        return 'MediaFinalizeResult';
      case _i4.MediaUploadRequest():
        return 'MediaUploadRequest';
      case _i5.MediaUploadSlot():
        return 'MediaUploadSlot';
      case _i6.SafetyBlock():
        return 'SafetyBlock';
      case _i7.SafetyReport():
        return 'SafetyReport';
      case _i8.RateLimitException():
        return 'RateLimitException';
      case _i9.ChatStreamEnvelope():
        return 'ChatStreamEnvelope';
    }
    className = _i10.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i11.Protocol().getClassNameForObject(data);
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
      return deserialize<_i2.Greeting>(data['data']);
    }
    if (dataClassName == 'MediaFinalizeResult') {
      return deserialize<_i3.MediaFinalizeResult>(data['data']);
    }
    if (dataClassName == 'MediaUploadRequest') {
      return deserialize<_i4.MediaUploadRequest>(data['data']);
    }
    if (dataClassName == 'MediaUploadSlot') {
      return deserialize<_i5.MediaUploadSlot>(data['data']);
    }
    if (dataClassName == 'SafetyBlock') {
      return deserialize<_i6.SafetyBlock>(data['data']);
    }
    if (dataClassName == 'SafetyReport') {
      return deserialize<_i7.SafetyReport>(data['data']);
    }
    if (dataClassName == 'RateLimitException') {
      return deserialize<_i8.RateLimitException>(data['data']);
    }
    if (dataClassName == 'ChatStreamEnvelope') {
      return deserialize<_i9.ChatStreamEnvelope>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i10.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i11.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

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
      return _i10.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i11.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
