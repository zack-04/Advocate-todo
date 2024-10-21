import 'dart:convert';
import 'package:advocate_todo_list/const.dart';
import 'package:advocate_todo_list/dialogs/transfer_dialog.dart';
import 'package:advocate_todo_list/methods/methods.dart';
import 'package:advocate_todo_list/model/todo_details_model.dart';
import 'package:advocate_todo_list/model/user_model.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
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
            icon: Icons.check,
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
          Navigator.pop(context);
          showTransferDialog(
            context,
            UserDataResponse.fromJson(jsonMap),
            widget.toDoDetailsResponse.data.todoId!,
            widget.onTransfer,
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
              padding: const EdgeInsets.only(left: 20, right: 10),
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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        debugPrint('Todo id = ${data.todoId!}');
                        await scheduleNotification(context, data.todoId!);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: const Icon(
                          Icons.alarm,
                          size: 20,
                          color: Color(0xFF545454),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Icon(
                          Icons.close,
                          size: 25,
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
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
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
                        : '${data.transferPersonName} (${data.todoStatus})',
                  ),
            _rowWidget('Handling By:', data.handlingPersonName!),
            const SizedBox(height: 15),
            _buildButton(
              widget.whichButtonToShow,
              () async {
                await getActiveUsersList();
              },
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
  void Function()? onPressed,
  void Function()? accept,
  void Function()? deny,
  BuildContext context,
  Widget acceptText,
  Widget denyText,
) {
  switch (text) {
    case 'Transfer':
      return _buildTransferButton(onPressed);
    case 'AcceptDeny':
      return _buildAcceptDenyButtons(
        context,
        accept,
        deny,
        acceptText,
        denyText,
      );
    case 'Nothing':
      return const SizedBox();
    default:
      return Container();
  }
}

Widget _buildTransferButton(void Function()? onPressed) {
  return Padding(
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
        onPressed: onPressed,
        child: Text(
          'Transfer',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
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
        icon: Icons.error,
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
      icon: Icons.error,
      primaryColor: Colors.red,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }
}

// void showInfoDialog(
//   BuildContext context,
//   void Function()? onTap,
//   ToDoDetailsResponse toDoDetailsResponse,
// ) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return InfoDialog(
//         onTap: onTap,
//         toDoDetailsResponse: toDoDetailsResponse,
//       );
//     },
//   );
// }

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
