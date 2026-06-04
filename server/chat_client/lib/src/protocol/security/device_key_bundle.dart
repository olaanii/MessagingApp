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

abstract class DeviceKeyBundle implements _i1.SerializableModel {
  DeviceKeyBundle._({
    this.id,
    required this.authUserId,
    required this.deviceId,
    required this.bundleJson,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DeviceKeyBundle({
    int? id,
    required _i1.UuidValue authUserId,
    required String deviceId,
    required String bundleJson,
    DateTime? createdAt,
  }) = _DeviceKeyBundleImpl;

  factory DeviceKeyBundle.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeviceKeyBundle(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      deviceId: jsonSerialization['deviceId'] as String,
      bundleJson: jsonSerialization['bundleJson'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue authUserId;

  String deviceId;

  String bundleJson;

  DateTime createdAt;

  /// Returns a shallow copy of this [DeviceKeyBundle]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeviceKeyBundle copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    String? deviceId,
    String? bundleJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeviceKeyBundle',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'deviceId': deviceId,
      'bundleJson': bundleJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeviceKeyBundleImpl extends DeviceKeyBundle {
  _DeviceKeyBundleImpl({
    int? id,
    required _i1.UuidValue authUserId,
    required String deviceId,
    required String bundleJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         deviceId: deviceId,
         bundleJson: bundleJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DeviceKeyBundle]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeviceKeyBundle copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    String? deviceId,
    String? bundleJson,
    DateTime? createdAt,
  }) {
    return DeviceKeyBundle(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      deviceId: deviceId ?? this.deviceId,
      bundleJson: bundleJson ?? this.bundleJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
