import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

import '../const.dart';
import '../widgets/toast_message.dart';

class BulletinDialog extends StatefulWidget {
  final String bulletinId; // Receive the bulletin ID from the previous page
  final String loginUserId; // Pass the loginUserId as well

  const BulletinDialog({
    required this.bulletinId,
    required this.loginUserId,
    super.key,
  });

  @override
  _BulletinDialogState createState() => _BulletinDialogState();
}

class _BulletinDialogState extends State<BulletinDialog> {
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _triggerBulletinAlert() async {
    setState(() {
      isLoading = true;
    });

    final String url = 'https://todo.sortbe.com/api/bulletin/Bulletin-Alert';
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'enc_key': encKey,
          'emp_id': widget.loginUserId,
          'bulletin_id': widget.bulletinId,
          'alert_on': formattedDate,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'Success') {
          showCustomToastification(
            context: context,
            type: ToastificationType.success,
            title: 'Triggered Successfully',
            // icon: Icons.check_circle_outline_outlined,
            primaryColor: Colors.green,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
          print('Bulletin alert triggered successfully!');
          Navigator.of(context).pop();
        } else if (responseBody['remarks'] == 'Already Alert is set.') {
          // Show toast for "Already Alert is set"
          showCustomToastification(
            context: context,
            type: ToastificationType.warning,
            title: 'Alert is already set',
            // icon: Icons.warning_amber_rounded,
            primaryColor: Colors.orange,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
          print('Alert already set.');
        } else {
          showCustomToastification(
            context: context,
            type: ToastificationType.error,
            title: 'Failed To Trigger',
            // icon: Icons.error,
            primaryColor: Colors.red,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
          print('Failed to trigger bulletin alert: ${responseBody['remarks']}');
        }
      } else {
        print('Error: Failed to send request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error triggering bulletin alert: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.8;
    final double height = MediaQuery.of(context).size.height * 0.35;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Alert On',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
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
                        const Icon(Icons.calendar_month),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF4B4B4B), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Border radius
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          _triggerBulletinAlert(); // Trigger the API call
                        },
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Trigger'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
