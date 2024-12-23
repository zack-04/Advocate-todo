import 'dart:convert';

import 'package:advocate_todo_list/utils/const.dart';
import 'package:advocate_todo_list/dialogs/info_dialog.dart';
import 'package:advocate_todo_list/model/todo_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<ToDoResponse?> fetchTodoList(
  String tabType,
  String empId,
  BuildContext context,
) async {
  ToDoResponse? toDoResponse;
  const String url = ApiConstants.todoListEndPoint;

  final request = http.MultipartRequest('POST', Uri.parse(url))
    ..fields['enc_key'] = encKey
    ..fields['emp_id'] = empId
    ..fields['type'] = tabType;

  if (tabType == 'Others') {
    String handlingUserId = await getActiveUserId();
    debugPrint('Handling id: $handlingUserId');
    if (handlingUserId.isNotEmpty) {
      request.fields['handling_user'] = handlingUserId;
    }
  }

  try {
    final response = await request.send();
    debugPrint('response todo status code = ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      debugPrint('body todo = $responseBody');

      if (responseBody.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        debugPrint('data todo = $data');

        if (data.isNotEmpty && data['status'] == 'Success') {
          toDoResponse = ToDoResponse.fromJson(data);
          debugPrint('todoresponse = $toDoResponse');
        } else {
          debugPrint('Invalid or empty data: $data');
        }
      } else {
        debugPrint('Response body is empty');
      }
    } else {
      debugPrint('Failed with status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error in todo list: $e');
  }

  return toDoResponse;
}

Future<String> getActiveUserId() async {
  String? empId = await getLoginUserId();
  debugPrint('empid: $empId');
  const String url = ApiConstants.activeUserEndPoint;

  final request = http.MultipartRequest('POST', Uri.parse(url))
    ..fields['enc_key'] = encKey
    ..fields['emp_id'] = empId!;

  try {
    final response = await request.send();
    debugPrint('response user: $response');
    debugPrint('code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      debugPrint('responsebody user: $responseBody');

      final json = jsonDecode(responseBody);
      final data = json['data'];
      debugPrint('data: $data');
      if (data is List && data.isNotEmpty) {
        debugPrint('in');
        debugPrint('userid: ${data[0]['user_id']}');
        return data[0]['user_id'];
      }
    } else {
      debugPrint('Failed: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error id: $e');
  }
  return '';
}
