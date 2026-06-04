import 'dart:typed_data';

/// Represents a discovered Bluetooth mesh peer.
class MeshPeer {
  final String deviceId;
  final String displayName;
  final int rssi; // Signal strength in dBm
  final DateTime lastSeen;
  final String? serviceData;
  bool isConnected;

  MeshPeer({
    required this.deviceId,
    required this.displayName,
    this.rssi = -100,
    DateTime? lastSeen,
    this.serviceData,
    this.isConnected = false,
  }) : lastSeen = lastSeen ?? DateTime.now();

  bool get isReachable => rssi > -85; // within ~100-200 m

  Duration get age => DateTime.now().difference(lastSeen);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeshPeer && deviceId == other.deviceId;

  @override
  int get hashCode => deviceId.hashCode;

  @override
  String toString() =>
      'MeshPeer($deviceId, rssi: $rssi, connected: $isConnected)';
}

/// A routing table entry: destination → next hop.
class MeshRoute {
  final String destinationId;
  final String nextHopId;
  final int hopCount;
  final DateTime updatedAt;

  MeshRoute({
    required this.destinationId,
    required this.nextHopId,
    required this.hopCount,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(updatedAt).inMinutes > 10;

  bool get isReachable => hopCount <= meshMaxHops;
}

/// Mesh packet types.
enum MeshPacketType {
  data(0x01),
  routeDiscovery(0x02),
  routeReply(0x03),
  hopByHopEncrypted(0x04),
  ack(0x05);

  final int value;
  const MeshPacketType(this.value);

  static MeshPacketType fromValue(int v) =>
      MeshPacketType.values.firstWhere((t) => t.value == v, orElse: () => data);
}

/// A mesh network packet.
class MeshPacket {
  static const int currentVersion = 1;
  static const int headerSize = 32;

  final int version;
  final MeshPacketType type;
  final String sourceId;
  final String destinationId;
  final String nextHopId; // empty if P2P
  final int ttl;
  final String messageId;
  final Uint8List payload;
  final Uint8List hmac; // HMAC-SHA256 for integrity

  const MeshPacket({
    this.version = currentVersion,
    required this.type,
    required this.sourceId,
    required this.destinationId,
    this.nextHopId = '',
    this.ttl = 5,
    required this.messageId,
    required this.payload,
    required this.hmac,
  });

  /// Serialize to bytes for BLE transmission.
  Uint8List serialize() {
    final builder = BytesBuilder();
    builder.addByte(version);
    builder.addByte(type.value);

    // Source ID (16 bytes UUID)
    final srcBytes = _uuidToBytes(sourceId);
    builder.add(srcBytes);

    // Destination ID (16 bytes UUID)
    final dstBytes = _uuidToBytes(destinationId);
    builder.add(dstBytes);

    // TTL
    builder.addByte(ttl);

    // Message ID as UTF-8 (up to 16 bytes)
    final msgIdBytes = messageId.codeUnits;
    builder.add(msgIdBytes.take(16).toList());
    if (msgIdBytes.length < 16) {
      builder.add(List.filled(16 - msgIdBytes.length, 0));
    }

    // Payload length (2 bytes)
    builder.add([
      (payload.length >> 8) & 0xFF,
      payload.length & 0xFF,
    ]);

    // Payload
    builder.add(payload);

    // HMAC (8 bytes truncated)
    builder.add(hmac.take(8).toList());

    return builder.toBytes();
  }

  /// Deserialize from BLE bytes.
  static MeshPacket deserialize(Uint8List bytes) {
    if (bytes.length < headerSize) {
      throw FormatException('Packet too short: ${bytes.length} bytes');
    }

    var offset = 0;
    final version = bytes[offset++];
    final type = MeshPacketType.fromValue(bytes[offset++]);

    // Source ID
    final sourceId = _bytesToUuid(bytes.sublist(offset, offset + 16));
    offset += 16;

    // Destination ID
    final destinationId = _bytesToUuid(bytes.sublist(offset, offset + 16));
    offset += 16;

    // TTL
    final ttl = bytes[offset++];

    // Message ID
    final msgIdBytes =
        bytes.sublist(offset, offset + 16).where((b) => b != 0).toList();
    final messageId = String.fromCharCodes(msgIdBytes);
    offset += 16;

    // Payload length
    final payloadLen = (bytes[offset] << 8) | bytes[offset + 1];
    offset += 2;

    // Payload
    final payload = bytes.sublist(offset, offset + payloadLen);
    offset += payloadLen;

    // HMAC
    final hmac = bytes.sublist(offset, offset + 8);

    return MeshPacket(
      version: version,
      type: type,
      sourceId: sourceId,
      destinationId: destinationId,
      ttl: ttl,
      messageId: messageId,
      payload: Uint8List.fromList(payload),
      hmac: Uint8List.fromList(hmac),
    );
  }

  MeshPacket copyWith({int? ttl}) => MeshPacket(
        version: version,
        type: type,
        sourceId: sourceId,
        destinationId: destinationId,
        nextHopId: nextHopId,
        ttl: ttl ?? this.ttl,
        messageId: messageId,
        payload: payload,
        hmac: hmac,
      );

  static Uint8List _uuidToBytes(String uuid) {
    final clean = uuid.replaceAll('-', '');
    final bytes = <int>[];
    for (var i = 0; i < clean.length; i += 2) {
      bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  static String _bytesToUuid(Uint8List bytes) {
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }
}

/// Maximum number of hops for mesh relay.
const int meshMaxHops = 5;

/// Mesh service UUID for BLE advertisement.
const String meshServiceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
