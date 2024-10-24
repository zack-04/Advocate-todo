import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initializes notifications and requests permission
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
  }

  // Fetch the FCM token
  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }
}


