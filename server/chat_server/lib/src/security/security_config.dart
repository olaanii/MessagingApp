/// Tunable caps for in-process limiting (ADR-0007). Replace with Redis/Postgres
/// buckets when scaling horizontally.
abstract final class SecurityConfig {
  static const rpcPerIpPerMinute = 120;
  static const rpcPerAuthUserPerMinute = 240;

  static const mediaPreparePerIpPerMinute = 40;
  static const mediaFinalizePerIpPerMinute = 80;

  static const jwtRefreshPerIpPerMinute = 45;

  static const emailLoginPerIpPerMinute = 30;
  static const emailLoginPerEmailPerMinute = 12;
  static const emailStartRegistrationPerIpPerMinute = 20;
  static const emailPasswordResetPerIpPerMinute = 15;

  static const streamConnectPerDevicePerMinute = 25;
  static const streamFramesPerDevicePerChatPerSecond = 48;
  static const streamSendMessagePerDevicePerChatPerMinute = 60;

  static const safetyReportsPerUserPerHour = 40;

  static const reputationWindow = Duration(minutes: 15);
  static const reputationViolationsBeforeThrottle = 8;
}
