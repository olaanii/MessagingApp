import 'dart:collection';

/// In-memory sliding window counter (single-process MVP).
final class SlidingWindowLimiter {
  SlidingWindowLimiter({
    required this.maxHits,
    required this.window,
  });

  final int maxHits;
  final Duration window;
  final Map<String, Queue<DateTime>> _queues = {};

  /// Returns true if the hit is allowed (and recorded).
  bool tryHit(String key, DateTime nowUtc) {
    final q = _queues.putIfAbsent(key, Queue<DateTime>.new);
    while (q.isNotEmpty && nowUtc.difference(q.first) > window) {
      q.removeFirst();
    }
    if (q.length >= maxHits) {
      return false;
    }
    q.add(nowUtc);
    return true;
  }
}

final class PerSecondLimiter {
  PerSecondLimiter({required this.maxHits});

  final int maxHits;
  final Map<String, Queue<DateTime>> _queues = {};

  bool tryHit(String key, DateTime nowUtc) {
    final q = _queues.putIfAbsent(key, Queue<DateTime>.new);
    final window = const Duration(seconds: 1);
    while (q.isNotEmpty && nowUtc.difference(q.first) > window) {
      q.removeFirst();
    }
    if (q.length >= maxHits) {
      return false;
    }
    q.add(nowUtc);
    return true;
  }
}
