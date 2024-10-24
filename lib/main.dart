import 'package:advocate_todo_list/methods/firebase_api.dart';
import 'package:advocate_todo_list/methods/methods.dart';
import 'package:advocate_todo_list/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:advocate_todo_list/dialogs/info_dialog.dart';
import 'package:advocate_todo_list/pages/login_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  await Permission.notification.request();
  await Permission.ignoreBatteryOptimizations.request();

  await Permission.microphone.request();

  await requestExactAlarmsPermission();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  String? payload;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    payload = notificationAppLaunchDetails?.notificationResponse?.payload;
  }

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  void openImage(String imagePath) async {
    final result = await OpenFilex.open(imagePath);
    debugPrint('Open file result: $result');
  }

  bool isImagePath(String path) {
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.gif');
  }

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) async {
      if (response.payload != null) {
        String payload = response.payload!;
        if (isImagePath(payload)) {
          openImage(payload);
          debugPrint(
              'Notification clicked: Image opened from payload: $payload');
        } else {
          MyApp.navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
          todoDetailsApi(
            MyApp.navigatorKey.currentContext!,
            payload,
            () {},
            'Transfer',
          );
          debugPrint(
              'Notification clicked: Navigated to HomePage with payload: $payload');
        }
      }
    },
    onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
  );

  await createNotificationChannel();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
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
        payload: message.data['payload'], // Pass the payload
      );
    }
  });

  runApp(MyApp(
    payload: payload,
  ));
}

@pragma('vm:entry-point')
void backgroundNotificationHandler(NotificationResponse response) async {
  if (response.payload != null) {
    debugPrint('Notification clicked in the background : ${response.payload}');
    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
    todoDetailsApi(
      MyApp.navigatorKey.currentContext!,
      response.payload!,
      () {},
      'Transfer',
    );
  }
}

// Function to request exact alarm permission on Android 13+
Future<void> requestExactAlarmsPermission() async {
  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    await androidPlugin.requestExactAlarmsPermission();
    debugPrint('Exact alarm permission granted');
  }
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final String? payload;

  const MyApp({
    super.key,
    this.payload,
  });

  Future<bool> isLoggedInOrNot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('login_user_id');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advocate Todo List',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          if (payload != null) {
            debugPrint('Inside : $payload');
            Future.delayed(Duration.zero, () {
              _onNotificationClick(context, payload!);
            });
          }

          return FutureBuilder<bool>(
            future: isLoggedInOrNot(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error occurred'));
              } else {
                final isLoggedIn = snapshot.data ?? false;
                return isLoggedIn ? const HomePage() : const LoginPage();
              }
            },
          );
        },
      ),
    );
  }
}

void _onNotificationClick(BuildContext context, String payload) async {
  debugPrint('Notification clicked from out : $payload');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const HomePage(),
    ),
  );
  todoDetailsApi(
    context,
    payload,
    () {},
    'Transfer',
  );
}
