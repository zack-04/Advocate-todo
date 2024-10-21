import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomContainer extends StatelessWidget {
  final String creatorName;
  final String updatedTime;
  final String bulletinContent;
  final String bulletinType;
  final List<String>? taggedUsers;

  final Widget? extraWidget;

  const CustomContainer({
    super.key,
    required this.creatorName,
    required this.updatedTime,
    required this.bulletinContent,
    required this.bulletinType,
    this.taggedUsers,
    this.extraWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    creatorName,
                    style: GoogleFonts.inter(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    updatedTime,
                    style: GoogleFonts.inter(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Render the bulletinContent only if it is not empty or null
              if (bulletinContent.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    bulletinContent,
                    style: GoogleFonts.inter(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              if (taggedUsers != null && taggedUsers!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  children: taggedUsers!.map((user) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFD9D9D9),
                      ),
                      child: Text(
                        user,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              if (extraWidget != null) ...[
                const SizedBox(height: 10),
                extraWidget!,
              ],
            ],
          ),

        ),
      ),
    );
  }
}
