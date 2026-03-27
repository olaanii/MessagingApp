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
import 'package:chat_server/src/generated/protocol.dart' as _i2;

/// Presign-style slot: PUT binary to [uploadUrl] with optional chunked headers.
abstract class MediaUploadSlot
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MediaUploadSlot._({
    required this.mediaId,
    required this.uploadUrl,
    required this.expiresAt,
    required this.maxBytes,
    required this.chunkSizeBytes,
    required this.allowedMimeTypes,
    required this.finalizeToken,
  });

  factory MediaUploadSlot({
    required String mediaId,
    required String uploadUrl,
    required DateTime expiresAt,
    required int maxBytes,
    required int chunkSizeBytes,
    required List<String> allowedMimeTypes,
    required String finalizeToken,
  }) = _MediaUploadSlotImpl;

  factory MediaUploadSlot.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaUploadSlot(
      mediaId: jsonSerialization['mediaId'] as String,
      uploadUrl: jsonSerialization['uploadUrl'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      maxBytes: jsonSerialization['maxBytes'] as int,
      chunkSizeBytes: jsonSerialization['chunkSizeBytes'] as int,
      allowedMimeTypes: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['allowedMimeTypes'],
      ),
      finalizeToken: jsonSerialization['finalizeToken'] as String,
    );
  }

  String mediaId;

  String uploadUrl;

  DateTime expiresAt;

  int maxBytes;

  int chunkSizeBytes;

  List<String> allowedMimeTypes;

  String finalizeToken;

  /// Returns a shallow copy of this [MediaUploadSlot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MediaUploadSlot copyWith({
    String? mediaId,
    String? uploadUrl,
    DateTime? expiresAt,
    int? maxBytes,
    int? chunkSizeBytes,
    List<String>? allowedMimeTypes,
    String? finalizeToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MediaUploadSlot',
      'mediaId': mediaId,
      'uploadUrl': uploadUrl,
      'expiresAt': expiresAt.toJson(),
      'maxBytes': maxBytes,
      'chunkSizeBytes': chunkSizeBytes,
      'allowedMimeTypes': allowedMimeTypes.toJson(),
      'finalizeToken': finalizeToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MediaUploadSlot',
      'mediaId': mediaId,
      'uploadUrl': uploadUrl,
      'expiresAt': expiresAt.toJson(),
      'maxBytes': maxBytes,
      'chunkSizeBytes': chunkSizeBytes,
      'allowedMimeTypes': allowedMimeTypes.toJson(),
      'finalizeToken': finalizeToken,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MediaUploadSlotImpl extends MediaUploadSlot {
  _MediaUploadSlotImpl({
    required String mediaId,
    required String uploadUrl,
    required DateTime expiresAt,
    required int maxBytes,
    required int chunkSizeBytes,
    required List<String> allowedMimeTypes,
    required String finalizeToken,
  }) : super._(
         mediaId: mediaId,
         uploadUrl: uploadUrl,
         expiresAt: expiresAt,
         maxBytes: maxBytes,
         chunkSizeBytes: chunkSizeBytes,
         allowedMimeTypes: allowedMimeTypes,
         finalizeToken: finalizeToken,
       );

  /// Returns a shallow copy of this [MediaUploadSlot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MediaUploadSlot copyWith({
    String? mediaId,
    String? uploadUrl,
    DateTime? expiresAt,
    int? maxBytes,
    int? chunkSizeBytes,
    List<String>? allowedMimeTypes,
    String? finalizeToken,
  }) {
    return MediaUploadSlot(
      mediaId: mediaId ?? this.mediaId,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      maxBytes: maxBytes ?? this.maxBytes,
      chunkSizeBytes: chunkSizeBytes ?? this.chunkSizeBytes,
      allowedMimeTypes:
          allowedMimeTypes ?? this.allowedMimeTypes.map((e0) => e0).toList(),
      finalizeToken: finalizeToken ?? this.finalizeToken,
    );
  }
}
