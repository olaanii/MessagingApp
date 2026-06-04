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

/// Returned after server verifies on-disk size; use [fetchUrl] in message attachments.
abstract class MediaFinalizeResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MediaFinalizeResult._({
    required this.mediaId,
    required this.fetchUrl,
  });

  factory MediaFinalizeResult({
    required String mediaId,
    required String fetchUrl,
  }) = _MediaFinalizeResultImpl;

  factory MediaFinalizeResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaFinalizeResult(
      mediaId: jsonSerialization['mediaId'] as String,
      fetchUrl: jsonSerialization['fetchUrl'] as String,
    );
  }

  String mediaId;

  String fetchUrl;

  /// Returns a shallow copy of this [MediaFinalizeResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MediaFinalizeResult copyWith({
    String? mediaId,
    String? fetchUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MediaFinalizeResult',
      'mediaId': mediaId,
      'fetchUrl': fetchUrl,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MediaFinalizeResult',
      'mediaId': mediaId,
      'fetchUrl': fetchUrl,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MediaFinalizeResultImpl extends MediaFinalizeResult {
  _MediaFinalizeResultImpl({
    required String mediaId,
    required String fetchUrl,
  }) : super._(
         mediaId: mediaId,
         fetchUrl: fetchUrl,
       );

  /// Returns a shallow copy of this [MediaFinalizeResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MediaFinalizeResult copyWith({
    String? mediaId,
    String? fetchUrl,
  }) {
    return MediaFinalizeResult(
      mediaId: mediaId ?? this.mediaId,
      fetchUrl: fetchUrl ?? this.fetchUrl,
    );
  }
}
