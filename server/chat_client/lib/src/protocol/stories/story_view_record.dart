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

/// Story view record (who viewed which story).
abstract class StoryViewRecord implements _i1.SerializableModel {
  StoryViewRecord._({
    this.id,
    required this.storyId,
    required this.viewerAuthUserId,
    DateTime? viewedAt,
  }) : viewedAt = viewedAt ?? DateTime.now();

  factory StoryViewRecord({
    _i1.UuidValue? id,
    required _i1.UuidValue storyId,
    required _i1.UuidValue viewerAuthUserId,
    DateTime? viewedAt,
  }) = _StoryViewRecordImpl;

  factory StoryViewRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoryViewRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      storyId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['storyId'],
      ),
      viewerAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['viewerAuthUserId'],
      ),
      viewedAt: jsonSerialization['viewedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['viewedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue storyId;

  _i1.UuidValue viewerAuthUserId;

  DateTime viewedAt;

  /// Returns a shallow copy of this [StoryViewRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StoryViewRecord copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? storyId,
    _i1.UuidValue? viewerAuthUserId,
    DateTime? viewedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StoryViewRecord',
      if (id != null) 'id': id?.toJson(),
      'storyId': storyId.toJson(),
      'viewerAuthUserId': viewerAuthUserId.toJson(),
      'viewedAt': viewedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StoryViewRecordImpl extends StoryViewRecord {
  _StoryViewRecordImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue storyId,
    required _i1.UuidValue viewerAuthUserId,
    DateTime? viewedAt,
  }) : super._(
         id: id,
         storyId: storyId,
         viewerAuthUserId: viewerAuthUserId,
         viewedAt: viewedAt,
       );

  /// Returns a shallow copy of this [StoryViewRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StoryViewRecord copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? storyId,
    _i1.UuidValue? viewerAuthUserId,
    DateTime? viewedAt,
  }) {
    return StoryViewRecord(
      id: id is _i1.UuidValue? ? id : this.id,
      storyId: storyId ?? this.storyId,
      viewerAuthUserId: viewerAuthUserId ?? this.viewerAuthUserId,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }
}
