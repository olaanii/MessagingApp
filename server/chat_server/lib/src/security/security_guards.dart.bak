import 'package:serverpod/serverpod.dart';

import 'device_reputation.dart';
import 'package:chat_server/src/generated/security/rate_limit_exception.dart';
import 'security_audit.dart';
import 'security_config.dart';
import 'sliding_window_limiter.dart';

/// Central enforcement for ADR-0007. Throws [RateLimitException] on abuse.
abstract final class SecurityGuards {
  static final _rpcIp = SlidingWindowLimiter(
    maxHits: SecurityConfig.rpcPerIpPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _rpcUser = SlidingWindowLimiter(
    maxHits: SecurityConfig.rpcPerAuthUserPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _mediaPrepareIp = SlidingWindowLimiter(
    maxHits: SecurityConfig.mediaPreparePerIpPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _mediaFinalizeIp = SlidingWindowLimiter(
    maxHits: SecurityConfig.mediaFinalizePerIpPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _jwtRefreshIp = SlidingWindowLimiter(
    maxHits: SecurityConfig.jwtRefreshPerIpPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _emailLoginIp = SlidingWindowLimiter(
    maxHits: SecurityConfig.emailLoginPerIpPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _emailLoginEmail = SlidingWindowLimiter(
    maxHits: SecurityConfig.emailLoginPerEmailPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _emailRegisterIp = SlidingWindowLimiter(
    maxHits: SecurityConfig.emailStartRegistrationPerIpPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _emailPwResetIp = SlidingWindowLimiter(
    maxHits: SecurityConfig.emailPasswordResetPerIpPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _streamConnectDevice = SlidingWindowLimiter(
    maxHits: SecurityConfig.streamConnectPerDevicePerMinute,
    window: const Duration(minutes: 1),
  );
  static final _streamFrameBurst = PerSecondLimiter(
    maxHits: SecurityConfig.streamFramesPerDevicePerChatPerSecond,
  );
  static final _streamSendPerChatDevice = SlidingWindowLimiter(
    maxHits: SecurityConfig.streamSendMessagePerDevicePerChatPerMinute,
    window: const Duration(minutes: 1),
  );
  static final _reportsPerUser = SlidingWindowLimiter(
    maxHits: SecurityConfig.safetyReportsPerUserPerHour,
    window: const Duration(hours: 1),
  );

  static void requireRpcAllowed(Session session) {
    final now = DateTime.now().toUtc();
    final ipKey = 'ip:${SecurityAudit.remoteKey(session)}';
    if (DeviceReputation.instance.isThrottled(ipKey, now)) {
      SecurityAudit.log(session, event: 'rate_limit', outcome: 'blocked_reputation');
      throw RateLimitException(
        code: 'RATE_LIMIT_RPC',
        message: 'Too many requests; try again later.',
      );
    }
    if (!_rpcIp.tryHit(ipKey, now)) {
      DeviceReputation.instance.recordViolation(ipKey, now);
      SecurityAudit.log(session, event: 'rate_limit', outcome: 'rpc_ip');
      throw RateLimitException(
        code: 'RATE_LIMIT_RPC',
        message: 'Too many requests from this network.',
      );
    }

    final authId = session.authenticated?.userIdentifier;
    if (authId != null) {
      final userKey = 'user:$authId';
      if (DeviceReputation.instance.isThrottled(userKey, now)) {
        SecurityAudit.log(
          session,
          event: 'rate_limit',
          outcome: 'blocked_reputation',
          userIdPrefix: SecurityAudit.authenticatedUserPrefix(session),
        );
        throw RateLimitException(
          code: 'RATE_LIMIT_RPC',
          message: 'Too many requests for this account.',
        );
      }
      if (!_rpcUser.tryHit(userKey, now)) {
        DeviceReputation.instance.recordViolation(userKey, now);
        SecurityAudit.log(
          session,
          event: 'rate_limit',
          outcome: 'rpc_user',
          userIdPrefix: SecurityAudit.authenticatedUserPrefix(session),
        );
        throw RateLimitException(
          code: 'RATE_LIMIT_RPC',
          message: 'Too many requests for this account.',
        );
      }
    }
  }

  static void requireMediaPrepareAllowed(Session session) {
    requireRpcAllowed(session);
    final now = DateTime.now().toUtc();
    final key = 'mediaprep:${SecurityAudit.remoteKey(session)}';
    if (!_mediaPrepareIp.tryHit(key, now)) {
      SecurityAudit.log(session, event: 'rate_limit', outcome: 'media_prepare');
      throw RateLimitException(
        code: 'RATE_LIMIT_MEDIA',
        message: 'Upload slot rate exceeded.',
      );
    }
  }

  static void requireMediaFinalizeAllowed(Session session) {
    requireRpcAllowed(session);
    final now = DateTime.now().toUtc();
    final key = 'mediafin:${SecurityAudit.remoteKey(session)}';
    if (!_mediaFinalizeIp.tryHit(key, now)) {
      SecurityAudit.log(session, event: 'rate_limit', outcome: 'media_finalize');
      throw RateLimitException(
        code: 'RATE_LIMIT_MEDIA',
        message: 'Finalize rate exceeded.',
      );
    }
  }

  static void requireAuthRefreshAllowed(Session session) {
    final now = DateTime.now().toUtc();
    final key = 'jwt:${SecurityAudit.remoteKey(session)}';
    if (!_jwtRefreshIp.tryHit(key, now)) {
      SecurityAudit.log(session, event: 'rate_limit', outcome: 'auth_refresh');
      throw RateLimitException(
        code: 'RATE_LIMIT_AUTH',
        message: 'Too many token refresh attempts.',
      );
    }
  }

  static void requireEmailLoginAllowed(Session session, String email) {
    final now = DateTime.now().toUtc();
    final ipKey = 'elogin_ip:${SecurityAudit.remoteKey(session)}';
    final emKey = 'elogin_em:${email.trim().toLowerCase().hashCode}';
    if (!_emailLoginIp.tryHit(ipKey, now) || !_emailLoginEmail.tryHit(emKey, now)) {
      SecurityAudit.log(session, event: 'rate_limit', outcome: 'email_login');
      throw RateLimitException(
        code: 'RATE_LIMIT_AUTH',
        message: 'Too many sign-in attempts.',
      );
    }
  }

  static void requireEmailRegistrationAllowed(Session session) {
    final now = DateTime.now().toUtc();
    final key = 'ereg:${SecurityAudit.remoteKey(session)}';
    if (!_emailRegisterIp.tryHit(key, now)) {
      SecurityAudit.log(session, event: 'rate_limit', outcome: 'email_register');
      throw RateLimitException(
        code: 'RATE_LIMIT_AUTH',
        message: 'Too many registration attempts.',
      );
    }
  }

  static void requireEmailPasswordResetAllowed(Session session) {
    final now = DateTime.now().toUtc();
    final key = 'epw:${SecurityAudit.remoteKey(session)}';
    if (!_emailPwResetIp.tryHit(key, now)) {
      SecurityAudit.log(session, event: 'rate_limit', outcome: 'email_pwreset');
      throw RateLimitException(
        code: 'RATE_LIMIT_AUTH',
        message: 'Too many password reset attempts.',
      );
    }
  }

  static void requireStreamConnectAllowed(Session session, {required String deviceId}) {
    final now = DateTime.now().toUtc();
    final key = 'strconn:$deviceId';
    if (!_streamConnectDevice.tryHit(key, now)) {
      SecurityAudit.log(
        session,
        event: 'rate_limit',
        outcome: 'stream_connect',
        deviceIdPrefix: deviceId,
      );
      throw RateLimitException(
        code: 'RATE_LIMIT_STREAM',
        message: 'Too many realtime connections for this device.',
      );
    }
  }

  static void requireStreamFrameAllowed(
    Session session, {
    required String chatId,
    required String deviceId,
  }) {
    final now = DateTime.now().toUtc();
    final key = '$chatId|$deviceId';
    if (!_streamFrameBurst.tryHit(key, now)) {
      SecurityAudit.log(
        session,
        event: 'rate_limit',
        outcome: 'stream_frame',
        deviceIdPrefix: deviceId,
      );
      throw RateLimitException(
        code: 'RATE_LIMIT_STREAM',
        message: 'Realtime event rate exceeded.',
      );
    }
  }

  static void requireStreamSendMessageAllowed(
    Session session, {
    required String chatId,
    required String deviceId,
  }) {
    final now = DateTime.now().toUtc();
    final key = 'send|$chatId|$deviceId';
    if (!_streamSendPerChatDevice.tryHit(key, now)) {
      SecurityAudit.log(
        session,
        event: 'rate_limit',
        outcome: 'stream_send',
        deviceIdPrefix: deviceId,
      );
      throw RateLimitException(
        code: 'RATE_LIMIT_MESSAGE',
        message: 'Message rate exceeded for this chat.',
      );
    }
  }

  static void requireReportAllowed(Session session) {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) {
      throw RateLimitException(code: 'UNAUTHENTICATED', message: 'Login required.');
    }
    final now = DateTime.now().toUtc();
    final key = 'report:$authId';
    if (!_reportsPerUser.tryHit(key, now)) {
      SecurityAudit.log(
        session,
        event: 'rate_limit',
        outcome: 'report_flood',
        userIdPrefix: SecurityAudit.authenticatedUserPrefix(session),
      );
      throw RateLimitException(
        code: 'RATE_LIMIT_REPORT',
        message: 'Too many reports submitted.',
      );
    }
  }
}
