import 'package:advocate_todo_list/main.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:toastification/toastification.dart';

Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'task_reminder',
    'Task Reminder',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> showNotification({
  required String title,
  required String body,
  required tz.TZDateTime time,
  required String todoId,
}) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'task_reminder',
    'Task reminder',
    importance: Importance.max,
    priority: Priority.high,
  );
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  // await flutterLocalNotificationsPlugin.show(
  //   0,
  //   title,
  //   body,
  //   platformChannelSpecifics,
  //   payload: 'item x',
  // );
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    title,
    body,
    time,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: todoId,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

Future<void> scheduleNotification(BuildContext context, String todoId) async {
  // Date picker
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );
  debugPrint('Picked date = $pickedDate');

  if (pickedDate != null) {
    // Time picker
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    debugPrint('Picked time = $pickedTime');

    if (pickedTime != null) {
      // Combine date and time
      final DateTime scheduledDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      final tz.TZDateTime tzScheduledDateTime = tz.TZDateTime.from(
        scheduledDateTime,
        tz.local,
      );

      debugPrint('Scheduled time = $tzScheduledDateTime');

      if (scheduledDateTime.isBefore(DateTime.now())) {
        showCustomToastification(
          context: context,
          type: ToastificationType.error,
          title: 'Please select a future date and time.',
          icon: Icons.error,
          primaryColor: Colors.red,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        );
      } else {
        await _setNotification(tzScheduledDateTime, context, todoId);
      }
    }
  }
}

Future<void> _setNotification(
  tz.TZDateTime scheduledDateTime,
  BuildContext context,
  String todoId,
) async {
  debugPrint('Set');
  Navigator.pop(context);
  showCustomToastification(
    context: context,
    type: ToastificationType.success,
    title: 'Notification scheduled!',
    icon: Icons.check,
    primaryColor: Colors.green,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  );

  // Schedule the notification
  await showNotification(
    title: 'To Do Reminder',
    body: 'You have a to-do task scheduled.',
    time: scheduledDateTime,
    todoId: todoId,
  );
  HapticFeedback.vibrate();
}
