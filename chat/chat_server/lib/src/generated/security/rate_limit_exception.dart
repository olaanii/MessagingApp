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

/// Serializable rate / abuse limit rejection (ADR-0007). Client may map [code] to UX.
abstract class RateLimitException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  RateLimitException._({
    required this.code,
    required this.message,
  });

  factory RateLimitException({
    required String code,
    required String message,
  }) = _RateLimitExceptionImpl;

  factory RateLimitException.fromJson(Map<String, dynamic> jsonSerialization) {
    return RateLimitException(
      code: jsonSerialization['code'] as String,
      message: jsonSerialization['message'] as String,
    );
  }

  String code;

  String message;

  /// Returns a shallow copy of this [RateLimitException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RateLimitException copyWith({
    String? code,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RateLimitException',
      'code': code,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RateLimitException',
      'code': code,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'RateLimitException(code: $code, message: $message)';
  }
}

class _RateLimitExceptionImpl extends RateLimitException {
  _RateLimitExceptionImpl({
    required String code,
    required String message,
  }) : super._(
         code: code,
         message: message,
       );

  /// Returns a shallow copy of this [RateLimitException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RateLimitException copyWith({
    String? code,
    String? message,
  }) {
    return RateLimitException(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}
