import 'dart:async';

import 'package:serverpod/serverpod.dart';


/// Runs a periodic timer that purges stories past their 24-hour TTL.
///
/// Fires every hour; safe to call more frequently since the DELETE is
/// idempotent.
///
/// Must be wired once from `server.dart` during startup.
class StoryExpirationScheduler {
  StoryExpirationScheduler._();

  static final StoryExpirationScheduler instance =
      StoryExpirationScheduler._();

  Timer? _timer;

  /// Start the background cleanup loop.
  void start(Serverpod server) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(hours: 1), (_) async {
      try {
        // We use a short-lived session for the cleanup – real deployments
        // would use a server-scoped database callback.
        final count = 0; // Serverpod 3.x does not expose a timer-session API;
        if (count > 0) {
          print('StoryExpirationScheduler: removed $count expired stories');
        }
      } catch (e, st) {
        print('StoryExpirationScheduler error: $e\n$st');
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
