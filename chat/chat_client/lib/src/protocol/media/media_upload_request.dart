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

/// Client wants to upload a compressed blob; server validates MIME/size and returns a slot.
abstract class MediaUploadRequest implements _i1.SerializableModel {
  MediaUploadRequest._({
    required this.fileName,
    required this.mimeType,
    required this.byteLength,
    this.chatId,
  });

  factory MediaUploadRequest({
    required String fileName,
    required String mimeType,
    required int byteLength,
    String? chatId,
  }) = _MediaUploadRequestImpl;

  factory MediaUploadRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaUploadRequest(
      fileName: jsonSerialization['fileName'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      byteLength: jsonSerialization['byteLength'] as int,
      chatId: jsonSerialization['chatId'] as String?,
    );
  }

  String fileName;

  String mimeType;

  int byteLength;

  String? chatId;

  /// Returns a shallow copy of this [MediaUploadRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MediaUploadRequest copyWith({
    String? fileName,
    String? mimeType,
    int? byteLength,
    String? chatId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MediaUploadRequest',
      'fileName': fileName,
      'mimeType': mimeType,
      'byteLength': byteLength,
      if (chatId != null) 'chatId': chatId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MediaUploadRequestImpl extends MediaUploadRequest {
  _MediaUploadRequestImpl({
    required String fileName,
    required String mimeType,
    required int byteLength,
    String? chatId,
  }) : super._(
         fileName: fileName,
         mimeType: mimeType,
         byteLength: byteLength,
         chatId: chatId,
       );

  /// Returns a shallow copy of this [MediaUploadRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MediaUploadRequest copyWith({
    String? fileName,
    String? mimeType,
    int? byteLength,
    Object? chatId = _Undefined,
  }) {
    return MediaUploadRequest(
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      byteLength: byteLength ?? this.byteLength,
      chatId: chatId is String? ? chatId : this.chatId,
    );
  }
}
