import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Container(
        margin: const EdgeInsets.only(right: 5, left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sarath Kumar',
                    style: GoogleFonts.inter(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '1:02 pm',
                    style: GoogleFonts.inter(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'I have reached the madurai district court and the client havent arrived yet. waiting outside the hall',
                style: GoogleFonts.inter(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
