import 'dart:convert';

import 'package:advocate_todo_list/const.dart';
import 'package:advocate_todo_list/model/todo_list_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<ToDoResponse?> fetchTodoList(String tabType, String empId) async {
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
    debugPrint('response = $response');
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();

      final data = jsonDecode(responseBody);
      toDoResponse = ToDoResponse.fromJson(data);
    } else {
      debugPrint('Failed: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
  return toDoResponse;
}

Future<String> getActiveUserId() async {
  String? empId = await getLoginUserId();
  debugPrint('empid: $empId');
  const String url = ApiConstants.activeUserEndPoint;

  final request = http.MultipartRequest('POST', Uri.parse(url))
    ..fields['enc_key'] = 'iq8xkfInuzVYYnE4YIpapvQUg6uU'
    ..fields['emp_id'] = empId!;

  try {
    final response = await request.send();
    debugPrint('response: $response');
    debugPrint('code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      debugPrint('responsebody: $responseBody');

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
