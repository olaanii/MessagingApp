import 'dart:convert';

import 'package:chat_client/chat_client.dart';

import '../../../core/device/device_id_service.dart';
import 'stream_subscription_service.dart';

/// Call media type.
enum CallType {
  voice,
  video;

  String get value => name;
}

/// Client-side wrapper around the Serverpod call signaling endpoint.
///
/// The endpoint relays signaling metadata only; actual audio/video transport is
/// handled by WebRTC in a future iteration.
final class CallService {
  CallService(this._client, this._deviceIdService);

  final Client _client;
  final DeviceIdService _deviceIdService;

  Future<String> initiateCall({
    required String chatId,
    required String deviceId,
    required String calleeAuthUserId,
    required CallType callType,
    String sdpOfferJson = '{}',
  }) async {
    return _client.call.initiateCall(
      chatId,
      deviceId,
      calleeAuthUserId,
      callType.value,
      sdpOfferJson,
    );
  }

  Future<void> answerCall({
    required String chatId,
    required String deviceId,
    required String callId,
    String sdpAnswerJson = '{}',
  }) {
    return _client.call.answerCall(chatId, deviceId, callId, sdpAnswerJson);
  }

  Future<void> rejectCall({
    required String chatId,
    required String deviceId,
    required String callId,
    required String reason,
  }) {
    return _client.call.rejectCall(chatId, deviceId, callId, reason);
  }

  Future<void> sendIceCandidate({
    required String chatId,
    required String deviceId,
    required String callId,
    required Map<String, Object?> candidate,
  }) {
    return _client.call.sendIceCandidate(
      chatId,
      deviceId,
      callId,
      jsonEncode(candidate),
    );
  }

  Future<void> endCall({
    required String chatId,
    required String deviceId,
    required String callId,
    required String reason,
  }) {
    return _client.call.endCall(chatId, deviceId, callId, reason);
  }

  /// Observes the chat room stream and yields only call-signaling events.
  Stream<InboundChatEvent> watchCallSignals({required String chatId}) async* {
    final deviceId = '${await _deviceIdService.getDeviceId()}:call';
    final inbound = _client.chatStream.chatRoom(
      chatId,
      deviceId,
      const Stream<ChatStreamEnvelope>.empty(),
    );

    await for (final envelope in inbound) {
      switch (envelope.type) {
        case 'call_offer':
          final payload = _decodePayload(envelope.payloadJson);
          yield CallOfferEvent(
            callId: payload['callId'] as String? ?? '',
            chatId: envelope.chatId ?? chatId,
            callerId: payload['callerId'] as String? ?? '',
            calleeId: payload['calleeId'] as String? ?? '',
            callType: payload['callType'] as String? ?? 'voice',
            sdpOfferJson: payload['sdpOfferJson'] as String? ?? '{}',
          );
        case 'call_answered':
          final payload = _decodePayload(envelope.payloadJson);
          yield CallAnsweredEvent(
            callId: payload['callId'] as String? ?? '',
            chatId: envelope.chatId ?? chatId,
            answererId: payload['answererId'] as String? ?? '',
            sdpAnswerJson: payload['sdpAnswerJson'] as String? ?? '{}',
          );
        case 'call_rejected':
          final payload = _decodePayload(envelope.payloadJson);
          yield CallRejectedEvent(
            callId: payload['callId'] as String? ?? '',
            chatId: envelope.chatId ?? chatId,
            rejecterId: payload['rejecterId'] as String? ?? '',
            reason: payload['reason'] as String? ?? '',
          );
        case 'ice_candidate':
          final payload = _decodePayload(envelope.payloadJson);
          yield IceCandidateEvent(
            callId: payload['callId'] as String? ?? '',
            chatId: envelope.chatId ?? chatId,
            senderId: payload['senderId'] as String? ?? '',
            candidateJson: payload['candidateJson'] as String? ?? '{}',
          );
        case 'call_ended':
          final payload = _decodePayload(envelope.payloadJson);
          yield CallEndedEvent(
            callId: payload['callId'] as String? ?? '',
            chatId: envelope.chatId ?? chatId,
            endedById: payload['endedById'] as String? ?? '',
            reason: payload['reason'] as String? ?? '',
          );
        default:
          break;
      }
    }
  }

  Map<String, dynamic> _decodePayload(String? payloadJson) {
    if (payloadJson == null || payloadJson.isEmpty) {
      return const <String, dynamic>{};
    }
    final decoded = jsonDecode(payloadJson);
    return decoded is Map<String, dynamic> ? decoded : const <String, dynamic>{};
  }
}
