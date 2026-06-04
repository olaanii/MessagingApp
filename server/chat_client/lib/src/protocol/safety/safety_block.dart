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

/// Block list: blocker cannot receive social graph delivery from blocked (enforce in fan-out). ADR-0007.
abstract class SafetyBlock implements _i1.SerializableModel {
  SafetyBlock._({
    this.id,
    required this.blockerAuthUserId,
    required this.blockedAuthUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SafetyBlock({
    _i1.UuidValue? id,
    required _i1.UuidValue blockerAuthUserId,
    required _i1.UuidValue blockedAuthUserId,
    DateTime? createdAt,
  }) = _SafetyBlockImpl;

  factory SafetyBlock.fromJson(Map<String, dynamic> jsonSerialization) {
    return SafetyBlock(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      blockerAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['blockerAuthUserId'],
      ),
      blockedAuthUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['blockedAuthUserId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue blockerAuthUserId;

  _i1.UuidValue blockedAuthUserId;

  DateTime createdAt;

  /// Returns a shallow copy of this [SafetyBlock]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SafetyBlock copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? blockerAuthUserId,
    _i1.UuidValue? blockedAuthUserId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SafetyBlock',
      if (id != null) 'id': id?.toJson(),
      'blockerAuthUserId': blockerAuthUserId.toJson(),
      'blockedAuthUserId': blockedAuthUserId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SafetyBlockImpl extends SafetyBlock {
  _SafetyBlockImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue blockerAuthUserId,
    required _i1.UuidValue blockedAuthUserId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         blockerAuthUserId: blockerAuthUserId,
         blockedAuthUserId: blockedAuthUserId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SafetyBlock]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SafetyBlock copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? blockerAuthUserId,
    _i1.UuidValue? blockedAuthUserId,
    DateTime? createdAt,
  }) {
    return SafetyBlock(
      id: id is _i1.UuidValue? ? id : this.id,
      blockerAuthUserId: blockerAuthUserId ?? this.blockerAuthUserId,
      blockedAuthUserId: blockedAuthUserId ?? this.blockedAuthUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
