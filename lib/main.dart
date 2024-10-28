import 'dart:convert';

import 'package:advocate_todo_list/utils/logger.dart';
import 'package:advocate_todo_list/methods/firebase_api.dart';
import 'package:advocate_todo_list/methods/methods.dart';
import 'package:advocate_todo_list/pages/bulletin_page.dart';
import 'package:advocate_todo_list/pages/cause_list_page.dart';
import 'package:advocate_todo_list/pages/home_page.dart';
import 'package:advocate_todo_list/pages/todo_list_page.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Background title: ${message.notification!.title}');
  debugPrint('Background body: ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Logger().init();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Permission.notification.request();
  await Permission.ignoreBatteryOptimizations.request();

  await Permission.microphone.request();

  await requestExactAlarmsPermission();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

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

  bool isPdfPath(String path) {
    return path.endsWith('.pdf');
  }

  bool isWordPath(String path) {
    return path.endsWith('.doc') || path.endsWith('.docx');
  }

  Future<void> openFileWithFallback(String filePath) async {
    final result = await OpenFilex.open(filePath);
    debugPrint('Open file result: $result');
    if (result.type != ResultType.done) {
      debugPrint('File could not be opened, navigating to HomePage');
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) async {
      Map<String, dynamic> data = jsonDecode(response.payload!);
      final type = data['type'];
      final layout = data['layout'];
      final todoId = data['todo_id'];

      debugPrint('Type: $type');
      debugPrint('Layout : $layout');
      debugPrint('Todo id : $todoId');

      if (type == 'Bulletin') {
        debugPrint('Data in : ${response.payload}');
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
          arguments: {'tabIndex': 1},
        );
      } else if (type == 'Cause List') {
        debugPrint('Data in cause : ${response.payload}');
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
          arguments: {'tabIndex': 2},
        );
      } else if (layout == 'details') {
        // Navigate to TodoListPage with 'Self' tab (index 0) and pass todoId
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
          arguments: {'tabIndex': 0, 'todoTabIndex': 0},
        );
        todoDetailsApi(
          navigatorKey.currentContext!,
          todoId,
          () {},
          'Transfer',
        );
      } else if (layout == 'approval') {
        // Navigate to TodoListPage with 'Assigned' tab (index 1) and pass todoId
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
          arguments: {'tabIndex': 0, 'todoTabIndex': 1},
        );
        todoDetailsApi(
          navigatorKey.currentContext!,
          todoId,
          () {},
          'AcceptDeny',
        );
      } else {
        String payload = response.payload!;
        if (isImagePath(payload) || isPdfPath(payload) || isWordPath(payload)) {
          openFileWithFallback(payload);
          debugPrint('Notification clicked: File opened: $payload');
        } else {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
          todoDetailsApi(
            navigatorKey.currentContext!,
            payload,
            () {},
            'Transfer',
          );
          debugPrint('Notification clicked: Navigated to HomePage: $payload');
        }
      }
    },
    onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
  );

  await createNotificationChannel();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    debugPrint('Message: $message');
    debugPrint('Notification: ${message.notification}');

    if (notification != null && android != null) {
      String payload = jsonEncode(message.data);
      debugPrint('Title: ${notification.title}');
      debugPrint('Body: ${notification.body}');
      debugPrint('Data: ${message.data}');
      debugPrint('Encoded data: $payload');
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
        payload: payload,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen(onNotificationClick);

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    Logger().log('Initial = ${initialMessage.data}');
    runApp(MyApp(message: initialMessage));
  }

  runApp(MyApp(payload: payload));
}

void onNotificationClick(RemoteMessage message) {
  final type = message.data['type'];
  final layout = message.data['layout'];
  final todoId = message.data['todo_id'];

  if (type == 'Bulletin') {
    // Navigate to HomePage with tab 1 selected
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
      arguments: {'tabIndex': 1},
    );
  } else if (type == 'Cause List') {
    // Navigate to HomePage with tab 2 selected
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
      arguments: {'tabIndex': 2},
    );
  } else if (layout == 'details') {
    // Navigate to TodoListPage with 'Self' tab (index 0) and pass todoId
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
      arguments: {'tabIndex': 0, 'todoTabIndex': 0},
    );
    todoDetailsApi(
      navigatorKey.currentContext!,
      todoId,
      () {},
      'Transfer',
    );
  } else if (layout == 'approval') {
    // Navigate to TodoListPage with 'Assigned' tab (index 1) and pass todoId
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
      arguments: {'tabIndex': 0, 'todoTabIndex': 1},
    );
    todoDetailsApi(
      navigatorKey.currentContext!,
      todoId,
      () {},
      'AcceptDeny',
    );
  }
}

@pragma('vm:entry-point')
void backgroundNotificationHandler(NotificationResponse response) async {
  if (response.payload != null) {
    debugPrint('Notification clicked in the background : ${response.payload}');
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
    todoDetailsApi(
      navigatorKey.currentContext!,
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
  final String? payload;
  final RemoteMessage? message;

  const MyApp({
    super.key,
    this.payload,
    this.message,
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
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (_) => HomePage(
              initialTabIndex: args['tabIndex'] ?? 0,
              todoTabIndex: args['todoTabIndex'] ?? 0,
            ),
          );
        }
        return null;
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          if (payload != null || message != null) {
            debugPrint('Inside : $payload');
            Future.delayed(Duration.zero, () {
              _onNotificationClick(context, payload!, message!);
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

void _onNotificationClick(
    BuildContext context, String payload, RemoteMessage message) async {
  final type = message.data['type'];
  final layout = message.data['layout'];

  if (type == 'Bulletin') {
    Logger().log('Bull Payload = $payload');
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
      arguments: {'tabIndex': 1},
    );
  } else if (type == 'Cause List') {
    Logger().log('Cause Payload = $payload');
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
      arguments: {'tabIndex': 2},
    );
  } else {
    debugPrint('Notification clicked from out : $payload');
    Logger().log('Normal Payload = $payload');
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
}
