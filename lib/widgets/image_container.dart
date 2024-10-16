import 'dart:io';

import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

class ImageContainer extends StatelessWidget {
  const ImageContainer({
    super.key,
    required this.path,
    required this.fileName,
    required this.downloadUrl,
  });
  final String path;
  final String fileName;
  final String downloadUrl;

  @override
  Widget build(BuildContext context) {
    String getFileExtension(String url) {
      if (url.contains('.pdf')) {
        return '.pdf';
      } else if (url.contains('.docx') || url.contains('.doc')) {
        return '.docx';
      } else if (url.contains('.jpg') || url.contains('.jpeg')) {
        return '.jpg';
      } else if (url.contains('.png')) {
        return '.png';
      } else {
        return '.txt';
      }
    }

    Future<void> downloadFile(BuildContext context) async {
      try {
        final response = await http.get(Uri.parse(downloadUrl));
        if (response.statusCode == 200) {
          Directory? directory = await getExternalStorageDirectory();
          String extension = getFileExtension(downloadUrl);
          String filePath = '${directory!.path}/$fileName$extension';
          debugPrint('Extension = $extension');
          debugPrint('File path = $filePath');

          // Save the file
          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          showCustomToastification(
            context: context,
            type: ToastificationType.success,
            title: 'Downloaded successfully!',
            icon: Icons.check,
            primaryColor: Colors.green,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
        } else {
          throw Exception('Failed to download file');
        }
      } catch (e) {
        print('Error: $e');
        showCustomToastification(
          context: context,
          type: ToastificationType.error,
          title: 'Downloading failed!',
          icon: Icons.error,
          primaryColor: Colors.red,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        );
      }
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.asset(
                path,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: Border.all(
                color: const Color(0xFFD9D9D9),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fileName,
                  style: GoogleFonts.inter(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    downloadFile(context);
                  },
                  child: const Icon(Icons.download),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
