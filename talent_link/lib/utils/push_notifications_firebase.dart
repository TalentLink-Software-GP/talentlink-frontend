import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationsFirebase {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    // Request permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get token

    // Initialize local notifications (for Android foreground notifications)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: null,
          macOS: null,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Configure message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle notification when app is terminated
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleTerminatedMessage(initialMessage);
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');

      // Show local notification
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'chat_messages', // Same as in your backend
            'Chat Messages',
            channelDescription: 'Incoming chat messages',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }

  static void _handleBackgroundMessage(RemoteMessage message) {
    print('Got a message whilst in the background!');
    print('Message data: ${message.data}');

    // Navigate to chat screen when notification is tapped
    if (message.data['type'] == 'chat') {
      // You'll need to implement your navigation logic here
      // For example using a global navigator key or similar
      // navigatorKey.currentState?.pushNamed('/chat', arguments: {
      //   'senderId': message.data['senderId'],
      //   'messageId': message.data['messageId'],
      // });
    }
  }

  static void _handleTerminatedMessage(RemoteMessage message) {
    print('Got a message whilst app was terminated!');
    print('Message data: ${message.data}');

    // Similar handling as background message
    _handleBackgroundMessage(message);
  }
}
