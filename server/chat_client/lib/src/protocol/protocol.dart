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
import 'auth/firebase_auth_user.dart' as _i2;
import 'auth/push_token.dart' as _i3;
import 'greetings/greeting.dart' as _i4;
import 'media/media_finalize_result.dart' as _i5;
import 'media/media_upload_request.dart' as _i6;
import 'media/media_upload_slot.dart' as _i7;
import 'messaging/chat_member.dart' as _i8;
import 'messaging/chat_message.dart' as _i9;
import 'messaging/chat_thread.dart' as _i10;
import 'messaging/message_sync_page.dart' as _i11;
import 'messaging/registered_device.dart' as _i12;
import 'safety/safety_block.dart' as _i13;
import 'safety/safety_report.dart' as _i14;
import 'security/device_key_bundle.dart' as _i15;
import 'security/rate_limit_exception.dart' as _i16;
import 'security/wrapped_chat_key.dart' as _i17;
import 'stories/story.dart' as _i18;
import 'stories/story_view_record.dart' as _i19;
import 'streaming/chat_stream_envelope.dart' as _i20;
import 'package:chat_client/src/protocol/messaging/chat_thread.dart' as _i21;
import 'package:chat_client/src/stories/story_model.dart' as _i22;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i23;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i24;
export 'auth/firebase_auth_user.dart';
export 'auth/push_token.dart';
export 'greetings/greeting.dart';
export 'media/media_finalize_result.dart';
export 'media/media_upload_request.dart';
export 'media/media_upload_slot.dart';
export 'messaging/chat_member.dart';
export 'messaging/chat_message.dart';
export 'messaging/chat_thread.dart';
export 'messaging/message_sync_page.dart';
export 'messaging/registered_device.dart';
export 'safety/safety_block.dart';
export 'safety/safety_report.dart';
export 'security/device_key_bundle.dart';
export 'security/rate_limit_exception.dart';
export 'security/wrapped_chat_key.dart';
export 'stories/story.dart';
export 'stories/story_view_record.dart';
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

    if (t == _i2.FirebaseAuthUser) {
      return _i2.FirebaseAuthUser.fromJson(data) as T;
    }
    if (t == _i3.PushToken) {
      return _i3.PushToken.fromJson(data) as T;
    }
    if (t == _i4.Greeting) {
      return _i4.Greeting.fromJson(data) as T;
    }
    if (t == _i5.MediaFinalizeResult) {
      return _i5.MediaFinalizeResult.fromJson(data) as T;
    }
    if (t == _i6.MediaUploadRequest) {
      return _i6.MediaUploadRequest.fromJson(data) as T;
    }
    if (t == _i7.MediaUploadSlot) {
      return _i7.MediaUploadSlot.fromJson(data) as T;
    }
    if (t == _i8.ChatMemberRow) {
      return _i8.ChatMemberRow.fromJson(data) as T;
    }
    if (t == _i9.ChatMessage) {
      return _i9.ChatMessage.fromJson(data) as T;
    }
    if (t == _i10.ChatThread) {
      return _i10.ChatThread.fromJson(data) as T;
    }
    if (t == _i11.MessageSyncPage) {
      return _i11.MessageSyncPage.fromJson(data) as T;
    }
    if (t == _i12.RegisteredDevice) {
      return _i12.RegisteredDevice.fromJson(data) as T;
    }
    if (t == _i13.SafetyBlock) {
      return _i13.SafetyBlock.fromJson(data) as T;
    }
    if (t == _i14.SafetyReport) {
      return _i14.SafetyReport.fromJson(data) as T;
    }
    if (t == _i15.DeviceKeyBundle) {
      return _i15.DeviceKeyBundle.fromJson(data) as T;
    }
    if (t == _i16.RateLimitException) {
      return _i16.RateLimitException.fromJson(data) as T;
    }
    if (t == _i17.WrappedChatKey) {
      return _i17.WrappedChatKey.fromJson(data) as T;
    }
    if (t == _i18.Story) {
      return _i18.Story.fromJson(data) as T;
    }
    if (t == _i19.StoryViewRecord) {
      return _i19.StoryViewRecord.fromJson(data) as T;
    }
    if (t == _i20.ChatStreamEnvelope) {
      return _i20.ChatStreamEnvelope.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.FirebaseAuthUser?>()) {
      return (data != null ? _i2.FirebaseAuthUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.PushToken?>()) {
      return (data != null ? _i3.PushToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Greeting?>()) {
      return (data != null ? _i4.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.MediaFinalizeResult?>()) {
      return (data != null ? _i5.MediaFinalizeResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.MediaUploadRequest?>()) {
      return (data != null ? _i6.MediaUploadRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.MediaUploadSlot?>()) {
      return (data != null ? _i7.MediaUploadSlot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ChatMemberRow?>()) {
      return (data != null ? _i8.ChatMemberRow.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ChatMessage?>()) {
      return (data != null ? _i9.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ChatThread?>()) {
      return (data != null ? _i10.ChatThread.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.MessageSyncPage?>()) {
      return (data != null ? _i11.MessageSyncPage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.RegisteredDevice?>()) {
      return (data != null ? _i12.RegisteredDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.SafetyBlock?>()) {
      return (data != null ? _i13.SafetyBlock.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.SafetyReport?>()) {
      return (data != null ? _i14.SafetyReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.DeviceKeyBundle?>()) {
      return (data != null ? _i15.DeviceKeyBundle.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.RateLimitException?>()) {
      return (data != null ? _i16.RateLimitException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.WrappedChatKey?>()) {
      return (data != null ? _i17.WrappedChatKey.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.Story?>()) {
      return (data != null ? _i18.Story.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.StoryViewRecord?>()) {
      return (data != null ? _i19.StoryViewRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ChatStreamEnvelope?>()) {
      return (data != null ? _i20.ChatStreamEnvelope.fromJson(data) : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i9.ChatMessage>) {
      return (data as List).map((e) => deserialize<_i9.ChatMessage>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i21.ChatThread>) {
      return (data as List).map((e) => deserialize<_i21.ChatThread>(e)).toList()
          as T;
    }
    if (t == List<_i22.Story>) {
      return (data as List).map((e) => deserialize<_i22.Story>(e)).toList()
          as T;
    }
    try {
      return _i23.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i24.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.FirebaseAuthUser => 'FirebaseAuthUser',
      _i3.PushToken => 'PushToken',
      _i4.Greeting => 'Greeting',
      _i5.MediaFinalizeResult => 'MediaFinalizeResult',
      _i6.MediaUploadRequest => 'MediaUploadRequest',
      _i7.MediaUploadSlot => 'MediaUploadSlot',
      _i8.ChatMemberRow => 'ChatMemberRow',
      _i9.ChatMessage => 'ChatMessage',
      _i10.ChatThread => 'ChatThread',
      _i11.MessageSyncPage => 'MessageSyncPage',
      _i12.RegisteredDevice => 'RegisteredDevice',
      _i13.SafetyBlock => 'SafetyBlock',
      _i14.SafetyReport => 'SafetyReport',
      _i15.DeviceKeyBundle => 'DeviceKeyBundle',
      _i16.RateLimitException => 'RateLimitException',
      _i17.WrappedChatKey => 'WrappedChatKey',
      _i18.Story => 'Story',
      _i19.StoryViewRecord => 'StoryViewRecord',
      _i20.ChatStreamEnvelope => 'ChatStreamEnvelope',
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
      case _i2.FirebaseAuthUser():
        return 'FirebaseAuthUser';
      case _i3.PushToken():
        return 'PushToken';
      case _i4.Greeting():
        return 'Greeting';
      case _i5.MediaFinalizeResult():
        return 'MediaFinalizeResult';
      case _i6.MediaUploadRequest():
        return 'MediaUploadRequest';
      case _i7.MediaUploadSlot():
        return 'MediaUploadSlot';
      case _i8.ChatMemberRow():
        return 'ChatMemberRow';
      case _i9.ChatMessage():
        return 'ChatMessage';
      case _i10.ChatThread():
        return 'ChatThread';
      case _i11.MessageSyncPage():
        return 'MessageSyncPage';
      case _i12.RegisteredDevice():
        return 'RegisteredDevice';
      case _i13.SafetyBlock():
        return 'SafetyBlock';
      case _i14.SafetyReport():
        return 'SafetyReport';
      case _i15.DeviceKeyBundle():
        return 'DeviceKeyBundle';
      case _i16.RateLimitException():
        return 'RateLimitException';
      case _i17.WrappedChatKey():
        return 'WrappedChatKey';
      case _i18.Story():
        return 'Story';
      case _i19.StoryViewRecord():
        return 'StoryViewRecord';
      case _i20.ChatStreamEnvelope():
        return 'ChatStreamEnvelope';
    }
    className = _i23.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i24.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'FirebaseAuthUser') {
      return deserialize<_i2.FirebaseAuthUser>(data['data']);
    }
    if (dataClassName == 'PushToken') {
      return deserialize<_i3.PushToken>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i4.Greeting>(data['data']);
    }
    if (dataClassName == 'MediaFinalizeResult') {
      return deserialize<_i5.MediaFinalizeResult>(data['data']);
    }
    if (dataClassName == 'MediaUploadRequest') {
      return deserialize<_i6.MediaUploadRequest>(data['data']);
    }
    if (dataClassName == 'MediaUploadSlot') {
      return deserialize<_i7.MediaUploadSlot>(data['data']);
    }
    if (dataClassName == 'ChatMemberRow') {
      return deserialize<_i8.ChatMemberRow>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i9.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatThread') {
      return deserialize<_i10.ChatThread>(data['data']);
    }
    if (dataClassName == 'MessageSyncPage') {
      return deserialize<_i11.MessageSyncPage>(data['data']);
    }
    if (dataClassName == 'RegisteredDevice') {
      return deserialize<_i12.RegisteredDevice>(data['data']);
    }
    if (dataClassName == 'SafetyBlock') {
      return deserialize<_i13.SafetyBlock>(data['data']);
    }
    if (dataClassName == 'SafetyReport') {
      return deserialize<_i14.SafetyReport>(data['data']);
    }
    if (dataClassName == 'DeviceKeyBundle') {
      return deserialize<_i15.DeviceKeyBundle>(data['data']);
    }
    if (dataClassName == 'RateLimitException') {
      return deserialize<_i16.RateLimitException>(data['data']);
    }
    if (dataClassName == 'WrappedChatKey') {
      return deserialize<_i17.WrappedChatKey>(data['data']);
    }
    if (dataClassName == 'Story') {
      return deserialize<_i18.Story>(data['data']);
    }
    if (dataClassName == 'StoryViewRecord') {
      return deserialize<_i19.StoryViewRecord>(data['data']);
    }
    if (dataClassName == 'ChatStreamEnvelope') {
      return deserialize<_i20.ChatStreamEnvelope>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i23.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i24.Protocol().deserializeByClassName(data);
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
      return _i23.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i24.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
