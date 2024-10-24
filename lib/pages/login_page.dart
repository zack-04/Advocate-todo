import 'package:advocate_todo_list/methods/firebase_api.dart';
import 'package:advocate_todo_list/pages/home_page.dart';
import 'package:advocate_todo_list/widgets/custom_button.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController mobController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode mobFocusNode = FocusNode();
  final FocusNode passFocusNode = FocusNode();
  final bool _obscureText = true;
  bool isLoading = false;

  Future<void> loginUser(String mobile, String password) async {
    const String url = ApiConstants.loginEndpoint;

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'enc_key': encKey,
          'mobile': mobile,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['status'] == 'Success') {
          final String loginUserId = responseBody['login_user_id'];
          final String loginUserRole = responseBody['login_user_role'];
          await _saveLoginUserId(loginUserId);
          await _saveLoginUserRole(loginUserRole);

          showCustomToastification(
            context: context,
            type: ToastificationType.success,
            title: 'Logged in successfully!',
            icon: Icons.check,
            primaryColor: Colors.green,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
          await sendFcmToken();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
            (route) => false,
          );
        } else if (responseBody['status'] == 'In-Valid User') {
          showCustomToastification(
            context: context,
            type: ToastificationType.error,
            title: 'Wrong Credentials!',
            icon: Icons.error,
            primaryColor: Colors.red,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
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
        title: 'Please check your connection.',
        icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendFcmToken() async {
    String? empId = await getLoginUserId();
    String? fcmToken = await FirebaseApi().getFcmToken();

    debugPrint('empid: $empId');
    debugPrint('Fcm token: $fcmToken');
    const String url = ApiConstants.sendFcmToken;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'enc_key': encKey,
          'emp_id': empId,
          'fcm_token': fcmToken,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['status'] == 'Success') {
        } else if (responseBody['status'] == 'In-Valid User') {
          showCustomToastification(
            context: context,
            type: ToastificationType.error,
            title: 'Wrong Credentials!',
            icon: Icons.error,
            primaryColor: Colors.red,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
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
        title: 'Please check your connection.',
        icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }
  }

  Future<void> _saveLoginUserId(String loginUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_user_id', loginUserId);
  }

  Future<void> _saveLoginUserRole(String loginUserRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_user_role', loginUserRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/background2.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.42,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mobile No",
                              style: GoogleFonts.inter(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: mobController,
                              focusNode: mobFocusNode,
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.black,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter mobile number';
                                }
                                if (value.length != 10) {
                                  return 'Mobile number must be 10 digits';
                                }
                                final RegExp regex = RegExp(r'^\d{10}$');
                                if (!regex.hasMatch(value)) {
                                  return 'Enter valid mobile number';
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
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
                            const SizedBox(height: 10),
                            Text(
                              "Password",
                              style: GoogleFonts.inter(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: passController,
                              focusNode: passFocusNode,
                              obscureText: _obscureText,
                              cursorColor: Colors.black,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
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
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50, left: 30, right: 30),
              child: CustomButton(
                text: 'Login',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  loginUser(mobController.text, passController.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
