import 'dart:convert';
import 'package:advocate_todo_list/utils/const.dart';
import 'package:advocate_todo_list/dialogs/transfer_dialog.dart';
import 'package:advocate_todo_list/methods/methods.dart';
import 'package:advocate_todo_list/model/todo_details_model.dart';
import 'package:advocate_todo_list/model/user_model.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

class InfoDialog extends StatefulWidget {
  const InfoDialog({
    super.key,
    required this.toDoDetailsResponse,
    required this.onTransfer,
    required this.whichButtonToShow,
  });
  final ToDoDetailsResponse toDoDetailsResponse;
  final VoidCallback onTransfer;
  final String whichButtonToShow;

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  bool isLoading = false;
  bool isLoading1 = false;
  bool isLoading2 = false;

  String? userRole;
  String? empId;
  DateTime? lastBuzzTime;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    String? role = await getLoginUserRole();
    String? empId1 = await getLoginUserId();
    setState(() {
      userRole = role;
      empId = empId1!;
    });
    debugPrint('Role = $role');
    debugPrint('Empid = $empId1');
  }

  Future<void> todoApproveStatus(String status) async {
    if (status == 'Approved') {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isLoading1 = true;
      });
    }
    final data = widget.toDoDetailsResponse.data;
    String? empId = await getLoginUserId();
    debugPrint('empid: $empId');
    debugPrint('Transfer id: ${data.transferApproveId!}');
    const String url = ApiConstants.todoApproveStatus;

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId!
      ..fields['transfer_id'] = data.transferApproveId!
      ..fields['status'] = status;

    try {
      if (empId != data.transferPersonId) {
        if (mounted) {
          if (status == 'Approved') {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading1 = false;
            });
          }
        }
        return;
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Transfer body: $responseBody');
        if (mounted) {
          showCustomToastification(
            context: context,
            type: ToastificationType.success,
            title: status == 'Approved'
                ? 'Accepted successfully!'
                : 'Denied successfully!',
            // icon: Icons.check,
            primaryColor: Colors.green,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
          widget.onTransfer();
          Navigator.pop(context);
        }
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error id: $e');
    } finally {
      if (mounted) {
        if (status == 'Approved') {
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading1 = false;
          });
        }
      }
    }
  }

  Future<void> getActiveUsersList(String buttonTextName) async {
    setState(() {
      isLoading2 = true;
    });
    String? empId = await getLoginUserId();
    debugPrint('empid: $empId');
    const String url = ApiConstants.allotingUserList;

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId!
      ..fields['todo_id'] = widget.toDoDetailsResponse.data.todoId!;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonMap = jsonDecode(responseBody);
        debugPrint('responsebody: $responseBody');
        if (mounted) {
          userRole != 'Admin' ? Navigator.pop(context) : null;
          showTransferDialog(
            context,
            UserDataResponse.fromJson(jsonMap),
            widget.toDoDetailsResponse.data.todoId!,
            widget.onTransfer,
            buttonTextName,
          );
        }
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error id: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading2 = false;
        });
      }
    }
  }

  Future<void> todoBuzzApi() async {
    if (lastBuzzTime != null) {
      final int remainingSeconds =
          30 - DateTime.now().difference(lastBuzzTime!).inSeconds;
      debugPrint('Sec: $remainingSeconds');

      if (remainingSeconds > 0) {
        toastification.dismissAll();
        showCustomToastification(
          context: context,
          type: ToastificationType.error,
          title: 'Wait $remainingSeconds seconds',
          // icon: Icons.error,
          primaryColor: Colors.red,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        );
        return;
      }
    }
    String? empId = await getLoginUserId();
    debugPrint('empid: $empId');
    const String url = ApiConstants.todoBuzz;

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId!
      ..fields['todo_id'] = widget.toDoDetailsResponse.data.todoId!;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonMap = jsonDecode(responseBody);
        debugPrint('Buzz response: $responseBody');
        lastBuzzTime = DateTime.now();
        if (mounted) {
          showCustomToastification(
            context: context,
            type: ToastificationType.success,
            title: 'Buzzing done successfully!',
            // icon: Icons.check,
            primaryColor: Colors.green,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
        }
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error id: $e');
    }
  }

  Future<void> todoPendingApi() async {
    String? empId = await getLoginUserId();
    debugPrint('empid: $empId');
    const String url = ApiConstants.todoPendingApi;

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId!
      ..fields['todo_id'] = widget.toDoDetailsResponse.data.todoId!
      ..fields['todo_status'] = widget.toDoDetailsResponse.data.todoStatus!;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Pending api response: $responseBody');

        if (mounted) {
          showCustomToastification(
            context: context,
            type: ToastificationType.success,
            title: 'Moved to pending',
            primaryColor: Colors.green,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
        }
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error id: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.toDoDetailsResponse.data;
    final date = data.dateDiff;
    final showSwitch = data.handlingPersonEnc! == empId || userRole == 'Admin';
    final move = data.todoStatus! != 'Pending' && userRole == 'Admin';
    final isVisible = widget.whichButtonToShow == 'Transfer' ||
        widget.whichButtonToShow == 'Others';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.only(
          top: 20,
          right: 20,
          bottom: 20,
          left: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 0),
              child: Row(
                children: [
                  Text(
                    'To Do List',
                    style: GoogleFonts.inter(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  isVisible
                      ? PopupMenuButton<String>(
                          padding: const EdgeInsets.all(0),
                          tooltip: '',
                          elevation: 14,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          position: PopupMenuPosition.under,
                          constraints: const BoxConstraints(
                            maxWidth: 190,
                          ),
                          style: const ButtonStyle(),
                          onSelected: (String value) async {
                            switch (value) {
                              case 'Snooze':
                                await scheduleNotification(
                                  context,
                                  widget.toDoDetailsResponse.data.todoId!,
                                );
                                break;
                              case 'Switch':
                                await getActiveUsersList('Switch');
                                break;
                              case 'Buzz':
                                await todoBuzzApi();
                                break;
                              case 'Move':
                                await todoPendingApi();
                                break;
                              case 'Close':
                                break;
                            }
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Colors.grey,
                          ),
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'Snooze',
                              height: 40,
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 3),
                                    child: Icon(
                                      Icons.alarm,
                                      size: 18,
                                      color: Color(0xFF545454),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Snooze',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF545454),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (showSwitch) ...[
                              PopupMenuItem<String>(
                                value: 'Switch',
                                height: 40,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: SvgPicture.asset(
                                        'assets/icons/arrow.svg',
                                        height: 16,
                                        width: 16,
                                        //color: const Color(0xFF545454),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Switch',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF545454),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            PopupMenuItem<String>(
                              value: 'Buzz',
                              height: 40,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: SvgPicture.asset(
                                      'assets/icons/buzz.svg',
                                      height: 17,
                                      width: 17,
                                      color: const Color(0xFF545454),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Buzz',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF545454),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (move) ...[
                              PopupMenuItem<String>(
                                value: 'Move',
                                height: 40,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: SvgPicture.asset(
                                        'assets/icons/move.svg',
                                        height: 16,
                                        width: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Move to Pending',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF545454),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            PopupMenuItem<String>(
                              value: 'Close',
                              padding: const EdgeInsets.all(0),
                              height: 40,
                              child: Container(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade400,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Color(0xFFFF4343),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Close',
                                      style: TextStyle(
                                        color: Color(0xFFFF4343),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Material(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFF545454),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                data.content!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            _rowWidget('Created By:', data.creatorName!),
            _rowWidget('Created On:', data.createdOn!),
            _rowWidget(
              'Complete By:',
              date == null
                  ? '${data.completeBy!} (0 days)'
                  : '${data.completeBy!} ($date days)',
            ),
            _rowWidget('Priority:', data.priority!),
            widget.whichButtonToShow == 'AcceptDeny'
                ? const SizedBox()
                : _rowWidget(
                    'Transfer To:',
                    data.transferPersonName == null
                        ? '-'
                        : '${data.transferPersonName} (${data.transferStatus})',
                  ),
            _rowWidget('Handling By:', data.handlingPersonName!),
            const SizedBox(height: 15),
            if ((widget.toDoDetailsResponse.data.handlingPersonEnc! == empId ||
                        userRole == 'Admin') &&
                    widget.whichButtonToShow == 'Transfer' ||
                widget.whichButtonToShow == 'Others')
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 10,
                  top: 20,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: MaterialButton(
                    height: 42,
                    minWidth: 130,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: const Color(0xFF4B4B4B),
                    onPressed: isLoading2
                        ? () {}
                        : () async {
                            await getActiveUsersList('Transfer Now');
                          },
                    child: isLoading2
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Transfer',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            if (widget.whichButtonToShow == 'AcceptDeny')
              _buildButton(
                widget.whichButtonToShow,
                () async {
                  await todoApproveStatus('Approved');
                },
                () async {
                  await todoApproveStatus('Rejected');
                },
                context,
                isLoading
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
                        'Accept',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                isLoading1
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
                        'Deny',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildButton(
  String text,
  void Function()? accept,
  void Function()? deny,
  BuildContext context,
  Widget acceptText,
  Widget denyText,
) {
  switch (text) {
    case 'AcceptDeny':
      return _buildAcceptDenyButtons(
        context,
        accept,
        deny,
        acceptText,
        denyText,
      );
    default:
      return Container();
  }
}

Widget _buildAcceptDenyButtons(
  BuildContext context,
  void Function()? accept,
  void Function()? deny,
  Widget acceptText,
  Widget denyText,
) {
  return Padding(
    padding: const EdgeInsets.only(
      left: 30,
      right: 10,
      top: 20,
    ),
    child: Row(
      children: [
        Expanded(
          child: MaterialButton(
            height: 42,
            minWidth: 130,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            color: const Color(0xFF08970B),
            onPressed: accept,
            child: acceptText,
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: MaterialButton(
            height: 42,
            minWidth: 130,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            color: const Color(0xFFBF0202),
            onPressed: deny,
            child: denyText,
          ),
        ),
      ],
    ),
  );
}

void showLoaderDialog(BuildContext context) {
  debugPrint('Loading');
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    },
  );
}

Future<void> todoDetailsApi(
  BuildContext context,
  String todoId,
  VoidCallback onTransfer,
  String whichButtonToShow,
) async {
  String? empId = await getLoginUserId();
  debugPrint('Id = $empId');
  debugPrint('api todo id = $todoId');
  const String url = ApiConstants.todoDetailsEndPoint;
  showLoaderDialog(context);

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'enc_key': encKey,
        'emp_id': empId,
        'todo_id': todoId,
      },
    );
    Navigator.pop(context);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['status'] == 'Success') {
        final todoDetailsResponse = ToDoDetailsResponse.fromJson(responseBody);
        print('Response body = $responseBody');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return InfoDialog(
              toDoDetailsResponse: todoDetailsResponse,
              onTransfer: onTransfer,
              whichButtonToShow: whichButtonToShow,
            );
          },
        );
      }
    } else {
      showCustomToastification(
        context: context,
        type: ToastificationType.error,
        title: 'Server error! Please try again.',
        // icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }
  } catch (e) {
    showCustomToastification(
      context: context,
      type: ToastificationType.error,
      title: 'An error occurred! Please check your connection.',
      // icon: Icons.error,
      primaryColor: Colors.red,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }
}

Widget _rowWidget(String text1, String text2) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, bottom: 10),
    child: Row(
      children: [
        Text(
          text1,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text2,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
