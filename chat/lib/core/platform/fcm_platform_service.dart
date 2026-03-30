import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'fcm_message_payload.dart';

/// Firebase Cloud Messaging integration: permissions, token publish, foreground
/// display, and **deep link** routing to `/chat/:id`.
///
/// ## Server payload contract
/// Include `chatId` (or `chat_id`) in the **data** payload so taps work when the
/// app was backgrounded or terminated. Notification-only payloads often omit
/// `data` and break routing.
///
/// ## Topics
/// MVP targets **per-device tokens** registered with the backend (`push_tokens`).
/// FCM topics are intentionally unused unless product adds broadcast.
///
/// ## Web
/// Push is **best-effort** on web (service worker, permission, browser limits).
/// Treat in-app inbox + sync as the source of truth; do not rely on background
/// delivery.
///
/// ## Wiring `publishToken`
/// The [publishToken] callback should be wired to `syncFcmToken` (from
/// `lib/data/services/fcm_token_sync.dart`) with the current
/// [MessagingSyncMode] and the Serverpod `client.push.registerToken` call
/// injected as `serverpodRegister`. Example:
///
/// ```dart
/// FcmPlatformService(
///   router: router,
///   publishToken: (userId, token) => syncFcmToken(
///     userId: userId,
///     token: token,
///     mode: MessagingSyncMode(),
///     serverpodRegister: (uid, tok, platform) =>
///         client.push.registerToken(uid, tok, platform),
///   ),
///   isAuthenticated: () => authNotifier.isAuthenticated,
/// )
/// ```
typedef PushTokenPublisher = Future<void> Function(
  String userId,
  String token,
);

const _androidChannelId = 'chat_messages';
const _androidChannelName = 'Chat messages';

/// ## iOS checklist (Xcode / Apple Developer)
/// - Enable **Push Notifications** capability.
/// - Add **Background Modes** → **Remote notifications** (`Info.plist`).
/// - Use a provisioning profile plus APNs key/certificate matching Firebase.
/// - Confirm `FirebaseAppDelegate` / messaging swizzling per FlutterFire docs.
final class FcmPlatformService {
  FcmPlatformService({
    required GoRouter router,
    required PushTokenPublisher publishToken,
    required bool Function() isAuthenticated,
  }) : _router = router,
       _publishToken = publishToken,
       _isAuthenticated = isAuthenticated;

  final GoRouter _router;
  final PushTokenPublisher _publishToken;
  final bool Function() _isAuthenticated;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final List<StreamSubscription<dynamic>> _subs = [];
  String? _pendingChatId;
  bool _localNotificationsInitialized = false;
  String? _sessionUserId;

  /// Starts listeners for [userId]. Idempotent for the same [userId].
  Future<void> startSession(String userId) async {
    if (_sessionUserId == userId && _subs.isNotEmpty) {
      return;
    }
    await resetSession();
    _sessionUserId = userId;

    if (kIsWeb) {
      debugPrint(
        'FCM (web): background delivery is limited; inbox sync remains primary.',
      );
    }

    await _ensureLocalNotifications();

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    final token = await _fcm.getToken();
    if (token != null) {
      await _safePublish(userId, token);
    }

    _subs.add(_fcm.onTokenRefresh.listen((t) => _safePublish(userId, t)));

    _subs.add(FirebaseMessaging.onMessage.listen(_onForegroundMessage));

    _subs.add(
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedFromBackground),
    );

    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _pendingChatId = parseChatIdFromRemoteMessage(initial);
    }
  }

  /// Cancels FCM subscriptions (e.g. sign-out). Does not revoke the token server-side.
  Future<void> resetSession() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _sessionUserId = null;
  }

  Future<void> _safePublish(String userId, String token) async {
    try {
      await _publishToken(userId, token);
    } catch (e, st) {
      debugPrint('Push token publish failed: $e $st');
    }
  }

  Future<void> _ensureLocalNotifications() async {
    if (kIsWeb || _localNotificationsInitialized) {
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwinInit = DarwinInitializationSettings();

    await _local.initialize(
      settings: InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    final androidImpl = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'New messages and alerts',
        importance: Importance.high,
      ),
    );

    _localNotificationsInitialized = true;
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _navigateToChat(payload);
    }
  }

  void _navigateToChat(String chatId) {
    if (!_isAuthenticated()) {
      _pendingChatId = chatId;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router.go('/chat/$chatId');
    });
  }

  void flushPendingNavigation() {
    final id = _pendingChatId;
    if (id == null) return;
    if (!_isAuthenticated()) return;
    _pendingChatId = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router.go('/chat/$id');
    });
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (kIsWeb) {
      return;
    }
    await _ensureLocalNotifications();
    final chatId = parseChatIdFromRemoteMessage(message);
    final title =
        message.notification?.title ??
        (message.data['title'] as String?) ??
        'New message';
    final body =
        message.notification?.body ?? (message.data['body'] as String?) ?? '';

    await _local.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'New messages and alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: chatId,
    );
  }

  void _onOpenedFromBackground(RemoteMessage message) {
    final chatId = parseChatIdFromRemoteMessage(message);
    if (chatId != null) {
      _navigateToChat(chatId);
    }
  }

  void dispose() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    _subs.clear();
  }
}
