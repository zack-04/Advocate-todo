import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:advocate_todo_list/dialogs/search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:toastification/toastification.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:advocate_todo_list/widgets/visual_component.dart';
import 'package:google_fonts/google_fonts.dart';

import '../const.dart';

class VoiceNoteDialog extends StatefulWidget {
  final Function refreshCallback;
  const VoiceNoteDialog({super.key, required this.refreshCallback});

  @override
  _VoiceNoteDialogState createState() => _VoiceNoteDialogState();
}

class _VoiceNoteDialogState extends State<VoiceNoteDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> selectedUsers = [];
  bool isRecording = false;
  final AudioRecorder audioRecorder = AudioRecorder();
  String? recordingPath;
  Timer? _timer;
  int recordingDuration = 0;
  String? loginUserId;
  List<Color> colors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.yellowAccent,
  ];

  List<int> duration = [900, 800, 700, 600, 500];

  @override
  void initState() {
    super.initState();
    debugPrint('VoiceNoteDialog initialized.');
    _getLoginUserId();
  }

  Future<void> _getLoginUserId() async {
    debugPrint('Fetching login user ID from shared preferences...');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginUserId = prefs.getString('login_user_id');
    });
    debugPrint('Login user ID: $loginUserId');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    debugPrint('Disposing resources...');
    super.dispose();
  }

  Future<void> _createVoiceBulletin() async {
    if (loginUserId == null || recordingPath == null) {
      debugPrint('Error: User not logged in or no recording found.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in or no recording found!')),
      );
      return;
    }

    final List<String> tagUsers =
    selectedUsers.map((user) => user['user_id']!).toList();
    debugPrint('Tagged users: $tagUsers');

    final Uri uri = Uri.parse(ApiConstants.bulletinCreate);
    var request = http.MultipartRequest('POST', uri);

    request.fields['enc_key'] = encKey;
    request.fields['emp_id'] = loginUserId!;
    request.fields['type'] = 'Voice';
    request.fields['tag_users'] = jsonEncode(tagUsers);

    if (recordingPath != null) {
      debugPrint('Attaching recorded file: $recordingPath');
      var file = await http.MultipartFile.fromPath('voice_note', recordingPath!);
      request.files.add(file);
    }

    debugPrint('Sending request to create voice bulletin...');
    var response = await request.send();

    if (response.statusCode == 200) {
      debugPrint('Voice note created successfully.');
      showCustomToastification(
        context: context,
        type: ToastificationType.success,
        title: 'Voice note created successfully!',
        icon: Icons.check,
        primaryColor: Colors.green,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
      widget.refreshCallback(); // Call the refresh callback after success

      // Pop the dialog to close it immediately after saving
      Navigator.pop(context);
    } else {
      debugPrint('Failed to create voice note. Status code: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create voice note!')),
      );
    }
  }


  void _startRecordingTimer() {
    debugPrint('Starting recording timer...');
    recordingDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordingDuration++;
      });
      debugPrint('Recording duration: ${_formatDuration(recordingDuration)}');
    });
  }

  void _stopRecordingTimer() {
    debugPrint('Stopping recording timer.');
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recording',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint('Closing dialog.');
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (isRecording) {
                        debugPrint('Stopping recording...');
                        String? path = await audioRecorder.stop();
                        if (path != null) {
                          debugPrint('Recording stopped, file saved at: $path');
                          _stopRecordingTimer();
                          setState(() {
                            isRecording = false;
                            recordingPath = path;
                          });
                          showCustomToastification(
                            context: context,
                            type: ToastificationType.success,
                            title: 'Recording saved successfully!',
                            icon: Icons.check,
                            primaryColor: Colors.green,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          );
                        }
                      } else {
                        if (await audioRecorder.hasPermission()) {
                          debugPrint('Starting new recording...');
                          final Directory? appDocumentDir = await getExternalStorageDirectory();
                          final String filePath = path.join(
                            appDocumentDir!.path,
                            'recording_${DateTime.now().millisecond}.wav',
                          );
                          debugPrint('Recording path: $filePath');
                          await audioRecorder.start(
                            const RecordConfig(),
                            path: filePath,
                          );
                          _startRecordingTimer();
                          setState(() {
                            isRecording = true;
                            recordingPath = null;
                          });
                        }
                      }
                    },
                    icon: Icon(
                      isRecording ? Icons.stop : Icons.play_arrow,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  isRecording
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      20,
                          (index) {
                        return VisualComponent(
                          duration: duration[index % 5],
                          color: colors[index % 4],
                        );
                      },
                    ),
                  )
                      : const Text(
                    'Not recording',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatDuration(recordingDuration),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 25),
              child: Text(
                'Tag Users',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10),
            UserSearch(
              selectedUsers: selectedUsers,
              onUserSelected: (user) {
                debugPrint('User selected: ${user['user_id']}');
                setState(() {
                  selectedUsers.add(user);
                });
              },
              onUserRemoved: (user) {
                debugPrint('User removed: ${user['user_id']}');
                setState(() {
                  selectedUsers.removeWhere(
                          (selected) => selected['user_id'] == user['user_id']);
                });
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: MaterialButton(
                  height: 42,
                  minWidth: 130,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: const Color(0xFF4B4B4B),
                  onPressed: () {
                    debugPrint('Send button pressed. Sending voice note...');
                    _createVoiceBulletin(); // Send the voice note
                    // No need to pop the dialog here; it will be handled inside _createVoiceBulletin on success
                  },
                  child: Text(
                    'Send',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showVoiceNoteDialog(BuildContext context, Function refreshCallback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return VoiceNoteDialog(refreshCallback: refreshCallback);
    },
  );
}
