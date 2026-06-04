import 'dart:collection';

import 'security_config.dart';

/// MVP soft signals: repeated limit breaches in a window → short cool-down.
final class DeviceReputation {
  DeviceReputation._();
  static final DeviceReputation instance = DeviceReputation._();

  final Map<String, Queue<DateTime>> _violations = {};

  void recordViolation(String key, DateTime nowUtc) {
    final q = _violations.putIfAbsent(key, Queue<DateTime>.new);
    while (
        q.isNotEmpty && nowUtc.difference(q.first) > SecurityConfig.reputationWindow) {
      q.removeFirst();
    }
    q.add(nowUtc);
  }

  /// True = caller should reject before consuming primary bucket (hard throttle).
  bool isThrottled(String key, DateTime nowUtc) {
    final q = _violations[key];
    if (q == null) {
      return false;
    }
    while (
        q.isNotEmpty && nowUtc.difference(q.first) > SecurityConfig.reputationWindow) {
      q.removeFirst();
    }
    return q.length >= SecurityConfig.reputationViolationsBeforeThrottle;
  }
}
