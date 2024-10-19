import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomContainer extends StatelessWidget {
  final String creatorName;
  final String updatedTime;
  final String bulletinContent;
  final String bulletinType;
  final List<String>? taggedUsers; // New parameter to accept tagged users

  final Widget? extraWidget;

  const CustomContainer({
    super.key,
    required this.creatorName,
    required this.updatedTime,
    required this.bulletinContent,
    required this.bulletinType,
    this.taggedUsers,  // Optional taggedUsers
    this.extraWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Convert the list of tagged users into a comma-separated string
    final taggedUsersText = taggedUsers != null && taggedUsers!.isNotEmpty
        ? taggedUsers!.join(', ')
        : 'No tagged users';

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

              // Bulletin Content
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

              const SizedBox(height: 10),

              // Tagged Users
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tagged Users: $taggedUsersText',  // Display tagged users text
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600], // Slightly lighter color for tagged users
                  ),
                ),
              ),

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
