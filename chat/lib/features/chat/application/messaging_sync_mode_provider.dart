import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/messaging_backend.dart';

/// Provides the [MessagingSyncMode] singleton.
///
/// Overridable in tests to inject a specific mode.
final messagingSyncModeProvider = Provider<MessagingSyncMode>(
  (ref) => MessagingSyncMode(),
);
