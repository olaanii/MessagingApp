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

abstract class FirebaseAuthUser implements _i1.SerializableModel {
  FirebaseAuthUser._({
    this.id,
    required this.firebaseUid,
    required this.authUserId,
  });

  factory FirebaseAuthUser({
    int? id,
    required String firebaseUid,
    required _i1.UuidValue authUserId,
  }) = _FirebaseAuthUserImpl;

  factory FirebaseAuthUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return FirebaseAuthUser(
      id: jsonSerialization['id'] as int?,
      firebaseUid: jsonSerialization['firebaseUid'] as String,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String firebaseUid;

  _i1.UuidValue authUserId;

  /// Returns a shallow copy of this [FirebaseAuthUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FirebaseAuthUser copyWith({
    int? id,
    String? firebaseUid,
    _i1.UuidValue? authUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FirebaseAuthUser',
      if (id != null) 'id': id,
      'firebaseUid': firebaseUid,
      'authUserId': authUserId.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FirebaseAuthUserImpl extends FirebaseAuthUser {
  _FirebaseAuthUserImpl({
    int? id,
    required String firebaseUid,
    required _i1.UuidValue authUserId,
  }) : super._(
         id: id,
         firebaseUid: firebaseUid,
         authUserId: authUserId,
       );

  /// Returns a shallow copy of this [FirebaseAuthUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FirebaseAuthUser copyWith({
    Object? id = _Undefined,
    String? firebaseUid,
    _i1.UuidValue? authUserId,
  }) {
    return FirebaseAuthUser(
      id: id is int? ? id : this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      authUserId: authUserId ?? this.authUserId,
    );
  }
}
