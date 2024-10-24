import 'dart:io';

import 'package:advocate_todo_list/widgets/image_container.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import '../const.dart';
import '../main.dart';
import '../widgets/toast_message.dart';

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
      lastDate: DateTime(2050),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      _fetchCauseList();
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
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    const String url = ApiConstants.causeList;
    final stopwatch = Stopwatch()..start();

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
      print('API call took ${stopwatch.elapsedMilliseconds} ms');

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
          const SnackBar(content: Text('Failed to load cause list')),
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
    _getLoginUserIdAndFetchData();
  }

  Future<void> _getLoginUserIdAndFetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    loginUserId = prefs.getString('login_user_id');

    if (loginUserId != null) {
      _fetchCauseList();
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
              GestureDetector(
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
                        const Icon(Icons.arrow_drop_down_sharp),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: causeList.isEmpty
                          ? const Center(
                              child: Text(
                                "No Cause List",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 24),
                              ),
                            )
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  for (var cause in causeList)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: ImageContainer(
                                        path:
                                            Uri.encodeFull(cause['cause_file']),
                                        fileName: cause['title'],
                                        downloadUrl:
                                            Uri.encodeFull(cause['cause_file']),
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

class ImageContainer extends StatelessWidget {
  final String path;
  final String fileName;
  final String downloadUrl;

  const ImageContainer({
    required this.path,
    required this.fileName,
    required this.downloadUrl,
    super.key,
  });

  Future<void> downloadImage(
      String url, String fileName, BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        const String imagePath = '/storage/emulated/0/AdvocateTodo/Images/';
        final folder = Directory(imagePath);
        if (!await folder.exists()) {
          await folder.create(recursive: true);
        }

        String fileExtension = url.split('.').last;
        String baseName = fileName;
        int counter = 1;
        File file;
        do {
          String uniqueFileName = counter == 1
              ? '$baseName.$fileExtension'
              : '${baseName}_$counter.$fileExtension';
          file = File('$imagePath$uniqueFileName');
          counter++;
        } while (await file.exists());

        await file.writeAsBytes(response.bodyBytes);

        // Show success toast and notification.
        showCustomToastification(
          context: context,
          type: ToastificationType.success,
          title: 'Successfully Downloaded',
          icon: Icons.check,
          primaryColor: Colors.green,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onTap: () async {
            await OpenFilex.open(file.path);
          },
        );

        _showDownloadNotification(baseName, file.path);
      } else {
        print("Failed to download image. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
  }

  void _showDownloadNotification(String title, String imagePath) async {
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(imagePath), // Use image as notification content.
      contentTitle: 'Image Downloaded',
      summaryText: title,
      largeIcon: FilePathAndroidBitmap(imagePath),
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'download_channel', // Channel ID.
      'Image Downloads', // Channel name.
      channelDescription: 'Notifications for image downloads',
      importance: Importance.low, // Ensure the notification is visible.
      priority: Priority.low,
      styleInformation: bigPictureStyleInformation, // Use BigPicture style.
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Generate a unique notification ID based on current timestamp.
    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      'Image Downloaded',
      title,
      notificationDetails,
      payload: imagePath,
    );
  }

  Future<void> requestPermission(BuildContext context) async {
    PermissionStatus status;

    if (Platform.isAndroid && await _isAtLeastAndroid11()) {
      status = await Permission.manageExternalStorage.status;
    } else {
      status = await Permission.storage.status;
    }

    if (status.isGranted) {
      downloadImage(downloadUrl, fileName, context);
    } else {
      if (Platform.isAndroid && await _isAtLeastAndroid11()) {
        status = await Permission.manageExternalStorage.request();
      } else {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        downloadImage(downloadUrl, fileName, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Storage permission is required to download the image.'),
          ),
        );
      }
    }
  }

  Future<bool> _isAtLeastAndroid11() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 30;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        requestPermission(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                path,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.download,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    requestPermission(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;

  const ImagePreviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Downloaded Image")),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
