import 'package:advocate_todo_list/methods/methods.dart';
import 'package:advocate_todo_list/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // For permission handling
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:advocate_todo_list/dialogs/info_dialog.dart';
import 'package:advocate_todo_list/pages/login_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.request(); // Request notification permission

  // Request audio recording permission
  await Permission.microphone.request();

  await requestExactAlarmsPermission();

  // Initialize timezone package
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  // Android initialization settings for notifications
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

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      if (response.payload != null) {
        debugPrint('Notification clicked : ${response.payload}');
        runApp(MyApp(payload: response.payload));
      }
    },
    onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
  );
  await createNotificationChannel();

  runApp(MyApp(payload: payload));
}

@pragma('vm:entry-point')
void backgroundNotificationHandler(NotificationResponse response) {
  if (response.payload != null) {
    debugPrint('Notification clicked in the background : ${response.payload}');
    runApp(MyApp(payload: response.payload));
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
  final String? payload;

  const MyApp({super.key, this.payload});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advocate Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          if (payload != null) {
            Future.delayed(Duration.zero, () {
              _onNotificationClick(context, payload!);
            });
          }
          return const LoginPage();
        },
      ),
    );
  }
}

void _onNotificationClick(BuildContext context, String payload) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const HomePage(),
    ),
  );
  showInfoDialog(
    context,
        () {
      scheduleNotification(context);
    },
  );
}
