import 'package:advocate_todo_list/utils/const.dart';
import 'package:advocate_todo_list/dialogs/search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:toastification/toastification.dart';

import '../widgets/toast_message.dart';

class TextNoteDialog extends StatefulWidget {
  final Function refreshCallback;

  const TextNoteDialog({super.key, required this.refreshCallback});

  @override
  State<TextNoteDialog> createState() => _TextNoteDialogState();
}

class _TextNoteDialogState extends State<TextNoteDialog> {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? loginUserId;
  List<Map<String, String>> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _getLoginUserId();
  }

  Future<void> _getLoginUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginUserId = prefs.getString('login_user_id');
    });
  }

  Future<void> _createBulletin() async {
    if (loginUserId == null) {
      showCustomToastification(
        context: context,
        type: ToastificationType.error,
        title: 'User Not Logged In',
        // icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
      return;
    }

    final String content = controller.text;
    if (content.isEmpty) {
      showCustomToastification(
        context: context,
        type: ToastificationType.error,
        title: 'Note Required',
        // icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onTap: () {
          // Optional: Navigate to a specific page or handle onTap event
        },
      );
      return;
    }

    final List<String> tagUsers =
        selectedUsers.map((user) => user['user_id']!).toList();

    print("Selected user IDs: $tagUsers");

    const String url = ApiConstants.bulletinCreate;
    final Map<String, String> body = {
      'enc_key': encKey,
      'emp_id': loginUserId!,
      'type': 'Text',
      'tag_users': jsonEncode(tagUsers),
      'content': content,
    };

    print("API Request Body: $body");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type':
              'application/x-www-form-urlencoded', // or 'application/json'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          Navigator.pop(context);
          widget.refreshCallback();
        } else {
          showCustomToastification(
            context: context,
            type: ToastificationType.error,
            title: 'Failed To Create Bulletin',
            // icon: Icons.error,
            primaryColor: Colors.red,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
        }
      } else {
        showCustomToastification(
          context: context,
          type: ToastificationType.error,
          title: 'Failed to Create Bulletin',
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
        title: 'Server Error',
        // icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Create Bulletin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 25,
                          color: Color(0xFF545454),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                const Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    "Bulletin Content",
                    style: TextStyle(

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: 130,
                    ),
                    child: TextFormField(
                      controller: controller,
                      cursorColor: Colors.black,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: null,
                      maxLength: 250,
                      minLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter note';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    'Tag Users',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                UserSearch(
                  selectedUsers: selectedUsers,
                  onUserSelected: (user) {
                    setState(() {
                      selectedUsers.add(user);
                    });
                    // Debug log after adding a user
                    print("User added: ${user['user_id']}");
                    print("Current selected users: $selectedUsers");
                  },
                  onUserRemoved: (user) {
                    setState(() {
                      selectedUsers.removeWhere(
                          (selected) => selected['user_id'] == user['user_id']);
                    });
                    // Debug log after removing a user
                    print("User removed: ${user['user_id']}");
                    print("Current selected users: $selectedUsers");
                  },
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 25,
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
                      onPressed: () async {
                        await _createBulletin();
                      },
                      child: Text(
                        'Send',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showTextNoteDialog(BuildContext context, Function refreshCallback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return TextNoteDialog(refreshCallback: refreshCallback);
    },
  );
}
