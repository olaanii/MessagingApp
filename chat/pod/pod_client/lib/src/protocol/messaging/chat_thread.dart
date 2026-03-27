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

abstract class ChatThread implements _i1.SerializableModel {
  ChatThread._({
    _i1.UuidValue? id,
    required this.type,
    this.title,
    this.createdByAuthUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ChatThread({
    _i1.UuidValue? id,
    required String type,
    String? title,
    _i1.UuidValue? createdByAuthUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatThreadImpl;

  factory ChatThread.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatThread(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      type: jsonSerialization['type'] as String,
      title: jsonSerialization['title'] as String?,
      createdByAuthUserId: jsonSerialization['createdByAuthUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByAuthUserId'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  String type;

  String? title;

  _i1.UuidValue? createdByAuthUserId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [ChatThread]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatThread copyWith({
    _i1.UuidValue? id,
    String? type,
    String? title,
    _i1.UuidValue? createdByAuthUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatThread',
      'id': id.toJson(),
      'type': type,
      if (title != null) 'title': title,
      if (createdByAuthUserId != null)
        'createdByAuthUserId': createdByAuthUserId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatThreadImpl extends ChatThread {
  _ChatThreadImpl({
    _i1.UuidValue? id,
    required String type,
    String? title,
    _i1.UuidValue? createdByAuthUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         type: type,
         title: title,
         createdByAuthUserId: createdByAuthUserId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ChatThread]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatThread copyWith({
    _i1.UuidValue? id,
    String? type,
    Object? title = _Undefined,
    Object? createdByAuthUserId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatThread(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title is String? ? title : this.title,
      createdByAuthUserId: createdByAuthUserId is _i1.UuidValue?
          ? createdByAuthUserId
          : this.createdByAuthUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
