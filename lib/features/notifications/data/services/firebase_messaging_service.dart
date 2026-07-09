import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/realtime/mock_realtime_service.dart';

class FirebaseMessagingService {
  FirebaseMessaging? get _firebaseMessaging =>
      Firebase.apps.isNotEmpty ? FirebaseMessaging.instance : null;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late final INotificationRepository _notificationRepository;

  FirebaseMessagingService() {
    _notificationRepository = GetIt.instance.get<INotificationRepository>();
  }

  Future<void> initialize() async {
    final messaging = _firebaseMessaging;

    if (messaging != null) {
      // Request permission for iOS
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Get FCM token
      try {
        final token = await messaging.getToken();
        if (kDebugMode) debugPrint('FCM Token: $token');
      } catch (e) {
        debugPrint('Error getting FCM token: $e');
      }
    }

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Subscribe to mock realtime notifications (development)
    try {
      final mock = GetIt.instance.get<MockRealtimeService>();
      mock.notifications.listen((payload) async {
        if (kDebugMode) debugPrint('Mock notification received: $payload');
        await _handleMockNotification(payload);
      });
    } catch (_) {
      // Ignore if mock realtime not registered
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('Foreground message received: ${message.notification?.title}');
    }

    // Save notification to repository
    final notification = NotificationEntity(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      timestamp: message.sentTime ?? DateTime.now(),
      target: 'user1', // Fallback for MVP as auth state might be async/stream
      data: message.data,
    );
    // TODO: In production, better to filter notification saving on backend or use current user ID if available.
    // _authRepository.currentUser...

    await _notificationRepository.saveNotification(notification);

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging?.getToken();
  }

  Future<void> _handleMockNotification(Map<String, dynamic> data) async {
    final notification = NotificationEntity(
      id:
          data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title']?.toString() ?? 'Notification',
      body: data['body']?.toString() ?? '',
      timestamp: DateTime.now(),
      target: data['target']?.toString() ?? 'user1',
      data: data,
    );

    await _notificationRepository.saveNotification(notification);

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: data.toString(),
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging?.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging?.unsubscribeFromTopic(topic);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('Background message received: ${message.notification?.title}');
  }
  // Note: In background handler, we can't access GetIt directly
  // The notification will be handled when the app comes to foreground
  // or we could use a different approach like storing in shared preferences
}
