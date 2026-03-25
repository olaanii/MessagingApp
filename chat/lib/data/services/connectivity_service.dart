import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'messaging_service.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      // connectivity_plus 6.x returns a List<ConnectivityResult>
      if (results.any((result) => result != ConnectivityResult.none)) {
        debugPrint('Connectivity restored. Triggering sync...');
        _syncOfflineMessages();
      }
    });
  }

  Future<void> _syncOfflineMessages() async {
    try {
      final messagingService = MessagingService();
      await messagingService.init();
      await messagingService.syncAllOfflineMessages();
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
