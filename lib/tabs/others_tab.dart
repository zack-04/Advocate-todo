import 'dart:convert';
import 'package:advocate_todo_list/const.dart';
import 'package:advocate_todo_list/model/todo_list_model.dart';
import 'package:advocate_todo_list/model/user_model.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:http/http.dart' as http;

class OthersTab extends StatefulWidget {
  const OthersTab({super.key, this.toDoResponse});
  final ToDoResponse? toDoResponse;

  @override
  State<OthersTab> createState() => _OthersTabState();
}

class _OthersTabState extends State<OthersTab> {
  UserDataResponse? userDataResponse;
  ToDoResponse? updatedToDoResponse;
  String? selectedUserName;
  String? selectedUserId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getActiveUsersList();
  }

  Future<void> getActiveUsersList() async {
    String? empId = await getLoginUserId();
    debugPrint('empid: $empId');
    const String url = ApiConstants.activeUserEndPoint;

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId!;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonMap = jsonDecode(responseBody);
        debugPrint('responsebody: $responseBody');
        if (mounted) {
          setState(() {
            userDataResponse = UserDataResponse.fromJson(jsonMap);
            isLoading = false;
          });
        }
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error id: $e');
    }
  }

  Future<void> fetchTodoList(String selectedUserId) async {
    String? empId = await getLoginUserId();
    debugPrint('empid: $empId');
    const String url = ApiConstants.todoListEndPoint;
    debugPrint('Selected user id: $selectedUserId');

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId!
      ..fields['type'] = 'Others'
      ..fields['handling_user'] = selectedUserId;

    try {
      final response = await request.send();
      debugPrint('response others = $response');
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        debugPrint('data others = $data');
        setState(() {
          updatedToDoResponse = ToDoResponse.fromJson(data);
        });
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _refreshOthersTab() async {
    if (selectedUserId == null) {
      return;
    }
    await fetchTodoList(selectedUserId!);
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFFF4400);
      case 'Medium':
        return const Color(0xFFFFE100);
      case 'Low':
        return const Color(0xFF659BFF);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final toDoData = updatedToDoResponse?.data ?? widget.toDoResponse?.data;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.white,
            ))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton<String>(
                      value: selectedUserName,
                      padding: const EdgeInsets.all(10),
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(20),
                      hint: const Text('Select User'),
                      isExpanded: true,
                      items: userDataResponse?.data.map((user) {
                        return DropdownMenuItem<String>(
                          value: user.name,
                          child: Text(user.name),
                          onTap: () {
                            selectedUserId = user.userId;
                          },
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        setState(() {
                          selectedUserName = newValue;
                        });
                        await fetchTodoList(selectedUserId!);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshOthersTab,
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      child: toDoData == null || toDoData.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: toDoData.length + 1,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (index < toDoData.length) {
                                  final data = toDoData[index];
                                  debugPrint('Data = ${data.todoId}');
                                  return _listItem(
                                    data.content!,
                                    index + 1,
                                    getPriorityColor(data.priority!),
                                    context,
                                  );
                                } else {
                                  return const SizedBox(height: 100);
                                }
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget _buildEmptyState() {
  return ListView(
    children: const [
      SizedBox(height: 200),
      Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 50),
          child: Text(
            'No ToDo items available',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    ],
  );
}

Widget _listItem(String title, int number, Color color, BuildContext context) {
  return GestureDetector(
    onTap: () {
      // showInfoDialog(
      //   context,
      //   () {
      //     pickDateAndTime(context);
      //   },
      // );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$number.',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> pickDateAndTime(BuildContext context) async {
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

      debugPrint('Scheduled time = $scheduledDateTime');
      Navigator.pop(context);
      showCustomToastification(
        context: context,
        type: ToastificationType.success,
        title: 'Time picked!',
        icon: Icons.check,
        primaryColor: Colors.green,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }
  }
}
