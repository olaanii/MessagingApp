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

/// Ephemeral story / post (encrypted content; 24 h TTL per ADR-0002).
abstract class Story implements _i1.SerializableModel {
  Story._({
    _i1.UuidValue? id,
    required this.authorAuthUserId,
    required this.mediaType,
    required this.encryptedPayload,
    required this.nonce,
    this.thumbnailCiphertext,
    required this.privacy,
    this.selectedViewerIds,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       expiresAt = expiresAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  factory Story({
    _i1.UuidValue? id,
    required _i1.UuidValue authorAuthUserId,
    required String mediaType,
    required String encryptedPayload,
    required String nonce,
    String? thumbnailCiphertext,
    required String privacy,
    String? selectedViewerIds,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) = _StoryImpl;

  factory Story.fromJson(Map<String, dynamic> jsonSerialization) {
    return Story(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authorAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authorAuthUserId'],
      ),
      mediaType: jsonSerialization['mediaType'] as String,
      encryptedPayload: jsonSerialization['encryptedPayload'] as String,
      nonce: jsonSerialization['nonce'] as String,
      thumbnailCiphertext: jsonSerialization['thumbnailCiphertext'] as String?,
      privacy: jsonSerialization['privacy'] as String,
      selectedViewerIds: jsonSerialization['selectedViewerIds'] as String?,
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue authorAuthUserId;

  String mediaType;

  String encryptedPayload;

  String nonce;

  String? thumbnailCiphertext;

  String privacy;

  String? selectedViewerIds;

  DateTime expiresAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [Story]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Story copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authorAuthUserId,
    String? mediaType,
    String? encryptedPayload,
    String? nonce,
    String? thumbnailCiphertext,
    String? privacy,
    String? selectedViewerIds,
    DateTime? expiresAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Story',
      'id': id.toJson(),
      'authorAuthUserId': authorAuthUserId.toJson(),
      'mediaType': mediaType,
      'encryptedPayload': encryptedPayload,
      'nonce': nonce,
      if (thumbnailCiphertext != null)
        'thumbnailCiphertext': thumbnailCiphertext,
      'privacy': privacy,
      if (selectedViewerIds != null) 'selectedViewerIds': selectedViewerIds,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoryImpl extends Story {
  _StoryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authorAuthUserId,
    required String mediaType,
    required String encryptedPayload,
    required String nonce,
    String? thumbnailCiphertext,
    required String privacy,
    String? selectedViewerIds,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authorAuthUserId: authorAuthUserId,
         mediaType: mediaType,
         encryptedPayload: encryptedPayload,
         nonce: nonce,
         thumbnailCiphertext: thumbnailCiphertext,
         privacy: privacy,
         selectedViewerIds: selectedViewerIds,
         expiresAt: expiresAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Story]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Story copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authorAuthUserId,
    String? mediaType,
    String? encryptedPayload,
    String? nonce,
    Object? thumbnailCiphertext = _Undefined,
    String? privacy,
    Object? selectedViewerIds = _Undefined,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return Story(
      id: id ?? this.id,
      authorAuthUserId: authorAuthUserId ?? this.authorAuthUserId,
      mediaType: mediaType ?? this.mediaType,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      nonce: nonce ?? this.nonce,
      thumbnailCiphertext: thumbnailCiphertext is String?
          ? thumbnailCiphertext
          : this.thumbnailCiphertext,
      privacy: privacy ?? this.privacy,
      selectedViewerIds: selectedViewerIds is String?
          ? selectedViewerIds
          : this.selectedViewerIds,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
