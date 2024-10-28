import 'package:advocate_todo_list/utils/const.dart';
import 'package:advocate_todo_list/model/user_model.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog({
    super.key,
    required this.userDataResponse,
    required this.todoId,
    required this.onTransfer,
    required this.buttonTextName,
  });
  final UserDataResponse userDataResponse;
  final String todoId;
  final VoidCallback onTransfer;
  final String buttonTextName;

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  String? selectedPerson;
  final TextEditingController controller = TextEditingController();
  String? userRole;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    String? role = await getLoginUserRole();
    setState(() {
      userRole = role;
    });
    debugPrint('Role = $userRole');
  }

  Future<void> tranferToOtherUser() async {
    setState(() {
      isLoading = true;
    });
    String? empId = await getLoginUserId();
    debugPrint('empid: $empId');
    debugPrint('Todo id: ${widget.todoId}');
    String url = widget.buttonTextName == 'Transfer Now'
        ? ApiConstants.tranferEndPoint
        : ApiConstants.todoSwitch;
    debugPrint('Url: $url');

    if (selectedPerson == null) {
      if (mounted) {
        showCustomToastification(
          context: context,
          type: ToastificationType.error,
          title: 'Please select a user',
          // icon: Icons.error,
          primaryColor: Colors.red,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        );
      }
      setState(() {
        isLoading = false;
      });
      return;
    }

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['enc_key'] = encKey
      ..fields['emp_id'] = empId!
      ..fields['transfer_to'] = selectedPerson!
      ..fields['todo_id'] = widget.todoId
      ..fields['remarks'] = controller.text;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Transfer body: $responseBody');
        if (mounted) {
          showCustomToastification(
            context: context,
            type: ToastificationType.success,
            title: widget.buttonTextName == 'Switch'
                ? 'Switched successfully!'
                : 'Transferred successfully!',
            // icon: Icons.check,
            primaryColor: Colors.green,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
          widget.onTransfer();
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        debugPrint('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error id: $e');
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
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.buttonTextName == 'Switch' ? 'Switch To' : 'Transfer To',
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Radio button list
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.userDataResponse.data.length,
                itemBuilder: (context, index) {
                  final data = widget.userDataResponse.data;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedPerson = data[index].userId;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedPerson == data[index].userId
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selectedPerson == data[index].userId
                                ? Colors.black
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            data[index].name,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Remarks input
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Remarks',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                minLines: 4,
                maxLines: null,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 0,
                top: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      height: 42,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: const Color(0xFFD8D8D8),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Close',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: MaterialButton(
                      height: 42,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: const Color(0xFF4B4B4B),
                      onPressed: () async {
                        await tranferToOtherUser();
                      },
                      child: isLoading
                          ? const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.buttonTextName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showTransferDialog(
  BuildContext context,
  UserDataResponse userDataResponse,
  String todoId,
  VoidCallback onTransfer,
  String buttonTextName,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return TransferDialog(
        userDataResponse: userDataResponse,
        todoId: todoId,
        onTransfer: () => onTransfer(),
        buttonTextName: buttonTextName,
      );
    },
  );
}
