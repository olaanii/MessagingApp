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
import 'dart:async' as _i2;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i3;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i4;
import 'package:chat_client/src/protocol/greetings/greeting.dart' as _i5;
import 'package:chat_client/src/protocol/media/media_upload_slot.dart' as _i6;
import 'package:chat_client/src/protocol/media/media_upload_request.dart'
    as _i7;
import 'package:chat_client/src/protocol/media/media_finalize_result.dart'
    as _i8;
import 'package:chat_client/src/protocol/safety/safety_report.dart' as _i9;
import 'package:chat_client/src/protocol/streaming/chat_stream_envelope.dart'
    as _i10;
import 'protocol.dart' as _i11;

/// Email IdP with ADR-0007 rate limits on login / registration / password reset.
/// {@category Endpoint}
class EndpointEmailIdp extends EndpointThrottledEmailIdp {
  EndpointEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  @override
  _i2.Future<_i3.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i3.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  @override
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i2.Future<_i3.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i3.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// JWT refresh with ADR-0007 per-IP throttling.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i3.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  @override
  _i2.Future<_i3.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i3.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// [EmailIdpBaseEndpoint] with ADR-0007 IP + per-email throttles on hot paths.
/// {@category Endpoint}
class EndpointThrottledEmailIdp extends _i4.EndpointEmailIdpBase {
  EndpointThrottledEmailIdp(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'throttledEmailIdp';

  @override
  _i2.Future<_i3.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i3.AuthSuccess>(
    'throttledEmailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  @override
  _i2.Future<_i1.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'throttledEmailIdp',
        'startRegistration',
        {'email': email},
      );

  @override
  _i2.Future<_i1.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'throttledEmailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i2.Future<String> verifyRegistrationCode({
    required _i1.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'throttledEmailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i2.Future<_i3.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i3.AuthSuccess>(
    'throttledEmailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i2.Future<String> verifyPasswordResetCode({
    required _i1.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'throttledEmailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i2.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'throttledEmailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'throttledEmailIdp',
    'hasAccount',
    {},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i5.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i5.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// RPC for media slots + finalize. Binary bytes use [MediaBlobRoute] (presign-style URL).
/// {@category Endpoint}
class EndpointMedia extends _i1.EndpointRef {
  EndpointMedia(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'media';

  _i2.Future<_i6.MediaUploadSlot> requestUploadSlot(
    _i7.MediaUploadRequest request,
  ) => caller.callServerEndpoint<_i6.MediaUploadSlot>(
    'media',
    'requestUploadSlot',
    {'request': request},
  );

  _i2.Future<_i8.MediaFinalizeResult> finalizeUpload(
    String mediaId,
    String finalizeToken,
    int declaredTotalBytes,
  ) => caller.callServerEndpoint<_i8.MediaFinalizeResult>(
    'media',
    'finalizeUpload',
    {
      'mediaId': mediaId,
      'finalizeToken': finalizeToken,
      'declaredTotalBytes': declaredTotalBytes,
    },
  );
}

/// Store compliance: report + block (ADR-0007). Requires authenticated Serverpod user.
/// {@category Endpoint}
class EndpointSafety extends _i1.EndpointRef {
  EndpointSafety(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'safety';

  /// At least one of [targetUserId], [targetChatId], [targetMessageId] must be set.
  /// [reason] is user-facing category + short text; max 2000 chars server-side.
  _i2.Future<_i9.SafetyReport> submitReport({
    String? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) => caller.callServerEndpoint<_i9.SafetyReport>(
    'safety',
    'submitReport',
    {
      'targetUserId': targetUserId,
      'targetChatId': targetChatId,
      'targetMessageId': targetMessageId,
      'reason': reason,
    },
  );

  /// Idempotent block row; [blockedAuthUserId] is Serverpod auth user UUID string.
  _i2.Future<void> blockUser(String blockedAuthUserId) =>
      caller.callServerEndpoint<void>(
        'safety',
        'blockUser',
        {'blockedAuthUserId': blockedAuthUserId},
      );
}

/// {@category Endpoint}
class EndpointChatStream extends _i1.EndpointRef {
  EndpointChatStream(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chatStream';

  _i2.Stream<_i10.ChatStreamEnvelope> chatRoom(
    String chatId,
    String deviceId,
    _i2.Stream<_i10.ChatStreamEnvelope> inbound,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i10.ChatStreamEnvelope>,
        _i10.ChatStreamEnvelope
      >(
        'chatStream',
        'chatRoom',
        {
          'chatId': chatId,
          'deviceId': deviceId,
        },
        {'inbound': inbound},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i4.Caller(client);
    serverpod_auth_core = _i3.Caller(client);
  }

  late final _i4.Caller serverpod_auth_idp;

  late final _i3.Caller serverpod_auth_core;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i11.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    throttledEmailIdp = EndpointThrottledEmailIdp(this);
    greeting = EndpointGreeting(this);
    media = EndpointMedia(this);
    safety = EndpointSafety(this);
    chatStream = EndpointChatStream(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointThrottledEmailIdp throttledEmailIdp;

  late final EndpointGreeting greeting;

  late final EndpointMedia media;

  late final EndpointSafety safety;

  late final EndpointChatStream chatStream;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'throttledEmailIdp': throttledEmailIdp,
    'greeting': greeting,
    'media': media,
    'safety': safety,
    'chatStream': chatStream,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
