import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/device/device_id_service.dart';
import '../../core/serverpod/serverpod_client_provider.dart';
import '../../features/chat/data/call_service.dart';
import '../../features/chat/data/stream_subscription_service.dart';
import '../providers/app_providers.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    super.key,
    required this.chatId,
    required this.calleeAuthUserId,
    required this.callType,
  });

  final String chatId;
  final String calleeAuthUserId;
  final CallType callType;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  late final CallService _callService;
  String? _deviceId;
  StreamSubscription<InboundChatEvent>? _sub;

  String? _callId;
  String _status = 'Preparing call...';
  bool _muted = false;
  bool _speakerOn = true;
  bool _cameraOn = true;
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _callService = CallService(
      ref.read(serverpodClientProvider),
      ref.read(deviceIdServiceProvider),
    );
    _startListening();
    _loadDeviceId();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCall());
  }

  Future<void> _loadDeviceId() async {
    final deviceId = await ref.read(deviceIdServiceProvider).getDeviceId();
    if (!mounted) return;
    setState(() => _deviceId = deviceId);
  }

  Future<void> _startListening() async {
    _sub = _callService.watchCallSignals(chatId: widget.chatId).listen(
      (event) {
        if (!mounted) return;
        setState(() {
          switch (event) {
            case CallOfferEvent():
              _callId = event.callId;
              _status = 'Incoming ${event.callType} call from ${event.callerId}';
              _log.insert(0, 'Offer: ${event.callId}');
              break;
            case CallAnsweredEvent():
              _callId = event.callId;
              _status = 'Call answered by ${event.answererId}';
              _log.insert(0, 'Answered: ${event.callId}');
              break;
            case CallRejectedEvent():
              _status = 'Call rejected: ${event.reason}';
              _log.insert(0, 'Rejected: ${event.callId}');
              break;
            case IceCandidateEvent():
              _log.insert(0, 'ICE: ${event.senderId}');
              break;
            case CallEndedEvent():
              _status = 'Call ended: ${event.reason}';
              _log.insert(0, 'Ended: ${event.callId}');
              break;
            default:
              break;
          }
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _status = 'Stream error: $error');
      },
    );
  }

  Future<void> _startCall() async {
    final auth = ref.read(authNotifierProvider);
    final user = auth.currentUser;
    final callerId = user?.id ?? 'me';
    final deviceId = _deviceId ?? await ref.read(deviceIdServiceProvider).getDeviceId();
    try {
      final callId = await _callService.initiateCall(
        chatId: widget.chatId,
        deviceId: deviceId,
        calleeAuthUserId: widget.calleeAuthUserId,
        callType: widget.callType,
        sdpOfferJson: '{"type":"offer","callerId":"$callerId"}',
      );
      if (!mounted) return;
      setState(() {
        _callId = callId;
        _status = 'Calling ${widget.calleeAuthUserId}...';
        _log.insert(0, 'Initiated: $callId');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Failed to start call: $e');
    }
  }

  Future<void> _answer() async {
    final callId = _callId;
    if (callId == null) return;
    final deviceId = _deviceId ?? await ref.read(deviceIdServiceProvider).getDeviceId();
    await _callService.answerCall(
      chatId: widget.chatId,
      deviceId: deviceId,
      callId: callId,
      sdpAnswerJson: '{"type":"answer"}',
    );
  }

  Future<void> _reject() async {
    final callId = _callId;
    if (callId == null) return;
    final deviceId = _deviceId ?? await ref.read(deviceIdServiceProvider).getDeviceId();
    await _callService.rejectCall(
      chatId: widget.chatId,
      deviceId: deviceId,
      callId: callId,
      reason: 'declined by user',
    );
    if (mounted) context.pop();
  }

  Future<void> _end() async {
    final callId = _callId;
    if (callId == null) return;
    final deviceId = _deviceId ?? await ref.read(deviceIdServiceProvider).getDeviceId();
    await _callService.endCall(
      chatId: widget.chatId,
      deviceId: deviceId,
      callId: callId,
      reason: 'hangup',
    );
    if (mounted) context.pop();
  }

  Future<void> _sendCandidate() async {
    final callId = _callId;
    if (callId == null) return;
    final deviceId = _deviceId ?? await ref.read(deviceIdServiceProvider).getDeviceId();
    await _callService.sendIceCandidate(
      chatId: widget.chatId,
      deviceId: deviceId,
      callId: callId,
      candidate: const {
        'candidate': 'candidate:1 1 udp 2122260223 0.0.0.0 9 typ host',
        'sdpMid': 'audio',
        'sdpMLineIndex': 0,
      },
    );
    if (!mounted) return;
    setState(() => _log.insert(0, 'Sent ICE candidate'));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('${widget.callType.value.toUpperCase()} call'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.phoneCall, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Call ID: ${_callId ?? 'pending'}'),
                    const SizedBox(height: 8),
                    Text('Chat: ${widget.chatId}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _actionButton(
                    icon: _muted ? LucideIcons.micOff : LucideIcons.mic,
                    label: _muted ? 'Unmute' : 'Mute',
                    onPressed: () => setState(() => _muted = !_muted),
                  ),
                  _actionButton(
                    icon: _speakerOn ? LucideIcons.volume2 : LucideIcons.volumeX,
                    label: _speakerOn ? 'Speaker' : 'Earpiece',
                    onPressed: () => setState(() => _speakerOn = !_speakerOn),
                  ),
                  if (widget.callType == CallType.video)
                    _actionButton(
                      icon: _cameraOn ? LucideIcons.video : LucideIcons.videoOff,
                      label: _cameraOn ? 'Camera on' : 'Camera off',
                      onPressed: () => setState(() => _cameraOn = !_cameraOn),
                    ),
                  _actionButton(
                    icon: LucideIcons.radio,
                    label: 'Send ICE',
                    onPressed: _sendCandidate,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _answer,
                      child: const Text('Answer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reject,
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: _end,
                child: const Text('End call'),
              ),
              const SizedBox(height: 24),
              Text('Signaling log', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _log.length,
                  itemBuilder: (context, index) => ListTile(
                    dense: true,
                    leading: const Icon(LucideIcons.messageSquare, size: 18),
                    title: Text(_log[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
