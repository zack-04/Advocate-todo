import 'package:shared_preferences/shared_preferences.dart';

String encKey = 'iq8xkfInuzVYYnE4YIpapvQUg6uU';

class ApiConstants {
  //base url
  static const String baseUrl = 'https://todo.sortbe.com/api/';

  //login urls
  static const String loginEndpoint = '${baseUrl}Login/Login';
  static const String sendFcmToken = '${baseUrl}Login/Firebase-Token';

  //active user list urls
  static const String activeUserEndPoint = '${baseUrl}User/Active-User-List';
  static const String allUsers = '${baseUrl}User/Active-User-List';

  //todo urls
  static const String todoListEndPoint = '${baseUrl}Todo/Todo-List';
  static const String todoCreationEndPoint = '${baseUrl}Todo/Todo-Creation';
  static const String todoDetailsEndPoint = '${baseUrl}Todo/Todo-Details';
  static const String tranferEndPoint = '${baseUrl}Todo/Todo-Transfer';
  static const String todoApproveStatus = '${baseUrl}Todo/Todo-Approval-Status';
  static const String todoWorkStatusChange = '${baseUrl}Todo/Todo-Work-Status';
  static const String allotingUserList = '${baseUrl}Todo/ToDo-Other-User-List';
  static const String todoSwitch = '${baseUrl}Todo/Todo-Switch';
  static const String todoBuzz = '${baseUrl}Todo/ToDo-Buzz';
  static const String todoPendingApi = '${baseUrl}Todo/ToDo-Pending';

  //bulletin and cause list urls
  static const String bulletinCreate = '${baseUrl}bulletin/Bulletin-Creation';
  static const String bulletinList = '${baseUrl}bulletin/Bulletin-List';
  static const String causeList = '${baseUrl}Cause/Cause-List';
}


//get login user id
Future<String?> getLoginUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('login_user_id');
}

//get login user role
Future<String?> getLoginUserRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('login_user_role');
}

const Map<String, String> taskStatus = {
  "IN_PROGRESS": 'Work in Progress',
  "PENDING": 'Pending Task',
  "COMPLETED": 'Completed Task',
};
