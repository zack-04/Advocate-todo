import 'dart:convert';

import 'package:advocate_todo_list/utils/const.dart';
import 'package:advocate_todo_list/dialogs/info_dialog.dart';
import 'package:advocate_todo_list/utils/logger_read.dart';
import 'package:advocate_todo_list/methods/api_methods.dart';
import 'package:advocate_todo_list/model/todo_list_model.dart';
import 'package:advocate_todo_list/model/user_model.dart';
import 'package:advocate_todo_list/tabs/assigned_tab.dart';
import 'package:advocate_todo_list/tabs/buzz_tab.dart';
import 'package:advocate_todo_list/tabs/others_tab.dart';
import 'package:advocate_todo_list/tabs/self_tab.dart';
import 'package:advocate_todo_list/widgets/custom_button.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key, this.tabIndex = 0});

  final int tabIndex;

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  int _selectedIndex = 0;
  bool showCreateForm = false;
  final List<String> _tabs = ['Self', 'Approval', 'Buzz', 'Others'];
  int selfCount = 0;
  int approvalCount = 0;
  int buzzCount = 0;
  List<ToDoResponse?> tabData = [];
  bool isLoading = false;
  final PageController _pageController = PageController();
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    fetchData();
    _selectedIndex = widget.tabIndex;
    debugPrint('Initial tab index in todo = ${widget.tabIndex}');
  }

  void _onTabTapped(int index) async {
    String? empId = await getLoginUserId();
    debugPrint('Id = $empId');
    if (!showCreateForm) {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 0) {
        if (mounted) {
          final result = await fetchTodoList('Self', empId!, context);
          debugPrint('Result self = ${result!.selfCount}');
          debugPrint('Result self = ${result.data![0].todoStatus}');
          setState(() {
            selfCount = int.parse(result.selfCount!);
            tabData[0] = result;
          });
          debugPrint('Tab data self = ${tabData[0]!.data![0].todoStatus}');
        }
      } else if (index == 1) {
        if (mounted) {
          showLoaderDialog(context);
          final result = await fetchTodoList('Assigned', empId!, context);
          Navigator.pop(context);
          debugPrint('Result assigned = ${result!.approvalCount}');
          setState(() {
            approvalCount = int.parse(result.approvalCount!);
            tabData[1] = result;
          });
        }
      } else if (index == 2) {
        if (mounted) {
          showLoaderDialog(context);
          final result = await fetchTodoList('Buzz', empId!, context);
          Navigator.pop(context);
          debugPrint('Result buzz = ${result!.buzzCount}');
          setState(() {
            buzzCount = int.parse(result.buzzCount!);
            tabData[2] = result;
          });
        }
      } else if (index == 3) {
        if (mounted) {
          showLoaderDialog(context);
          final result = await fetchTodoList('Others', empId!, context);
          Navigator.pop(context);
          debugPrint('Result others length = ${result!.data!.length}');
          setState(() {
            tabData[3] = result;
          });
        }
      }
    }
  }

  void toggleCreateForm() {
    setState(() {
      showCreateForm = !showCreateForm;
      if (showCreateForm) {
        _selectedIndex = -1;
      } else {
        _selectedIndex = 0;
      }
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    String? empId = await getLoginUserId();
    try {
      if (mounted) {
        final results = await Future.wait([
          fetchTodoList('Self', empId!, context),
          fetchTodoList('Assigned', empId, context),
          fetchTodoList('Buzz', empId, context),
          fetchTodoList('Others', empId, context),
        ]);

        debugPrint('Results = $results');
        debugPrint('Length = ${results.length}');

        // Handle the results
        for (var result in results) {
          debugPrint('Result = ${result.toString()}');
        }
        debugPrint('Self count = ${results[0]!.selfCount!}');
        debugPrint('Approval count = ${results[0]!.approvalCount!}');
        debugPrint('Buzz count = ${results[0]!.buzzCount!}');
        debugPrint('parsed self count = ${int.parse(results[0]!.selfCount!)}');
        debugPrint(
            'parsed app count = ${int.parse(results[0]!.approvalCount!)}');

        setState(() {
          tabData = results;
          selfCount = int.parse(results[0]!.selfCount!);
          approvalCount = int.parse(results[0]!.approvalCount!);
          buzzCount = int.parse(results[0]!.buzzCount!);
          _selectedIndex = 0;
        });
      }
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : SafeArea(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/abstractBg.jpeg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'To Do List',
                              style: GoogleFonts.inter(
                                fontSize: 25.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                showCreateForm ? Icons.close : Icons.add,
                                size: 25,
                              ),
                              onPressed: toggleCreateForm,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.abc,
                                size: 25,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoggerRead(),
                                    ));
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      showCreateForm ? const SizedBox() : _buildTabBar(),
                      Expanded(
                        child: showCreateForm
                            ? ToDoCreationForm(
                                onPressed: () async {
                                  debugPrint('Refresh');
                                  await fetchData();
                                  toggleCreateForm();
                                },
                              )
                            : _buildTabContent(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // Future<void> _refreshSelfTab() async {
  //   debugPrint('Refresh in');
  //   String? empId = await getLoginUserId();
  //   await fetchTodoList('Self', empId!, context);
  // }

  // Future<void> _refreshAssignedTab() async {
  //   String? empId = await getLoginUserId();
  //   await fetchTodoList('Others', empId!, context);
  // }

  // Future<void> _refreshOthersTab() async {
  //   String? empId = await getLoginUserId();
  //   await fetchTodoList('Others', empId!);
  // }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: const Color(0xFFF6F6F6),
            border: Border.all(
              color: const Color(0xFFEDF5F8),
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_tabs.length, (index) {
            return GestureDetector(
              onTap: () {
                _onTabTapped(index);
                _pageController.jumpToPage(
                  index,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _selectedIndex == index
                        ? Colors.white
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: index == 2 || index == 3
                            ? const EdgeInsets.symmetric(vertical: 2)
                            : const EdgeInsets.all(0),
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: _selectedIndex == index
                                ? Colors.black
                                : Colors.black54,
                            fontWeight: _selectedIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _containerWidget(_tabs[index]),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _containerWidget(String tabType) {
    if (tabType == 'Self' && selfCount > 0) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Text(
          '$selfCount',
          style: const TextStyle(fontSize: 10),
        ),
      );
    } else if (tabType == 'Assigned' && approvalCount > 0) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Text(
          '$approvalCount',
          style: const TextStyle(fontSize: 10),
        ),
      );
    } else if (tabType == 'Buzz' && buzzCount > 0) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Text(
          '$buzzCount',
          style: const TextStyle(fontSize: 10),
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildTabContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      children: [
        SelfTab(
          toDoResponse: tabData[0],
          onTransfer: () => fetchData(),
          onRefresh: () => fetchData(),
          toggleCreateForm: toggleCreateForm,
        ),
        AssignedTab(
          toDoResponse: tabData[1],
          onTransfer: () => fetchData(),
        ),
        BuzzTab(
          toDoResponse: tabData[2],
        ),
        OthersTab(
          toDoResponse: tabData[3],
        ),
      ],
    );
  }
}

class ToDoCreationForm extends StatefulWidget {
  const ToDoCreationForm({
    super.key,
    required this.onPressed,
  });
  final Future<void> Function() onPressed;

  @override
  State<ToDoCreationForm> createState() => _ToDoCreationFormState();
}

class _ToDoCreationFormState extends State<ToDoCreationForm> {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();
  String selectedPriority = 'High';
  bool isDropdownOpen = false;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  bool isLoading1 = false;
  UserDataResponse? userDataResponse;
  String? selectedUserName;
  String? selectedUserId;
  String? loginUserRole;

  @override
  void initState() {
    super.initState();
    getActiveUsersList();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    String? role = await getLoginUserRole();
    setState(() {
      loginUserRole = role;
    });
    debugPrint('Role = $loginUserRole');
  }

  Future<void> getActiveUsersList() async {
    setState(() {
      isLoading1 = true;
    });
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
            for (var user in userDataResponse?.data ?? []) {
              if (user.userId == empId) {
                selectedUserName = user.name;
                selectedUserId = user.userId;
                break;
              }
            }
          });
        }
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error id: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading1 = false;
        });
      }
    }
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.yellow;
      case 'Low':
        return Colors.blue[900]!;
      default:
        return Colors.transparent;
    }
  }

  Future<void> todoCreation() async {
    setState(() {
      isLoading = true;
    });
    String? empId = await getLoginUserId();
    debugPrint('Id = $empId');
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    debugPrint('Formatted date = $formattedDate');
    const String url = ApiConstants.todoCreationEndPoint;

    debugPrint('Content = ${controller.text}');
    debugPrint('Priority = $selectedPriority');
    debugPrint('userid = $selectedUserId');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'enc_key': encKey,
          'emp_id': empId,
          'todo': controller.text,
          'priority': selectedPriority,
          'due_date': formattedDate,
          'assign_id': loginUserRole == 'Admin' ? selectedUserId : empId,
        },
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      debugPrint('Body = $responseBody');
      debugPrint('status = ${responseBody['status']}');

      if (responseBody['status'] == 'Success') {
        if (mounted) {
          showCustomToastification(
            context: context,
            type: ToastificationType.success,
            title: 'Todo created successfully!',
            primaryColor: Colors.green,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
        }
        await widget.onPressed();
      } else {
        if (mounted) {
          showCustomToastification(
            context: context,
            type: ToastificationType.error,
            title: responseBody['status'],
            primaryColor: Colors.red,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomToastification(
          context: context,
          type: ToastificationType.error,
          title: 'An error occurred! Please check your connection.',
          primaryColor: Colors.red,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        );
      }
      debugPrint('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: isLoading1
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Stack(
              children: [
                Image.asset(
                  'assets/images/abstractBg.jpeg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 20,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "To Do Creation",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 130,
                          ),
                          child: TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            cursorColor: Colors.black,
                            cursorHeight: 25,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            maxLines: null,
                            maxLength: 250,
                            minLines: 3,
                            keyboardType: TextInputType.multiline,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter content';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(16, 8, 8, 8),
                              filled: true,
                              fillColor: const Color(0xFFF9F9F9),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Priority',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDropdownOpen = !isDropdownOpen;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                              top: 14,
                              bottom: 14,
                              left: 15,
                              right: 15,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFF6F6F6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color:
                                            _getPriorityColor(selectedPriority),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 22),
                                    Text(
                                      selectedPriority,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  isDropdownOpen
                                      ? FontAwesome.chevron_up_solid
                                      : FontAwesome.chevron_down_solid,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Complete Before',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFF6F6F6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd-MMM-yyyy')
                                      .format(selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        loginUserRole == 'Admin'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Assign To',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 55,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xFFF6F6F6),
                                    ),
                                    child: DropdownButton<String>(
                                      value: selectedUserName,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 10,
                                      ),
                                      underline: const SizedBox(),
                                      borderRadius: BorderRadius.circular(20),
                                      hint: const Text(
                                        'Select User',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                      icon: const Icon(
                                        FontAwesome.chevron_down_solid,
                                        size: 19,
                                        color: Colors.black,
                                      ),
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
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(height: 40),
                        CustomButton(
                          widget: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Create List',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  if (selectedUserId == null) {
                                    showCustomToastification(
                                      context: context,
                                      type: ToastificationType.error,
                                      title: 'Select a user',
                                      primaryColor: Colors.red,
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    );
                                    return;
                                  }
                                  await todoCreation();
                                },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Dropdown menu overlay
                if (isDropdownOpen)
                  Positioned(
                    top: 170,
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        children: <String>['High', 'Medium', 'Low']
                            .map((priority) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedPriority = priority;
                                      isDropdownOpen = false;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 15,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(priority),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 22),
                                        Text(
                                          priority,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
