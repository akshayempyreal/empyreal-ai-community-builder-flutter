import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, 
  // ensure you call `Firebase.initializeApp()` here as well.
  if (kDebugMode) {
    print("FCM: Handling a background message: ${message.messageId}");
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Android Notification Channel for high-importance notifications
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  /// Initializes the notification service
  Future<void> initialize() async {
    if (kIsWeb) return;

    // Set the background messaging handler early on
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Create the Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Initialize local notifications for foreground display
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap here if needed in the future
        if (kDebugMode) {
          print("FCM: Notification tapped: ${details.payload}");
        }
      },
    );

    // Request permissions
    await _requestPermissions();

    // Setup listeners
    _configureFCM();

    // Get initial token
    await _logToken();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('FCM: User granted permission: ${settings.authorizationStatus}');
    }
  }

  void _configureFCM() {
    // 1. Foreground Message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('FCM: Received a foreground message: ${message.notification?.title}');
      }

      RemoteNotification? notification = message.notification;
      
      // If `onMessage` is triggered, we manually show a local notification
      // because FCM does not show UI notifications while the app is in the foreground.
      if (notification != null && !kIsWeb) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: message.notification?.android?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    // 2. Token refresh listener
    _fcm.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print('FCM: Token refreshed: $newToken');
      }
    });
  }

  Future<void> _logToken() async {
    try {
      String? token = await _fcm.getToken();
      if (kDebugMode) {
        print('FCM: Token: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM: Error getting token: $e');
      }
    }
  }
}
