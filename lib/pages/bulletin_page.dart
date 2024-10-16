import 'package:advocate_todo_list/dialogs/text_note_dialog.dart';
import 'package:advocate_todo_list/dialogs/voice_note_dialog.dart';
import 'package:advocate_todo_list/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class BulletinPage extends StatelessWidget {
  const BulletinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bulletin",
                    style: GoogleFonts.inter(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialogAtTopRight(context);
                    },
                    child: SvgPicture.asset(
                      'assets/icons/horn.svg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 6,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return const CustomContainer();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

void showDialogAtTopRight(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Stack(
        children: [
          Positioned(
            top: 40,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 30,
                  bottom: 20,
                  right: 40,
                ),
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showVoiceNoteDialog(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.mic),
                          Text(
                            'Voice Note',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showTextNoteDialog(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.add,
                            size: 25,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Text(
                              'Text Note',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
