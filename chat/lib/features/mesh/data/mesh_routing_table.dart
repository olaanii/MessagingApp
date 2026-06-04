import 'dart:collection';

import 'mesh_peer.dart';

// ── Mesh Constants ─────────────────────────────────────────────────────────────

/// Maximum number of hops a packet can traverse in the mesh network.
const int MeshMaxHops = 7;

/// Distance-vector routing table for the mesh network.
///
/// Maintains routes to known destinations via next-hop peers.
/// Implements expiration and max-hop enforcement.
///
/// Requirements: 3.4
class MeshRoutingTable {
  final _routes = <String, MeshRoute>{};
  final _neighbors = <String, MeshPeer>{};

  /// Known routes: destination → route.
  UnmodifiableMapView<String, MeshRoute> get routes =>
      UnmodifiableMapView(_routes);

  /// Directly connected neighbors.
  UnmodifiableMapView<String, MeshPeer> get neighbors =>
      UnmodifiableMapView(_neighbors);

  /// Register or update a direct neighbor.
  void addNeighbor(MeshPeer peer) {
    _neighbors[peer.deviceId] = peer;
    _routes[peer.deviceId] = MeshRoute(
      destinationId: peer.deviceId,
      nextHopId: peer.deviceId,
      hopCount: 1,
    );
  }

  /// Remove a neighbor and all routes through it.
  void removeNeighbor(String deviceId) {
    _neighbors.remove(deviceId);
    _routes.removeWhere((_, route) =>
        route.destinationId == deviceId || route.nextHopId == deviceId);
  }

  /// Add or update a route discovered via route discovery.
  void updateRoute(String destinationId, String nextHopId, int hopCount) {
    if (hopCount > MeshMaxHops) return; // Exceeds max hops

    final existing = _routes[destinationId];
    if (existing == null || hopCount < existing.hopCount) {
      _routes[destinationId] = MeshRoute(
        destinationId: destinationId,
        nextHopId: nextHopId,
        hopCount: hopCount,
      );
    }
  }

  /// Look up the next hop for [destinationId].
  String? getNextHop(String destinationId) {
    final route = _routes[destinationId];
    if (route == null || route.isExpired || !route.isReachable) return null;

    // Check that the next hop is still a neighbor
    if (!_neighbors.containsKey(route.nextHopId)) {
      _routes.remove(destinationId);
      return null;
    }

    return route.nextHopId;
  }

  /// Check if we have a valid route to [destinationId].
  bool hasRoute(String destinationId) => getNextHop(destinationId) != null;

  /// Expire stale routes and return count of expired entries.
  int expireStaleRoutes() {
    final toRemove = <String>[];
    _routes.forEach((dest, route) {
      if (route.isExpired) toRemove.add(dest);
      if (!_neighbors.containsKey(route.nextHopId)) toRemove.add(dest);
    });
    toRemove.forEach(_routes.remove);
    return toRemove.length;
  }

  /// Get number of known routes (including direct neighbors).
  int get routeCount => _routes.length;

  /// Clear all routes and neighbors.
  void clear() {
    _routes.clear();
    _neighbors.clear();
  }

  /// Get routing table summary for debugging.
  Map<String, dynamic> toDebugMap() {
    return {
      'neighbors': _neighbors.length,
      'routes': _routes.length,
      'entries': _routes.entries.map((e) => {
            'dest': e.key.substring(0, 8),
            'nextHop': e.value.nextHopId.substring(0, 8),
            'hops': e.value.hopCount,
            'expired': e.value.isExpired,
          }).toList(),
    };
  }
}
