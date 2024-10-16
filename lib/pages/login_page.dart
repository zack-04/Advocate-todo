import 'package:advocate_todo_list/pages/home_page.dart';
import 'package:advocate_todo_list/widgets/custom_button.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/services.dart';

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

  // void _togglePasswordVisibility() {
  //   setState(() {
  //     _obscureText = !_obscureText;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/background1.png',
                fit: BoxFit.fill,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.42,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          // suffixIcon: IconButton(
                          //   icon: Icon(
                          //     _obscureText
                          //         ? Icons.visibility_off
                          //         : Icons.visibility,
                          //   ),
                          //   onPressed: _togglePasswordVisibility,
                          // ),
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: CustomButton(
                          text: 'Login',
                          onPressed: () {
                            // if (!formKey.currentState!.validate()) {
                            //   return;
                            // }
                            showCustomToastification(
                              context: context,
                              type: ToastificationType.success,
                              title: 'Logged in successfully!',
                              icon: Icons.check,
                              primaryColor: Colors.green,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
