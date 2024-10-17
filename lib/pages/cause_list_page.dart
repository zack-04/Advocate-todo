import 'package:advocate_todo_list/widgets/image_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../const.dart';
class CaseListPage extends StatefulWidget {
  const CaseListPage({super.key});

  @override
  State<CaseListPage> createState() => _CaseListPageState();
}

class _CaseListPageState extends State<CaseListPage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> causeList = [];
  bool isLoading = false;
  String? loginUserId;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      _fetchCauseList(); // Fetch the data when a new date is selected
    }
  }

  Future<void> _getLoginUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginUserId = prefs.getString('login_user_id');
    });
  }

  Future<void> _fetchCauseList() async {
    if (loginUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    const String url = ApiConstants.causeList;
    final stopwatch = Stopwatch()..start(); // Start measuring time

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'enc_key': encKey,
          'emp_id': loginUserId!,
          'cause_date': DateFormat('yyyy-MM-dd').format(selectedDate),
        },
      );

      stopwatch.stop();
      print('API call took ${stopwatch.elapsedMilliseconds} ms'); // Log time

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          causeList = List<Map<String, dynamic>>.from(data['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load cause list')),
        );
      }
    } catch (e) {
      stopwatch.stop();
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _getLoginUserIdAndFetchData(); // Fetch login_user_id and cause list initially
  }

  Future<void> _getLoginUserIdAndFetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    loginUserId = prefs.getString('login_user_id');

    if (loginUserId != null) {
      _fetchCauseList(); // Only fetch data after user ID is available
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cause List",
                style: GoogleFonts.inter(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                height: 50,
                width: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          DateFormat('dd-MMM-yyyy').format(selectedDate),
                          style: GoogleFonts.inter(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: const Icon(Icons.arrow_drop_down_sharp),
                        onTap: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      for (var cause in causeList)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ImageContainer(
                            path: cause['cause_file'], // dynamic path
                            fileName: cause['title'],
                            downloadUrl: cause['cause_file'],
                          ),
                        ),
                      const SizedBox(height: 130),
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
