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
import 'package:chat_client/src/protocol/messaging/chat_thread.dart' as _i9;
import 'package:chat_client/src/protocol/safety/safety_report.dart' as _i10;
import 'package:chat_client/src/stories/story_model.dart' as _i11;
import 'package:chat_client/src/protocol/streaming/chat_stream_envelope.dart'
    as _i12;
import 'package:chat_client/src/protocol/messaging/message_sync_page.dart'
    as _i13;
import 'protocol.dart' as _i14;

/// Device registry endpoint — lists active sessions and supports remote revoke,
/// plus [registerDevice] for ADR-0003 `device_id` binding (merged from pod messaging).
/// {@category Endpoint}
class EndpointDevice extends _i1.EndpointRef {
  EndpointDevice(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'device';

  /// Returns registered devices for the authenticated user.
  _i2.Future<List<String>> list() => caller.callServerEndpoint<List<String>>(
    'device',
    'list',
    {},
  );

  /// Revokes a device registration (removes from registered_device).
  _i2.Future<void> revoke(String deviceId) => caller.callServerEndpoint<void>(
    'device',
    'revoke',
    {'deviceId': deviceId},
  );

  /// Registers or updates a device for ADR-0003 `device_id` binding.
  _i2.Future<void> registerDevice(
    String deviceId,
    String platform,
    String? name,
  ) => caller.callServerEndpoint<void>(
    'device',
    'registerDevice',
    {
      'deviceId': deviceId,
      'platform': platform,
      'name': name,
    },
  );
}

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

/// Firebase phone/email sign-in endpoint for the chat server.
///
/// Verifies the Firebase ID token via the Serverpod Firebase IdP and issues a
/// Serverpod auth token pair. Configure `firebaseServiceAccountKey` in
/// `config/passwords.yaml` to enable token verification.
/// {@category Endpoint}
class EndpointFirebaseAuth extends _i4.EndpointFirebaseIdpBase {
  EndpointFirebaseAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'firebaseAuth';

  @override
  _i2.Future<_i3.AuthSuccess> login({required String idToken}) =>
      caller.callServerEndpoint<_i3.AuthSuccess>(
        'firebaseAuth',
        'login',
        {'idToken': idToken},
      );

  @override
  _i2.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'firebaseAuth',
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
  );
}

/// Push token registration endpoint.
///
/// Upserts a row in the `push_tokens` table so the server can deliver
/// FCM notifications to the device.
///
/// Requirements: 9.1, 9.5
/// {@category Endpoint}
class EndpointPush extends _i1.EndpointRef {
  EndpointPush(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'push';

  /// Registers (or updates) the FCM [token] for [userId] on [platform] and
  /// binds it to the stable [deviceId].
  ///
  /// [platform] is one of `'android'`, `'ios'`, or `'web'`.
  _i2.Future<void> registerToken(
    String userId,
    String deviceId,
    String token,
    String platform,
  ) => caller.callServerEndpoint<void>(
    'push',
    'registerToken',
    {
      'userId': userId,
      'deviceId': deviceId,
      'token': token,
      'platform': platform,
    },
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

/// WebRTC signaling endpoint (ADR-0004 / Requirement 4).
///
/// This endpoint only relays signaling metadata. It does not access audio or
/// video streams.
/// {@category Endpoint}
class EndpointCall extends _i1.EndpointRef {
  EndpointCall(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'call';

  _i2.Future<String> initiateCall(
    String chatId,
    String deviceId,
    String calleeAuthUserId,
    String callType,
    String sdpOfferJson,
  ) => caller.callServerEndpoint<String>(
    'call',
    'initiateCall',
    {
      'chatId': chatId,
      'deviceId': deviceId,
      'calleeAuthUserId': calleeAuthUserId,
      'callType': callType,
      'sdpOfferJson': sdpOfferJson,
    },
  );

  _i2.Future<void> answerCall(
    String chatId,
    String deviceId,
    String callId,
    String sdpAnswerJson,
  ) => caller.callServerEndpoint<void>(
    'call',
    'answerCall',
    {
      'chatId': chatId,
      'deviceId': deviceId,
      'callId': callId,
      'sdpAnswerJson': sdpAnswerJson,
    },
  );

  _i2.Future<void> rejectCall(
    String chatId,
    String deviceId,
    String callId,
    String reason,
  ) => caller.callServerEndpoint<void>(
    'call',
    'rejectCall',
    {
      'chatId': chatId,
      'deviceId': deviceId,
      'callId': callId,
      'reason': reason,
    },
  );

  _i2.Future<void> sendIceCandidate(
    String chatId,
    String deviceId,
    String callId,
    String candidateJson,
  ) => caller.callServerEndpoint<void>(
    'call',
    'sendIceCandidate',
    {
      'chatId': chatId,
      'deviceId': deviceId,
      'callId': callId,
      'candidateJson': candidateJson,
    },
  );

  _i2.Future<void> endCall(
    String chatId,
    String deviceId,
    String callId,
    String reason,
  ) => caller.callServerEndpoint<void>(
    'call',
    'endCall',
    {
      'chatId': chatId,
      'deviceId': deviceId,
      'callId': callId,
      'reason': reason,
    },
  );
}

/// Simple greeting/health-check endpoint.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  _i2.Future<_i5.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i5.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Media upload endpoint — delegates to [MediaRuntime.store] for slot management.
/// {@category Endpoint}
class EndpointMedia extends _i1.EndpointRef {
  EndpointMedia(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'media';

  _i2.Future<_i6.MediaUploadSlot> requestUpload(
    _i7.MediaUploadRequest request,
  ) => caller.callServerEndpoint<_i6.MediaUploadSlot>(
    'media',
    'requestUpload',
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

/// 1:1 and group threads (MVP: direct only helper).
/// {@category Endpoint}
class EndpointChat extends _i1.EndpointRef {
  EndpointChat(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chat';

  /// Opens or returns an existing direct thread with [otherAuthUserId].
  _i2.Future<_i9.ChatThread> openDirectChat(String otherAuthUserId) =>
      caller.callServerEndpoint<_i9.ChatThread>(
        'chat',
        'openDirectChat',
        {'otherAuthUserId': otherAuthUserId},
      );

  _i2.Future<_i9.ChatThread> createGroupChat(
    String? title,
    List<String> memberAuthUserIds,
  ) => caller.callServerEndpoint<_i9.ChatThread>(
    'chat',
    'createGroupChat',
    {
      'title': title,
      'memberAuthUserIds': memberAuthUserIds,
    },
  );

  _i2.Future<_i9.ChatThread> getChatDetails(_i1.UuidValue chatId) =>
      caller.callServerEndpoint<_i9.ChatThread>(
        'chat',
        'getChatDetails',
        {'chatId': chatId},
      );

  _i2.Future<void> addGroupMembers(
    _i1.UuidValue chatId,
    List<String> memberAuthUserIds,
  ) => caller.callServerEndpoint<void>(
    'chat',
    'addGroupMembers',
    {
      'chatId': chatId,
      'memberAuthUserIds': memberAuthUserIds,
    },
  );

  _i2.Future<void> removeGroupMember(
    _i1.UuidValue chatId,
    String memberAuthUserId,
  ) => caller.callServerEndpoint<void>(
    'chat',
    'removeGroupMember',
    {
      'chatId': chatId,
      'memberAuthUserId': memberAuthUserId,
    },
  );

  /// Lists chat threads where the caller is a member, newest-updated first.
  _i2.Future<List<_i9.ChatThread>> listMyChats() =>
      caller.callServerEndpoint<List<_i9.ChatThread>>(
        'chat',
        'listMyChats',
        {},
      );
}

/// Store compliance: report + block (ADR-0007).
/// {@category Endpoint}
class EndpointSafety extends _i1.EndpointRef {
  EndpointSafety(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'safety';

  _i2.Future<_i10.SafetyReport> submitReport({
    String? targetUserId,
    String? targetChatId,
    String? targetMessageId,
    required String reason,
  }) => caller.callServerEndpoint<_i10.SafetyReport>(
    'safety',
    'submitReport',
    {
      'targetUserId': targetUserId,
      'targetChatId': targetChatId,
      'targetMessageId': targetMessageId,
      'reason': reason,
    },
  );

  _i2.Future<void> blockUser(String blockedAuthUserId) =>
      caller.callServerEndpoint<void>(
        'safety',
        'blockUser',
        {'blockedAuthUserId': blockedAuthUserId},
      );

  _i2.Future<void> unblockUser(String blockedAuthUserId) =>
      caller.callServerEndpoint<void>(
        'safety',
        'unblockUser',
        {'blockedAuthUserId': blockedAuthUserId},
      );
}

/// Server-side key management endpoint for E2EE key distribution.
///
/// Stores and retrieves X25519 public key bundles and wrapped chat key
/// envelopes in the `device_keys` table.
///
/// Table schema (must exist before this endpoint is used):
/// ```sql
/// CREATE TABLE device_keys (
///   id          uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
///   auth_user_id uuid NOT NULL,
///   device_id   text NOT NULL,
///   bundle_json text NOT NULL,   -- JSON-encoded PublicKeyBundle
///   created_at  timestamp NOT NULL DEFAULT now(),
///   UNIQUE (auth_user_id, device_id)
/// );
///
/// CREATE TABLE wrapped_chat_keys (
///   id          uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
///   chat_id     text NOT NULL,
///   recipient_auth_user_id uuid NOT NULL,
///   envelope_json text NOT NULL, -- JSON-encoded WrappedChatKeyEnvelope
///   created_at  timestamp NOT NULL DEFAULT now()
/// );
/// ```
///
/// Requirements: 6.1, 6.2
/// {@category Endpoint}
class EndpointKey extends _i1.EndpointRef {
  EndpointKey(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'key';

  /// Upload the caller's [PublicKeyBundle] for [deviceId].
  ///
  /// Upserts the row so re-registration (e.g. after key rotation) is safe.
  ///
  /// [bundleJson] is a JSON-encoded map with fields:
  ///   - `schemaVersion` (int)
  ///   - `x25519Public` (base64-encoded 32-byte public key)
  _i2.Future<void> uploadBundle(
    String deviceId,
    String bundleJson,
  ) => caller.callServerEndpoint<void>(
    'key',
    'uploadBundle',
    {
      'deviceId': deviceId,
      'bundleJson': bundleJson,
    },
  );

  /// Fetch the most-recently uploaded [PublicKeyBundle] for [userId].
  ///
  /// Returns the JSON-encoded bundle string, or `null` if no bundle exists.
  _i2.Future<String?> fetchUserBundle(String userId) =>
      caller.callServerEndpoint<String?>(
        'key',
        'fetchUserBundle',
        {'userId': userId},
      );

  /// Upload a batch of wrapped chat key envelopes for [chatId].
  ///
  /// Each element of [envelopesJson] is a JSON-encoded map with fields:
  ///   - `recipientAuthUserId` (String UUID)
  ///   - `schemaVersion` (int)
  ///   - `ephemeralPublic` (base64)
  ///   - `nonce` (base64)
  ///   - `ciphertextWithMac` (base64)
  ///
  /// Existing envelopes for the same (chatId, recipientAuthUserId) are
  /// replaced so that key rotation is idempotent.
  _i2.Future<void> uploadWrappedKeys(
    String chatId,
    List<String> envelopesJson,
  ) => caller.callServerEndpoint<void>(
    'key',
    'uploadWrappedKeys',
    {
      'chatId': chatId,
      'envelopesJson': envelopesJson,
    },
  );
}

/// Ephemeral stories / posts endpoint (ADR-0002).
///
/// Stories are encrypted before leaving the client; the server only stores
/// ciphertext and enforces the 24-hour TTL.
///
/// Requirements: 7.1, 7.2, 7.3, 7.4, 7.9
/// {@category Endpoint}
class EndpointStory extends _i1.EndpointRef {
  EndpointStory(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'story';

  /// Upload a new encrypted story.
  ///
  /// [mediaType]  – `"image"`, `"video"`, or `"text"`.
  /// [encryptedPayload]  – base64 ciphertext from the E2EE module.
  /// [nonce]  – base64 nonce used for encryption.
  /// [privacy]  – `"all_contacts"`, `"selected"`, or `"public"`.
  /// [selectedViewerIds]  – comma-separated auth-user UUIDs when [privacy]="selected".
  ///
  /// Expires 24 h after creation.
  _i2.Future<_i11.Story> createStory({
    required String mediaType,
    required String encryptedPayload,
    required String nonce,
    String? thumbnailCiphertext,
    required String privacy,
    String? selectedViewerIds,
  }) => caller.callServerEndpoint<_i11.Story>(
    'story',
    'createStory',
    {
      'mediaType': mediaType,
      'encryptedPayload': encryptedPayload,
      'nonce': nonce,
      'thumbnailCiphertext': thumbnailCiphertext,
      'privacy': privacy,
      'selectedViewerIds': selectedViewerIds,
    },
  );

  /// List non-expired stories from contacts (reverse-chronological).
  ///
  /// Returns only stories whose `expiresAt` is in the future.
  /// The [limit] is clamped to [1..50].
  _i2.Future<List<_i11.Story>> listStories({
    String? forAuthUserId,
    required int limit,
  }) => caller.callServerEndpoint<List<_i11.Story>>(
    'story',
    'listStories',
    {
      'forAuthUserId': forAuthUserId,
      'limit': limit,
    },
  );

  /// Mark [storyId] as viewed by the caller.
  ///
  /// Idempotent – duplicate calls are silently ignored (unique constraint).
  _i2.Future<void> viewStory({required String storyId}) =>
      caller.callServerEndpoint<void>(
        'story',
        'viewStory',
        {'storyId': storyId},
      );

  /// Return the list of viewer IDs for [storyId] (author only).
  _i2.Future<List<String>> getViewers({required String storyId}) =>
      caller.callServerEndpoint<List<String>>(
        'story',
        'getViewers',
        {'storyId': storyId},
      );

  /// Delete [storyId] – only the author may do this.
  _i2.Future<void> deleteStory({required String storyId}) =>
      caller.callServerEndpoint<void>(
        'story',
        'deleteStory',
        {'storyId': storyId},
      );

  /// Server-side cleanup for expired stories.
  ///
  /// Intended to be called by [StoryExpirationScheduler] every hour.
  _i2.Future<int> cleanupExpired() => caller.callServerEndpoint<int>(
    'story',
    'cleanupExpired',
    {},
  );
}

/// {@category Endpoint}
class EndpointChatStream extends _i1.EndpointRef {
  EndpointChatStream(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chatStream';

  _i2.Stream<_i12.ChatStreamEnvelope> chatRoom(
    String chatId,
    String deviceId,
    _i2.Stream<_i12.ChatStreamEnvelope> inbound,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i12.ChatStreamEnvelope>,
        _i12.ChatStreamEnvelope
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

/// Incremental sync endpoint for chat changes.
/// {@category Endpoint}
class EndpointSync extends _i1.EndpointRef {
  EndpointSync(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sync';

  _i2.Future<_i13.MessageSyncPage> getChanges(
    String? cursor,
    int limit,
  ) => caller.callServerEndpoint<_i13.MessageSyncPage>(
    'sync',
    'getChanges',
    {
      'cursor': cursor,
      'limit': limit,
    },
  );

  _i2.Future<_i13.MessageSyncPage> getChatChanges(
    String chatId,
    String? cursor,
    int limit,
  ) => caller.callServerEndpoint<_i13.MessageSyncPage>(
    'sync',
    'getChatChanges',
    {
      'chatId': chatId,
      'cursor': cursor,
      'limit': limit,
    },
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
         _i14.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    device = EndpointDevice(this);
    emailIdp = EndpointEmailIdp(this);
    firebaseAuth = EndpointFirebaseAuth(this);
    jwtRefresh = EndpointJwtRefresh(this);
    push = EndpointPush(this);
    throttledEmailIdp = EndpointThrottledEmailIdp(this);
    call = EndpointCall(this);
    greeting = EndpointGreeting(this);
    media = EndpointMedia(this);
    chat = EndpointChat(this);
    safety = EndpointSafety(this);
    key = EndpointKey(this);
    story = EndpointStory(this);
    chatStream = EndpointChatStream(this);
    sync = EndpointSync(this);
    modules = Modules(this);
  }

  late final EndpointDevice device;

  late final EndpointEmailIdp emailIdp;

  late final EndpointFirebaseAuth firebaseAuth;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointPush push;

  late final EndpointThrottledEmailIdp throttledEmailIdp;

  late final EndpointCall call;

  late final EndpointGreeting greeting;

  late final EndpointMedia media;

  late final EndpointChat chat;

  late final EndpointSafety safety;

  late final EndpointKey key;

  late final EndpointStory story;

  late final EndpointChatStream chatStream;

  late final EndpointSync sync;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'device': device,
    'emailIdp': emailIdp,
    'firebaseAuth': firebaseAuth,
    'jwtRefresh': jwtRefresh,
    'push': push,
    'throttledEmailIdp': throttledEmailIdp,
    'call': call,
    'greeting': greeting,
    'media': media,
    'chat': chat,
    'safety': safety,
    'key': key,
    'story': story,
    'chatStream': chatStream,
    'sync': sync,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
