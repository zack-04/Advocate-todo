import 'package:advocate_todo_list/widgets/image_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CaseListPage extends StatefulWidget {
  const CaseListPage({super.key});

  @override
  State<CaseListPage> createState() => _CaseListPageState();
}

class _CaseListPageState extends State<CaseListPage> {
  DateTime selectedDate = DateTime.now();

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
              const Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ImageContainer(
                        path: 'assets/images/image1.png',
                        fileName: "Word file",
                        downloadUrl:
                            'https://file-examples.com/wp-content/storage/2017/02/file-sample_100kB.doc',
                      ),
                      SizedBox(height: 20),
                      ImageContainer(
                        path: 'assets/images/image2.png',
                        fileName: "Pdf file",
                        downloadUrl:
                            'https://onlinetestcase.com/wp-content/uploads/2023/06/1-MB.pdf',
                      ),
                      SizedBox(height: 20),
                      ImageContainer(
                        path: 'assets/images/image2.png',
                        fileName: "Image file",
                        downloadUrl:
                            'https://cdn.prod.website-files.com/6410ebf8e483b5bb2c86eb27/6410ebf8e483b5758186fbd8_ABM%20college%20mobile%20app%20dev%20main.jpg',
                      ),
                      SizedBox(height: 130),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
