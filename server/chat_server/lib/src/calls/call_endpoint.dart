import 'dart:convert';

import 'package:chat_server/src/generated/streaming/chat_stream_envelope.dart';
import 'package:chat_server/src/security/security_guards.dart';
import 'package:chat_server/src/streaming/chat_stream_hub.dart';
import 'package:serverpod/serverpod.dart';

/// WebRTC signaling endpoint (ADR-0004 / Requirement 4).
///
/// This endpoint only relays signaling metadata. It does not access audio or
/// video streams.
class CallEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> initiateCall(
    Session session,
    String chatId,
    String deviceId,
    String calleeAuthUserId,
    String callType,
    String sdpOfferJson,
  ) async {
    SecurityGuards.requireRpcAllowed(session);
    await _assertMember(session, chatId, session.authenticated!.userIdentifier);

    final normalizedCallType = _normalizeCallType(callType);
    final callId = const Uuid().v4();
    final callerId = session.authenticated!.userIdentifier;

    await _broadcast(
      session: session,
      chatId: chatId,
      exceptDeviceId: deviceId,
      type: 'call_offer',
      payload: {
        'callId': callId,
        'callerId': callerId,
        'calleeId': calleeAuthUserId,
        'callType': normalizedCallType,
        'sdpOfferJson': sdpOfferJson,
      },
    );

    return callId;
  }

  Future<void> answerCall(
    Session session,
    String chatId,
    String deviceId,
    String callId,
    String sdpAnswerJson,
  ) async {
    SecurityGuards.requireRpcAllowed(session);
    await _assertMember(session, chatId, session.authenticated!.userIdentifier);

    await _broadcast(
      session: session,
      chatId: chatId,
      exceptDeviceId: deviceId,
      type: 'call_answered',
      payload: {
        'callId': callId,
        'answererId': session.authenticated!.userIdentifier,
        'sdpAnswerJson': sdpAnswerJson,
      },
    );
  }

  Future<void> rejectCall(
    Session session,
    String chatId,
    String deviceId,
    String callId,
    String reason,
  ) async {
    SecurityGuards.requireRpcAllowed(session);
    await _assertMember(session, chatId, session.authenticated!.userIdentifier);

    await _broadcast(
      session: session,
      chatId: chatId,
      exceptDeviceId: deviceId,
      type: 'call_rejected',
      payload: {
        'callId': callId,
        'rejecterId': session.authenticated!.userIdentifier,
        'reason': reason,
      },
    );
  }

  Future<void> sendIceCandidate(
    Session session,
    String chatId,
    String deviceId,
    String callId,
    String candidateJson,
  ) async {
    SecurityGuards.requireRpcAllowed(session);
    await _assertMember(session, chatId, session.authenticated!.userIdentifier);

    await _broadcast(
      session: session,
      chatId: chatId,
      exceptDeviceId: deviceId,
      type: 'ice_candidate',
      payload: {
        'callId': callId,
        'senderId': session.authenticated!.userIdentifier,
        'candidateJson': candidateJson,
      },
    );
  }

  Future<void> endCall(
    Session session,
    String chatId,
    String deviceId,
    String callId,
    String reason,
  ) async {
    SecurityGuards.requireRpcAllowed(session);
    await _assertMember(session, chatId, session.authenticated!.userIdentifier);

    await _broadcast(
      session: session,
      chatId: chatId,
      exceptDeviceId: deviceId,
      type: 'call_ended',
      payload: {
        'callId': callId,
        'endedById': session.authenticated!.userIdentifier,
        'reason': reason,
      },
    );
  }

  Future<void> _broadcast({
    required Session session,
    required String chatId,
    String? exceptDeviceId,
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    await ChatStreamHub.instance.broadcast(
      session,
      chatId,
      ChatStreamEnvelope(
        type: type,
        deviceId: 'server',
        chatId: chatId,
        ts: DateTime.now().toUtc(),
        payloadJson: jsonEncode(payload),
      ),
      exceptDeviceId: exceptDeviceId,
      senderAuthUserId: UuidValueJsonExtension.fromJson(
        session.authenticated!.userIdentifier,
      ),
    );
  }

  Future<void> _assertMember(Session session, String chatId, String userId) async {
    final rows = await session.db.unsafeQuery(
      'SELECT 1 FROM chat_member WHERE "chatId" = @chatId::uuid '
      'AND "memberAuthUserId" = @userId::uuid LIMIT 1',
      parameters: QueryParameters.named({'chatId': chatId, 'userId': userId}),
    );
    if (rows.isEmpty) {
      throw StateError('not a member of this chat');
    }
  }

  String _normalizeCallType(String callType) {
    final normalized = callType.trim().toLowerCase();
    if (normalized != 'voice' && normalized != 'video') {
      throw ArgumentError.value(callType, 'callType', 'Must be voice or video');
    }
    return normalized;
  }
}
