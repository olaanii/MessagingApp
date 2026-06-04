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
import '../auth/device_endpoint.dart' as _i2;
import '../auth/email_idp_endpoint.dart' as _i3;
import '../auth/firebase_auth_endpoint.dart' as _i4;
import '../auth/jwt_refresh_endpoint.dart' as _i5;
import '../auth/push_endpoint.dart' as _i6;
import '../auth/throttled_email_idp_endpoint.dart' as _i7;
import '../calls/call_endpoint.dart' as _i8;
import '../greetings/greeting_endpoint.dart' as _i9;
import '../media/media_endpoint.dart' as _i10;
import '../messaging/chat_endpoint.dart' as _i11;
import '../safety/safety_endpoint.dart' as _i12;
import '../security/key_endpoint.dart' as _i13;
import '../stories/story_endpoint.dart' as _i14;
import '../streaming/chat_stream_endpoint.dart' as _i15;
import '../sync/sync_endpoint.dart' as _i16;
import 'package:chat_server/src/generated/media/media_upload_request.dart'
    as _i17;
import 'package:chat_server/src/generated/streaming/chat_stream_envelope.dart'
    as _i18;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i19;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i20;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'device': _i2.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          null,
        ),
      'emailIdp': _i3.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'firebaseAuth': _i4.FirebaseAuthEndpoint()
        ..initialize(
          server,
          'firebaseAuth',
          null,
        ),
      'jwtRefresh': _i5.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'push': _i6.PushEndpoint()
        ..initialize(
          server,
          'push',
          null,
        ),
      'throttledEmailIdp': _i7.ThrottledEmailIdpEndpoint()
        ..initialize(
          server,
          'throttledEmailIdp',
          null,
        ),
      'call': _i8.CallEndpoint()
        ..initialize(
          server,
          'call',
          null,
        ),
      'greeting': _i9.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'media': _i10.MediaEndpoint()
        ..initialize(
          server,
          'media',
          null,
        ),
      'chat': _i11.ChatEndpoint()
        ..initialize(
          server,
          'chat',
          null,
        ),
      'safety': _i12.SafetyEndpoint()
        ..initialize(
          server,
          'safety',
          null,
        ),
      'key': _i13.KeyEndpoint()
        ..initialize(
          server,
          'key',
          null,
        ),
      'story': _i14.StoryEndpoint()
        ..initialize(
          server,
          'story',
          null,
        ),
      'chatStream': _i15.ChatStreamEndpoint()
        ..initialize(
          server,
          'chatStream',
          null,
        ),
      'sync': _i16.SyncEndpoint()
        ..initialize(
          server,
          'sync',
          null,
        ),
    };
    connectors['device'] = _i1.EndpointConnector(
      name: 'device',
      endpoint: endpoints['device']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['device'] as _i2.DeviceEndpoint).list(session),
        ),
        'revoke': _i1.MethodConnector(
          name: 'revoke',
          params: {
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['device'] as _i2.DeviceEndpoint).revoke(
                session,
                params['deviceId'],
              ),
        ),
        'registerDevice': _i1.MethodConnector(
          name: 'registerDevice',
          params: {
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'platform': _i1.ParameterDescription(
              name: 'platform',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['device'] as _i2.DeviceEndpoint).registerDevice(
                    session,
                    params['deviceId'],
                    params['platform'],
                    params['name'],
                  ),
        ),
      },
    );
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i3.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['firebaseAuth'] = _i1.EndpointConnector(
      name: 'firebaseAuth',
      endpoint: endpoints['firebaseAuth']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'idToken': _i1.ParameterDescription(
              name: 'idToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['firebaseAuth'] as _i4.FirebaseAuthEndpoint).login(
                    session,
                    idToken: params['idToken'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['firebaseAuth'] as _i4.FirebaseAuthEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i5.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['push'] = _i1.EndpointConnector(
      name: 'push',
      endpoint: endpoints['push']!,
      methodConnectors: {
        'registerToken': _i1.MethodConnector(
          name: 'registerToken',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'platform': _i1.ParameterDescription(
              name: 'platform',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['push'] as _i6.PushEndpoint).registerToken(
                session,
                params['userId'],
                params['deviceId'],
                params['token'],
                params['platform'],
              ),
        ),
      },
    );
    connectors['throttledEmailIdp'] = _i1.EndpointConnector(
      name: 'throttledEmailIdp',
      endpoint: endpoints['throttledEmailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['throttledEmailIdp']
                          as _i7.ThrottledEmailIdpEndpoint)
                      .login(
                        session,
                        email: params['email'],
                        password: params['password'],
                      ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['throttledEmailIdp']
                          as _i7.ThrottledEmailIdpEndpoint)
                      .startRegistration(
                        session,
                        email: params['email'],
                      ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['throttledEmailIdp']
                          as _i7.ThrottledEmailIdpEndpoint)
                      .startPasswordReset(
                        session,
                        email: params['email'],
                      ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['throttledEmailIdp']
                          as _i7.ThrottledEmailIdpEndpoint)
                      .verifyRegistrationCode(
                        session,
                        accountRequestId: params['accountRequestId'],
                        verificationCode: params['verificationCode'],
                      ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['throttledEmailIdp']
                          as _i7.ThrottledEmailIdpEndpoint)
                      .finishRegistration(
                        session,
                        registrationToken: params['registrationToken'],
                        password: params['password'],
                      ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['throttledEmailIdp']
                          as _i7.ThrottledEmailIdpEndpoint)
                      .verifyPasswordResetCode(
                        session,
                        passwordResetRequestId:
                            params['passwordResetRequestId'],
                        verificationCode: params['verificationCode'],
                      ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['throttledEmailIdp']
                          as _i7.ThrottledEmailIdpEndpoint)
                      .finishPasswordReset(
                        session,
                        finishPasswordResetToken:
                            params['finishPasswordResetToken'],
                        newPassword: params['newPassword'],
                      ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['throttledEmailIdp']
                          as _i7.ThrottledEmailIdpEndpoint)
                      .hasAccount(session),
        ),
      },
    );
    connectors['call'] = _i1.EndpointConnector(
      name: 'call',
      endpoint: endpoints['call']!,
      methodConnectors: {
        'initiateCall': _i1.MethodConnector(
          name: 'initiateCall',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'calleeAuthUserId': _i1.ParameterDescription(
              name: 'calleeAuthUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callType': _i1.ParameterDescription(
              name: 'callType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sdpOfferJson': _i1.ParameterDescription(
              name: 'sdpOfferJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['call'] as _i8.CallEndpoint).initiateCall(
                session,
                params['chatId'],
                params['deviceId'],
                params['calleeAuthUserId'],
                params['callType'],
                params['sdpOfferJson'],
              ),
        ),
        'answerCall': _i1.MethodConnector(
          name: 'answerCall',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callId': _i1.ParameterDescription(
              name: 'callId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sdpAnswerJson': _i1.ParameterDescription(
              name: 'sdpAnswerJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['call'] as _i8.CallEndpoint).answerCall(
                session,
                params['chatId'],
                params['deviceId'],
                params['callId'],
                params['sdpAnswerJson'],
              ),
        ),
        'rejectCall': _i1.MethodConnector(
          name: 'rejectCall',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callId': _i1.ParameterDescription(
              name: 'callId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['call'] as _i8.CallEndpoint).rejectCall(
                session,
                params['chatId'],
                params['deviceId'],
                params['callId'],
                params['reason'],
              ),
        ),
        'sendIceCandidate': _i1.MethodConnector(
          name: 'sendIceCandidate',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callId': _i1.ParameterDescription(
              name: 'callId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'candidateJson': _i1.ParameterDescription(
              name: 'candidateJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['call'] as _i8.CallEndpoint).sendIceCandidate(
                    session,
                    params['chatId'],
                    params['deviceId'],
                    params['callId'],
                    params['candidateJson'],
                  ),
        ),
        'endCall': _i1.MethodConnector(
          name: 'endCall',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'callId': _i1.ParameterDescription(
              name: 'callId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['call'] as _i8.CallEndpoint).endCall(
                session,
                params['chatId'],
                params['deviceId'],
                params['callId'],
                params['reason'],
              ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i9.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['media'] = _i1.EndpointConnector(
      name: 'media',
      endpoint: endpoints['media']!,
      methodConnectors: {
        'requestUpload': _i1.MethodConnector(
          name: 'requestUpload',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i17.MediaUploadRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['media'] as _i10.MediaEndpoint).requestUpload(
                    session,
                    params['request'],
                  ),
        ),
        'finalizeUpload': _i1.MethodConnector(
          name: 'finalizeUpload',
          params: {
            'mediaId': _i1.ParameterDescription(
              name: 'mediaId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'finalizeToken': _i1.ParameterDescription(
              name: 'finalizeToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'declaredTotalBytes': _i1.ParameterDescription(
              name: 'declaredTotalBytes',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['media'] as _i10.MediaEndpoint).finalizeUpload(
                    session,
                    params['mediaId'],
                    params['finalizeToken'],
                    params['declaredTotalBytes'],
                  ),
        ),
      },
    );
    connectors['chat'] = _i1.EndpointConnector(
      name: 'chat',
      endpoint: endpoints['chat']!,
      methodConnectors: {
        'openDirectChat': _i1.MethodConnector(
          name: 'openDirectChat',
          params: {
            'otherAuthUserId': _i1.ParameterDescription(
              name: 'otherAuthUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i11.ChatEndpoint).openDirectChat(
                    session,
                    params['otherAuthUserId'],
                  ),
        ),
        'createGroupChat': _i1.MethodConnector(
          name: 'createGroupChat',
          params: {
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'memberAuthUserIds': _i1.ParameterDescription(
              name: 'memberAuthUserIds',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i11.ChatEndpoint).createGroupChat(
                    session,
                    params['title'],
                    params['memberAuthUserIds'],
                  ),
        ),
        'getChatDetails': _i1.MethodConnector(
          name: 'getChatDetails',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i11.ChatEndpoint).getChatDetails(
                    session,
                    params['chatId'],
                  ),
        ),
        'addGroupMembers': _i1.MethodConnector(
          name: 'addGroupMembers',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'memberAuthUserIds': _i1.ParameterDescription(
              name: 'memberAuthUserIds',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i11.ChatEndpoint).addGroupMembers(
                    session,
                    params['chatId'],
                    params['memberAuthUserIds'],
                  ),
        ),
        'removeGroupMember': _i1.MethodConnector(
          name: 'removeGroupMember',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'memberAuthUserId': _i1.ParameterDescription(
              name: 'memberAuthUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i11.ChatEndpoint).removeGroupMember(
                    session,
                    params['chatId'],
                    params['memberAuthUserId'],
                  ),
        ),
        'listMyChats': _i1.MethodConnector(
          name: 'listMyChats',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i11.ChatEndpoint).listMyChats(session),
        ),
      },
    );
    connectors['safety'] = _i1.EndpointConnector(
      name: 'safety',
      endpoint: endpoints['safety']!,
      methodConnectors: {
        'submitReport': _i1.MethodConnector(
          name: 'submitReport',
          params: {
            'targetUserId': _i1.ParameterDescription(
              name: 'targetUserId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'targetChatId': _i1.ParameterDescription(
              name: 'targetChatId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'targetMessageId': _i1.ParameterDescription(
              name: 'targetMessageId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['safety'] as _i12.SafetyEndpoint).submitReport(
                    session,
                    targetUserId: params['targetUserId'],
                    targetChatId: params['targetChatId'],
                    targetMessageId: params['targetMessageId'],
                    reason: params['reason'],
                  ),
        ),
        'blockUser': _i1.MethodConnector(
          name: 'blockUser',
          params: {
            'blockedAuthUserId': _i1.ParameterDescription(
              name: 'blockedAuthUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['safety'] as _i12.SafetyEndpoint).blockUser(
                session,
                params['blockedAuthUserId'],
              ),
        ),
        'unblockUser': _i1.MethodConnector(
          name: 'unblockUser',
          params: {
            'blockedAuthUserId': _i1.ParameterDescription(
              name: 'blockedAuthUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['safety'] as _i12.SafetyEndpoint).unblockUser(
                    session,
                    params['blockedAuthUserId'],
                  ),
        ),
      },
    );
    connectors['key'] = _i1.EndpointConnector(
      name: 'key',
      endpoint: endpoints['key']!,
      methodConnectors: {
        'uploadBundle': _i1.MethodConnector(
          name: 'uploadBundle',
          params: {
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'bundleJson': _i1.ParameterDescription(
              name: 'bundleJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['key'] as _i13.KeyEndpoint).uploadBundle(
                session,
                params['deviceId'],
                params['bundleJson'],
              ),
        ),
        'fetchUserBundle': _i1.MethodConnector(
          name: 'fetchUserBundle',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['key'] as _i13.KeyEndpoint).fetchUserBundle(
                session,
                params['userId'],
              ),
        ),
        'uploadWrappedKeys': _i1.MethodConnector(
          name: 'uploadWrappedKeys',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'envelopesJson': _i1.ParameterDescription(
              name: 'envelopesJson',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['key'] as _i13.KeyEndpoint).uploadWrappedKeys(
                    session,
                    params['chatId'],
                    params['envelopesJson'],
                  ),
        ),
      },
    );
    connectors['story'] = _i1.EndpointConnector(
      name: 'story',
      endpoint: endpoints['story']!,
      methodConnectors: {
        'createStory': _i1.MethodConnector(
          name: 'createStory',
          params: {
            'mediaType': _i1.ParameterDescription(
              name: 'mediaType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'encryptedPayload': _i1.ParameterDescription(
              name: 'encryptedPayload',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'nonce': _i1.ParameterDescription(
              name: 'nonce',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'thumbnailCiphertext': _i1.ParameterDescription(
              name: 'thumbnailCiphertext',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'privacy': _i1.ParameterDescription(
              name: 'privacy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'selectedViewerIds': _i1.ParameterDescription(
              name: 'selectedViewerIds',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['story'] as _i14.StoryEndpoint).createStory(
                session,
                mediaType: params['mediaType'],
                encryptedPayload: params['encryptedPayload'],
                nonce: params['nonce'],
                thumbnailCiphertext: params['thumbnailCiphertext'],
                privacy: params['privacy'],
                selectedViewerIds: params['selectedViewerIds'],
              ),
        ),
        'listStories': _i1.MethodConnector(
          name: 'listStories',
          params: {
            'forAuthUserId': _i1.ParameterDescription(
              name: 'forAuthUserId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['story'] as _i14.StoryEndpoint).listStories(
                session,
                forAuthUserId: params['forAuthUserId'],
                limit: params['limit'],
              ),
        ),
        'viewStory': _i1.MethodConnector(
          name: 'viewStory',
          params: {
            'storyId': _i1.ParameterDescription(
              name: 'storyId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['story'] as _i14.StoryEndpoint).viewStory(
                session,
                storyId: params['storyId'],
              ),
        ),
        'getViewers': _i1.MethodConnector(
          name: 'getViewers',
          params: {
            'storyId': _i1.ParameterDescription(
              name: 'storyId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['story'] as _i14.StoryEndpoint).getViewers(
                session,
                storyId: params['storyId'],
              ),
        ),
        'deleteStory': _i1.MethodConnector(
          name: 'deleteStory',
          params: {
            'storyId': _i1.ParameterDescription(
              name: 'storyId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['story'] as _i14.StoryEndpoint).deleteStory(
                session,
                storyId: params['storyId'],
              ),
        ),
        'cleanupExpired': _i1.MethodConnector(
          name: 'cleanupExpired',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['story'] as _i14.StoryEndpoint)
                  .cleanupExpired(session),
        ),
      },
    );
    connectors['chatStream'] = _i1.EndpointConnector(
      name: 'chatStream',
      endpoint: endpoints['chatStream']!,
      methodConnectors: {
        'chatRoom': _i1.MethodStreamConnector(
          name: 'chatRoom',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {
            'inbound': _i1.StreamParameterDescription<_i18.ChatStreamEnvelope>(
              name: 'inbound',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) =>
                  (endpoints['chatStream'] as _i15.ChatStreamEndpoint).chatRoom(
                    session,
                    params['chatId'],
                    params['deviceId'],
                    streamParams['inbound']!.cast<_i18.ChatStreamEnvelope>(),
                  ),
        ),
      },
    );
    connectors['sync'] = _i1.EndpointConnector(
      name: 'sync',
      endpoint: endpoints['sync']!,
      methodConnectors: {
        'getChanges': _i1.MethodConnector(
          name: 'getChanges',
          params: {
            'cursor': _i1.ParameterDescription(
              name: 'cursor',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['sync'] as _i16.SyncEndpoint).getChanges(
                session,
                params['cursor'],
                params['limit'],
              ),
        ),
        'getChatChanges': _i1.MethodConnector(
          name: 'getChatChanges',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'cursor': _i1.ParameterDescription(
              name: 'cursor',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sync'] as _i16.SyncEndpoint).getChatChanges(
                    session,
                    params['chatId'],
                    params['cursor'],
                    params['limit'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i19.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i20.Endpoints()
      ..initializeEndpoints(server);
  }
}
