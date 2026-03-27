/// Dual-mode messaging during Firestore → Serverpod cutover.
///
/// See `mvp_plan.md` Phase 1 checklist and ADR for authoritative milestones.
enum MessagingBackend {
  /// Current default: Firestore + optional Hive offline queue.
  firestore,

  /// Target: Serverpod RPC + streaming + Drift mirror (Phases M1–M3).
  serverpod,
}

/// Compile-time default; override in CI/integration tests via `--dart-define`.
const MessagingBackend kDefaultMessagingBackend =
    bool.fromEnvironment('SERVERPOD_MESSAGING', defaultValue: false)
        ? MessagingBackend.serverpod
        : MessagingBackend.firestore;

/// Runtime toggle for staged rollouts (e.g. Settings dev menu or remote config).
final class MessagingSyncMode {
  MessagingSyncMode({MessagingBackend? backend})
      : backend = backend ?? kDefaultMessagingBackend;

  MessagingBackend backend;

  bool get useServerpod => backend == MessagingBackend.serverpod;

  bool get useFirestore => backend == MessagingBackend.firestore;
}
