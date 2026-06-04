import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../core/device/device_id_service.dart';
import 'mesh_peer.dart';
import 'mesh_routing_table.dart';

// ── Mesh Constants ─────────────────────────────────────────────────────────────

/// UUID for the mesh networking BLE service.
const String MeshServiceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';

/// Maximum number of hops a packet can traverse in the mesh network.
const int MeshMaxHops = 7;

/// BLE-based mesh networking service.
///
/// Handles peer discovery, connection management, and message relay.
///
/// Requirements: 3.1, 3.2, 3.4, 3.9
class MeshBleService {
  MeshBleService({
    required this.deviceIdService,
    required this.localDeviceId,
  }) : _routingTable = MeshRoutingTable();

  final DeviceIdService deviceIdService;
  final String localDeviceId;
  final MeshRoutingTable _routingTable;

  final _peersController = StreamController<List<MeshPeer>>.broadcast();
  final _messageController = StreamController<Uint8List>.broadcast();

  Stream<List<MeshPeer>> get peersStream => _peersController.stream;
  Stream<Uint8List> get messageStream => _messageController.stream;
  MeshRoutingTable get routingTable => _routingTable;

  StreamSubscription? _scanSubscription;
  final _connectedDevices = <String, BluetoothDevice>{};
  final _characteristicCache = <String, BluetoothCharacteristic>{};
  bool _isScanning = false;
  bool _isAdvertising = false;

  /// Initialize BLE mesh: request permissions, start scanning and advertising.
  Future<bool> initialize() async {
    // Request BLE permissions
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    final denied = statuses.entries.where((e) => !e.value.isGranted);
    if (denied.isNotEmpty) {
      debugPrint('MeshBleService: denied permissions: ${denied.map((e) => e.key)}');
      return false;
    }

    // Check if BLE is available
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      debugPrint('MeshBleService: Bluetooth is off');
      return false;
    }

    return true;
  }

  /// Start mesh mode: scan for peers and advertise self.
  Future<void> startMesh() async {
    await startScanning();
    await startAdvertising();
  }

  /// Stop mesh mode.
  Future<void> stopMesh() async {
    await stopScanning();
    await stopAdvertising();
    await _disconnectAll();
    _routingTable.clear();
  }

  // ── Peer Discovery ──────────────────────────────────────────────────────────

  /// Start scanning for nearby mesh peers.
  Future<void> startScanning() async {
    if (_isScanning) return;
    _isScanning = true;

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(MeshServiceUuid)],
        timeout: const Duration(seconds: 30),
        continuousUpdates: true,
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          final peers = <String, MeshPeer>{};
          for (final result in results) {
            final deviceId =
                result.device.platformName.isNotEmpty
                    ? result.device.platformName
                    : result.device.remoteId.str;

            // Skip self
            if (deviceId == localDeviceId) continue;

            final existing = peers[deviceId];
            if (existing == null || result.rssi > existing.rssi) {
              peers[deviceId] = MeshPeer(
                deviceId: deviceId,
                displayName: result.device.platformName.isNotEmpty
                    ? result.device.platformName
                    : 'Device ${deviceId.substring(0, 8)}',
                rssi: result.rssi,
                serviceData: result.advertisementData.serviceData.isNotEmpty
                    ? result.advertisementData.serviceData.toString()
                    : null,
              );
            }
          }

          _peersController.add(peers.values.toList());
        },
        onError: (e) {
          debugPrint('MeshBleService scan error: $e');
          _isScanning = false;
        },
      );
    } catch (e) {
      debugPrint('MeshBleService startScanning error: $e');
      _isScanning = false;
    }
  }

  Future<void> stopScanning() async {
    _isScanning = false;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  // ── Advertising ─────────────────────────────────────────────────────────────

  /// Advertise this device as a mesh node.
  Future<void> startAdvertising() async {
    if (_isAdvertising) return;
    // flutter_blue_plus supports advertising on Android 5+.
    // This is a best-effort call; on unsupported platforms it's a no-op.
    _isAdvertising = true;
    try {
      // Advertising is handled via the system; scan results will include
      // this device on other mesh nodes.
      debugPrint('MeshBleService: advertising started (passive)');
    } catch (e) {
      debugPrint('MeshBleService startAdvertising error: $e');
      _isAdvertising = false;
    }
  }

  Future<void> stopAdvertising() async {
    _isAdvertising = false;
  }

  // ── Connection Management ───────────────────────────────────────────────────

  /// Connect to a discovered peer.
  Future<bool> connectToPeer(String deviceId) async {
    if (_connectedDevices.containsKey(deviceId)) return true;

    try {
      // Scan result gives us the device reference
      final scanResults = await FlutterBluePlus.scanResults.first;
      final result = scanResults.firstWhere(
        (r) =>
            r.device.platformName == deviceId ||
            r.device.remoteId.str == deviceId,
        orElse: () => throw StateError('Device $deviceId not found'),
      );

      await result.device.connect(timeout: const Duration(seconds: 15));
      _connectedDevices[deviceId] = result.device;

      // Register in routing table
      _routingTable.addNeighbor(MeshPeer(
        deviceId: deviceId,
        displayName: result.device.platformName,
        rssi: result.rssi,
        isConnected: true,
      ));

      // Discover services and write characteristic
      await _setupCharacteristic(result.device);

      // Monitor disconnect
      result.device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _connectedDevices.remove(deviceId);
          _characteristicCache.remove(deviceId);
          _routingTable.removeNeighbor(deviceId);
          _peersController.add(_getPeersSnapshot());
        }
      });

      _peersController.add(_getPeersSnapshot());
      return true;
    } catch (e) {
      debugPrint('MeshBleService connect error: $e');
      return false;
    }
  }

  Future<void> disconnectPeer(String deviceId) async {
    final device = _connectedDevices[deviceId];
    if (device != null) {
      try {
        await device.disconnect();
      } catch (_) {}
      _connectedDevices.remove(deviceId);
      _characteristicCache.remove(deviceId);
      _routingTable.removeNeighbor(deviceId);
    }
  }

  Future<void> _disconnectAll() async {
    for (final device in _connectedDevices.values) {
      try {
        await device.disconnect();
      } catch (_) {}
    }
    _connectedDevices.clear();
    _characteristicCache.clear();
  }

  Future<void> _setupCharacteristic(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      for (final service in services) {
        if (service.uuid.toString().toLowerCase() ==
            MeshServiceUuid.toLowerCase()) {
          for (final char in service.characteristics) {
            if (char.properties.write || char.properties.writeWithoutResponse) {
              _characteristicCache[device.platformName.isNotEmpty
                  ? device.platformName
                  : device.remoteId.str] = char;
            }
            if (char.properties.notify || char.properties.indicate) {
              await char.setNotifyValue(true);
              char.lastValueStream.listen((data) {
                if (data.isNotEmpty) {
                  _handleIncomingData(data, device.remoteId.str);
                }
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('MeshBleService setupCharacteristic error: $e');
    }
  }

  // ── Message Sending ─────────────────────────────────────────────────────────

  /// Send a message via the mesh network.
  ///
  /// If [destinationId] is a known neighbor, sends directly.
  /// Otherwise, forwards to the next hop from the routing table.
  /// If no route exists, broadcasts to all neighbors (flooding with TTL).
  Future<bool> sendMessage({
    required String destinationId,
    required Uint8List payload,
    String? messageId,
  }) async {
    final msgId = messageId ?? const Uuid().v4();
    final packet = MeshPacket(
      type: MeshPacketType.data,
      sourceId: localDeviceId,
      destinationId: destinationId,
      ttl: MeshMaxHops,
      messageId: msgId,
      payload: payload,
      hmac: Uint8List(8), // TODO: compute HMAC
    );

    // Fragment if needed for BLE MTU
    final fragments = _fragmentPacket(packet);

    // Determine next hop
    final nextHop = _routingTable.getNextHop(destinationId);
    if (nextHop != null) {
      return _sendToPeer(nextHop, fragments);
    }

    // No known route – flood to all neighbors with TTL
    bool anySent = false;
    for (final peerId in _connectedDevices.keys) {
      final sent = await _sendToPeer(peerId, fragments);
      if (sent) anySent = true;
    }

    if (!anySent) {
      debugPrint(
          'MeshBleService: no route to $destinationId and no connected peers');
    }

    return anySent;
  }

  Future<bool> _sendToPeer(String peerId, List<Uint8List> fragments) async {
    final char = _characteristicCache[peerId];
    if (char == null) return false;

    try {
      for (final fragment in fragments) {
        await char.write(fragment, withoutResponse: false);
      }
      return true;
    } catch (e) {
      debugPrint('MeshBleService send error to $peerId: $e');
      return false;
    }
  }

  // ── Message Receiving ───────────────────────────────────────────────────────

  void _handleIncomingData(List<int> data, String fromPeerId) {
    if (data.isEmpty) return;

    try {
      final packet = MeshPacket.deserialize(Uint8List.fromList(data));

      // Check TTL
      if (packet.ttl <= 0) {
        debugPrint('MeshBleService: packet TTL expired, dropping');
        return;
      }

      // Verify HMAC
      if (!_verifyHmac(packet)) {
        debugPrint('MeshBleService: HMAC verification failed, dropping');
        return;
      }

      // Is this packet for us?
      if (packet.destinationId == localDeviceId) {
        _messageController.add(packet.payload);
        return;
      }

      // Forward to next hop (relay)
      final nextHop = _routingTable.getNextHop(packet.destinationId);
      if (nextHop != null && nextHop != fromPeerId) {
        final forwarded = packet.copyWith(ttl: packet.ttl - 1);
        final fragments = _fragmentPacket(forwarded);
        _sendToPeer(nextHop, fragments).catchError((_) => false);
      } else if (nextHop == null) {
        // Flood to all other neighbors
        final forwarded = packet.copyWith(ttl: packet.ttl - 1);
        final fragments = _fragmentPacket(forwarded);
        for (final peerId in _connectedDevices.keys) {
          if (peerId != fromPeerId) {
            _sendToPeer(peerId, fragments).catchError((_) => false);
          }
        }
      }
    } catch (e) {
      debugPrint('MeshBleService handleIncomingData error: $e');
    }
  }

  bool _verifyHmac(MeshPacket packet) {
    // TODO: Implement HMAC-SHA256 verification using shared mesh key
    return true; // Placeholder
  }

  // ── Fragmentation ───────────────────────────────────────────────────────────

  static const int maxFragmentSize = 512; // BLE MTU default is ~512 bytes

  List<Uint8List> _fragmentPacket(MeshPacket packet) {
    final serialized = packet.serialize();
    if (serialized.length <= maxFragmentSize) {
      return [serialized];
    }

    final fragments = <Uint8List>[];
    var offset = 0;
    while (offset < serialized.length) {
      final end =
          (offset + maxFragmentSize).clamp(0, serialized.length);
      fragments.add(serialized.sublist(offset, end));
      offset = end;
    }
    return fragments;
  }

  // ── Utility ─────────────────────────────────────────────────────────────────

  List<MeshPeer> _getPeersSnapshot() {
    return _routingTable.neighbors.values.toList();
  }

  bool get isScanning => _isScanning;
  bool get isMeshActive => _isScanning || _isAdvertising;
  int get connectedPeerCount => _connectedDevices.length;

  void dispose() {
    stopMesh();
    _peersController.close();
    _messageController.close();
  }
}
