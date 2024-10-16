import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcceptOrDenyDialog extends StatefulWidget {
  const AcceptOrDenyDialog({super.key});

  @override
  State<AcceptOrDenyDialog> createState() => _AcceptOrDenyDialogState();
}

class _AcceptOrDenyDialogState extends State<AcceptOrDenyDialog> {
  String? selectedPerson;
  final List<String> persons = [
    'Sarath Kumar',
    'Suresh',
    'Mahesh',
    'Sudharshan',
    'Maheshwari'
  ];

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
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words,',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
            _rowWidget('Created By:', 'Sarath Kumar'),
            _rowWidget('Created On:', '02 Oct 2024'),
            _rowWidget('Complete By:', '10 Oct 2024 (+2 days)'),
            _rowWidget('Priority:', 'High'),
            _rowWidget('Handled By:', 'Sarath Kumar'),
            const SizedBox(height: 30),
            Padding(
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Accept',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Deny',
                        style: GoogleFonts.inter(
                          fontSize: 14,
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

void showAcceptOrDenyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const AcceptOrDenyDialog();
    },
  );
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
        Text(
          text2,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
