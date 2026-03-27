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

abstract class RegisteredDevice implements _i1.SerializableModel {
  RegisteredDevice._({
    this.id,
    required this.deviceId,
    required this.ownerAuthUserId,
    required this.platform,
    this.name,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastSeenAt = lastSeenAt ?? DateTime.now();

  factory RegisteredDevice({
    int? id,
    required String deviceId,
    required String ownerAuthUserId,
    required String platform,
    String? name,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) = _RegisteredDeviceImpl;

  factory RegisteredDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return RegisteredDevice(
      id: jsonSerialization['id'] as int?,
      deviceId: jsonSerialization['deviceId'] as String,
      ownerAuthUserId: jsonSerialization['ownerAuthUserId'] as String,
      platform: jsonSerialization['platform'] as String,
      name: jsonSerialization['name'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeenAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String deviceId;

  String ownerAuthUserId;

  String platform;

  String? name;

  DateTime createdAt;

  DateTime? lastSeenAt;

  /// Returns a shallow copy of this [RegisteredDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RegisteredDevice copyWith({
    int? id,
    String? deviceId,
    String? ownerAuthUserId,
    String? platform,
    String? name,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RegisteredDevice',
      if (id != null) 'id': id,
      'deviceId': deviceId,
      'ownerAuthUserId': ownerAuthUserId,
      'platform': platform,
      if (name != null) 'name': name,
      'createdAt': createdAt.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RegisteredDeviceImpl extends RegisteredDevice {
  _RegisteredDeviceImpl({
    int? id,
    required String deviceId,
    required String ownerAuthUserId,
    required String platform,
    String? name,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) : super._(
         id: id,
         deviceId: deviceId,
         ownerAuthUserId: ownerAuthUserId,
         platform: platform,
         name: name,
         createdAt: createdAt,
         lastSeenAt: lastSeenAt,
       );

  /// Returns a shallow copy of this [RegisteredDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RegisteredDevice copyWith({
    Object? id = _Undefined,
    String? deviceId,
    String? ownerAuthUserId,
    String? platform,
    Object? name = _Undefined,
    DateTime? createdAt,
    Object? lastSeenAt = _Undefined,
  }) {
    return RegisteredDevice(
      id: id is int? ? id : this.id,
      deviceId: deviceId ?? this.deviceId,
      ownerAuthUserId: ownerAuthUserId ?? this.ownerAuthUserId,
      platform: platform ?? this.platform,
      name: name is String? ? name : this.name,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt is DateTime? ? lastSeenAt : this.lastSeenAt,
    );
  }
}
