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

abstract class PushToken implements _i1.SerializableModel {
  PushToken._({
    this.id,
    required this.authUserId,
    required this.deviceId,
    required this.token,
    required this.platform,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory PushToken({
    int? id,
    required _i1.UuidValue authUserId,
    required String deviceId,
    required String token,
    required String platform,
    DateTime? updatedAt,
  }) = _PushTokenImpl;

  factory PushToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return PushToken(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      deviceId: jsonSerialization['deviceId'] as String,
      token: jsonSerialization['token'] as String,
      platform: jsonSerialization['platform'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue authUserId;

  String deviceId;

  String token;

  String platform;

  DateTime updatedAt;

  /// Returns a shallow copy of this [PushToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PushToken copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    String? deviceId,
    String? token,
    String? platform,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PushToken',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'deviceId': deviceId,
      'token': token,
      'platform': platform,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PushTokenImpl extends PushToken {
  _PushTokenImpl({
    int? id,
    required _i1.UuidValue authUserId,
    required String deviceId,
    required String token,
    required String platform,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         deviceId: deviceId,
         token: token,
         platform: platform,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PushToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PushToken copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    String? deviceId,
    String? token,
    String? platform,
    DateTime? updatedAt,
  }) {
    return PushToken(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      deviceId: deviceId ?? this.deviceId,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
