import 'package:advocate_todo_list/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initializes notifications and requests permission
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      debugPrint('Message: $message');
      debugPrint('Notification: ${message.notification}');

      if (notification != null && android != null) {
        debugPrint('Title: ${notification.title}');
        debugPrint('Body: ${notification.body}');
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              '@mipmap/ic_launcher',
              'AdvocateTodo',
              channelDescription: 'AdvocateTodo notification channel',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: message.data['payload'],
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message clicked! Message data: ${message.data}');
    });
  }

  // Fetch the FCM token
  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }
}
