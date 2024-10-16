import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog({super.key});

  @override
  _TransferDialogState createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
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
        // width: MediaQuery.of(context).size.width,
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
                'Transfer To',
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Radio button list
            ListView.builder(
              shrinkWrap: true,
              itemCount: persons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPerson = persons[index];
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
                          selectedPerson == persons[index]
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selectedPerson == persons[index]
                              ? Colors.black
                              : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          persons[index],
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Remarks input
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Transfer Now',
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

void showTransferDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const TransferDialog();
    },
  );
}
