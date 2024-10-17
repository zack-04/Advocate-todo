import 'package:shared_preferences/shared_preferences.dart';

String encKey = 'iq8xkfInuzVYYnE4YIpapvQUg6uU';

class ApiConstants {
  static const String baseUrl = 'https://todo.sortbe.com/api/';
  static const String loginEndpoint = '${baseUrl}Login/Login';
  static const String todoListEndPoint = '${baseUrl}Todo/Todo-List';
  static const String activeUserEndPoint = '${baseUrl}User/Active-User-List';
  static const String todoCreationEndPoint = '${baseUrl}Todo/Todo-Creation';
  static const String todoDetailsEndPoint = '${baseUrl}Todo/Todo-Details';
  static const String tranferEndPoint = '${baseUrl}Todo/Todo-Transfer';
}

Future<String?> getLoginUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('login_user_id');
}

const Map<String, String> taskStatus = {
  "IN_PROGRESS": 'Work in Progress',
  "PENDING": 'Pending Task',
  "COMPLETED": 'Completed Task',
};
