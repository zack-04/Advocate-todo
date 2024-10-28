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

import '../utils/const.dart';
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
      showCustomToastification(
        context: context,
        type: ToastificationType.error,
        title: 'User not Logged in',
        // icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
        showCustomToastification(
          context: context,
          type: ToastificationType.success,
          title: 'Failed To Load Cause List',
          // icon: Icons.check,
          primaryColor: Colors.green,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        );
      }
    } catch (e) {
      stopwatch.stop();
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      showCustomToastification(
        context: context,
        type: ToastificationType.success,
        title: 'Error Fetching Cause List',
        // icon: Icons.check,
        primaryColor: Colors.green,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
            left: 20,
            right: 30,
            top: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
        child: Stack(
          children: [
            Image.asset(
              'assets/images/abstractBg.jpeg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 30,
                top: 15,
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
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 35,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.black,
                        padding: const EdgeInsets.all(12),
                        height: 50,
                        width: 190,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  DateFormat('dd-MMM-yyyy')
                                      .format(selectedDate),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_sharp,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: RefreshIndicator(
                        backgroundColor: const Color(0xFFFFFFFF),
                        color: Colors.black,
                        onRefresh: _fetchCauseList,
                        child: causeList.isEmpty
                            ? Center(
                                child: Image.asset(
                                  'assets/images/no_cause.png',
                                  fit: BoxFit.cover,
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    for (var cause in causeList)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: ImageContainer(
                                          path: Uri.encodeFull(
                                              cause['cause_file']),
                                          fileName: cause['title'],
                                          downloadUrl: Uri.encodeFull(
                                              cause['cause_file']),
                                          fileType: cause['file_type'],
                                        ),
                                      ),
                                    const SizedBox(height: 130),
                                  ],
                                ),
                              ),
                      ),
                    ),
            ],
          ),
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
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: RefreshIndicator(
                            backgroundColor: const Color(0xFFFFFFFF),
                            color: Colors.black,
                            onRefresh: _fetchCauseList,
                            child: causeList.isEmpty
                                ? Center(
                                    child: Image.asset(
                                      'assets/images/no_cause.png',
                                      fit: BoxFit.cover,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                    ),
                                  )
                                : SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        for (var cause in causeList)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: ImageContainer(
                                              path: Uri.encodeFull(
                                                  cause['cause_file']),
                                              fileName: cause['title'],
                                              downloadUrl: Uri.encodeFull(
                                                  cause['cause_file']),
                                              fileType: cause['file_type'],
                                            ),
                                          ),
                                        const SizedBox(height: 130),
                                      ],
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

class ImageContainer extends StatefulWidget {
  final String path;
  final String fileName;
  final String downloadUrl;
  final String fileType;

  const ImageContainer({
    required this.path,
    required this.fileName,
    required this.downloadUrl,
    required this.fileType,
    super.key,
  });

  @override
  _ImageContainerState createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  bool isLoading = false;

  Future<void> downloadImage(String url, String fileName, BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Define the download paths based on the fileType.
        String downloadPath;
        if (widget.fileType == "PDF") {
          downloadPath = '/storage/emulated/0/AdvocateTodo/PDF/';
        } else if (widget.fileType == "Word" || widget.fileType == "docx") {
          downloadPath = '/storage/emulated/0/AdvocateTodo/Documents/';
        } else {
          downloadPath = '/storage/emulated/0/AdvocateTodo/Images/';
        }

        final folder = Directory(downloadPath);
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
          file = File('$downloadPath$uniqueFileName');
          counter++;
        } while (await file.exists());

        await file.writeAsBytes(response.bodyBytes);

        // Show success toast and notification.
        showCustomToastification(
          context: context,
          type: ToastificationType.success,
          title: 'Successfully Downloaded',
          // icon: Icons.check,
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

  void _showDownloadNotification(String title, String filePath) async {
    // Set notification title based on fileType.
    String notificationTitle;
    if (widget.fileType == "PDF") {
      notificationTitle = 'PDF Downloaded';
    } else if (widget.fileType == "Word" || widget.fileType == "docx") {
      notificationTitle = 'Document Downloaded';
    } else {
      notificationTitle = 'Image Downloaded';
    }

    // Set style information
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(filePath),
      contentTitle: notificationTitle,
      summaryText: title,
      largeIcon: FilePathAndroidBitmap(filePath),
    );

    // Define Android notification details.
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'download_channel',
      'File Downloads',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.low,
      priority: Priority.low,
      styleInformation: bigPictureStyleInformation,
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    int notificationId =
    DateTime.now().millisecondsSinceEpoch.remainder(100000);
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      title,
      notificationDetails,
      payload: filePath,
    );
  }

  Future<void> requestPermission(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    PermissionStatus status;

    try {
      if (Platform.isAndroid && await _isAtLeastAndroid11()) {
        status = await Permission.manageExternalStorage.status;
      } else {
        status = await Permission.storage.status;
      }

      if (status.isGranted) {
        await downloadImage(widget.downloadUrl, widget.fileName, context);
      } else {
        if (Platform.isAndroid && await _isAtLeastAndroid11()) {
          status = await Permission.manageExternalStorage.request();
        } else {
          status = await Permission.storage.request();
        }

        if (status.isGranted) {
          await downloadImage(widget.downloadUrl, widget.fileName, context);
        } else {
          showCustomToastification(
            context: context,
            type: ToastificationType.error,
            title: 'Storage permission is required to download the image.',
            // icon: Icons.error,
            primaryColor: Colors.red,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          );
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
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
    String previewImage;
    if (widget.fileType == "Image") {
      previewImage = widget.path; // Use the server path for images.
    } else {
      if (widget.fileType == "PDF") {
      if (fileType == "PDF") {
        previewImage = 'assets/images/pdf_image.png';
      } else if (widget.fileType == "Word" || widget.fileType == "docx") {
        previewImage = 'assets/images/word_image.jpg';
      } else {
        previewImage = 'assets/images/word_image.png';
      }
    }

    return GestureDetector(
      onTap: () {
        requestPermission(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFcfcfd2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(color: Color(0xFFcfcfd2), width: 1),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: widget.fileType == "Image"
                  ? Image.network(
                previewImage,
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity,
              )
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  previewImage,
                  fit: BoxFit.contain,
                  height: 150,
                  width: double.infinity,
                ),
              ),
                      previewImage, // For server-based images
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    )
                  : Image.asset(
                      previewImage,
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
              border: Border.all(color: Color(0xFFcfcfd2), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Optional: to prevent overflow.
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Center(
                    child: isLoading
                        ? CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black87,
                    )
                        : IconButton(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        requestPermission(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
