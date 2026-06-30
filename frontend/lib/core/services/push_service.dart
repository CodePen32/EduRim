import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // No custom work needed for MVP; system tray displays the notification.
}

class PushService {
  // Lazy: must NOT touch Firebase before Firebase.initializeApp() has run.
  // Accessing FirebaseMessaging.instance at construction throws [core/no-app].
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'concouri_default_channel',
    'إشعارات Concouri',
    description: 'إشعارات التطبيق العامة',
    importance: Importance.high,
  );

  /// Initialize Firebase + messaging. Safe to call once at startup.
  /// Best-effort: any failure is swallowed so the app never breaks.
  Future<void> init() async {
    if (_initialized || kIsWeb) return;
    try {
      await Firebase.initializeApp();

      // Local notifications (to show FCM messages while app is in foreground)
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _local.initialize(const InitializationSettings(android: androidInit));
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      FirebaseMessaging.onMessage.listen(_showForeground);

      _initialized = true;
    } catch (e) {
      debugPrint('[PushService] init failed (ignored): $e');
    }
  }

  void _showForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _local.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Fetch the FCM token and send it to the backend.
  /// Best-effort: requires the user to be authenticated (token set on apiClient).
  Future<void> registerToken() async {
    if (kIsWeb) return;
    try {
      if (!_initialized) await init();
      if (apiClient.currentToken == null) return; // not logged in yet
      final fcm = await _messaging.getToken();
      if (fcm == null || fcm.isEmpty) return;
      await apiClient.post('/me/fcm-token', {'fcm_token': fcm});
      debugPrint('[PushService] FCM token sent to backend');

      // keep backend in sync if the token rotates
      _messaging.onTokenRefresh.listen((t) async {
        try {
          if (apiClient.currentToken != null) {
            await apiClient.post('/me/fcm-token', {'fcm_token': t});
          }
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('[PushService] registerToken failed (ignored): $e');
    }
  }
}

final pushService = PushService();
