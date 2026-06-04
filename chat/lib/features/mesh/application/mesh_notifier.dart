import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/device/device_id_service.dart';
import '../data/mesh_peer.dart';
import '../data/mesh_ble_service.dart';

// ── Mesh State ────────────────────────────────────────────────────────────────

sealed class MeshState {
  const MeshState();
}

class MeshStateIdle extends MeshState {
  const MeshStateIdle();
}

class MeshStateInitializing extends MeshState {
  const MeshStateInitializing();
}

class MeshStateActive extends MeshState {
  const MeshStateActive({
    required this.peers,
    required this.connectedCount,
  });
  final List<MeshPeer> peers;
  final int connectedCount;
}

class MeshStateError extends MeshState {
  const MeshStateError(this.message);
  final String message;
}

// ── MeshNotifier ──────────────────────────────────────────────────────────────

class MeshNotifier extends AsyncNotifier<MeshState> {
  MeshBleService? _bleService;
  StreamSubscription? _peersSub;

  @override
  FutureOr<MeshState> build() async {
    ref.onDispose(() {
      _peersSub?.cancel();
      _bleService?.dispose();
    });
    return const MeshStateIdle();
  }

  /// Start the mesh network.
  Future<void> startMesh() async {
    state = const AsyncLoading();
    try {
      final deviceIdService = ref.read(deviceIdServiceProvider);
      final deviceId = await deviceIdService.getDeviceId();

      _bleService = MeshBleService(
        deviceIdService: deviceIdService,
        localDeviceId: deviceId,
      );

      final initialized = await _bleService!.initialize();
      if (!initialized) {
        state = AsyncError(
          const MeshStateError('Bluetooth permissions denied or BLE unavailable'),
          StackTrace.current,
        );
        return;
      }

      await _bleService!.startMesh();

      // Listen to peer updates
      _peersSub?.cancel();
      _peersSub = _bleService!.peersStream.listen(
        (peers) {
          state = AsyncData(MeshStateActive(
            peers: peers,
            connectedCount: _bleService!.connectedPeerCount,
          ));
        },
        onError: (e) {
          state = AsyncError(
            MeshStateError('Mesh error: $e'),
            StackTrace.current,
          );
        },
      );

      state = const AsyncData(MeshStateInitializing());
    } catch (e) {
      state = AsyncError(
        MeshStateError('Failed to start mesh: $e'),
        StackTrace.current,
      );
    }
  }

  /// Stop the mesh network.
  Future<void> stopMesh() async {
    await _peersSub?.cancel();
    _peersSub = null;
    await _bleService?.stopMesh();
    _bleService?.dispose();
    _bleService = null;
    state = const AsyncData(MeshStateIdle());
  }

  /// Connect to a specific peer.
  Future<bool> connectToPeer(String deviceId) async {
    return await _bleService?.connectToPeer(deviceId) ?? false;
  }

  /// Disconnect from a peer.
  Future<void> disconnectPeer(String deviceId) async {
    await _bleService?.disconnectPeer(deviceId);
  }

  /// Send a message via mesh.
  Future<bool> sendMessage({
    required String destinationId,
    required Uint8List payload,
  }) async {
    return await _bleService?.sendMessage(
          destinationId: destinationId,
          payload: payload,
        ) ??
        false;
  }

  /// Get the mesh message stream.
  Stream<Uint8List>? get messageStream => _bleService?.messageStream;

  /// Get routing table info.
  Map<String, dynamic> getRoutingTableDebug() =>
      _bleService?.routingTable.toDebugMap() ?? {};

  bool get isMeshActive => _bleService?.isMeshActive ?? false;
  int get connectedPeerCount => _bleService?.connectedPeerCount ?? 0;
}

final meshProvider =
    AsyncNotifierProvider.autoDispose<MeshNotifier, MeshState>(
  MeshNotifier.new,
);
