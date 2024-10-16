import 'dart:async';
import 'dart:io';

import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:advocate_todo_list/widgets/visual_component.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:toastification/toastification.dart';

class VoiceNoteDialog extends StatefulWidget {
  const VoiceNoteDialog({super.key});

  @override
  _VoiceNoteDialogState createState() => _VoiceNoteDialogState();
}

class _VoiceNoteDialogState extends State<VoiceNoteDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> allUsers = [
    'Sarath Kumar',
    'Abinaya',
    'John',
    'Suresh',
    'Mahesh',
    'Krishna',
    'Swetha',
    'Sam',
    'Ram',
    'Shyam',
    'Saransh',
    'Sikandar',
  ];
  List<String> filteredUsers = [];
  List<String> selectedUsers = [];
  bool isRecording = false;
  final AudioRecorder audioRecorder = AudioRecorder();
  String? recordingPath;
  List<Color> colors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.yellowAccent,
  ];
  List<int> duration = [900, 800, 700, 600, 500];
  Timer? _timer;
  int recordingDuration = 0;
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _filterUsers() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isEmpty) {
        filteredUsers.clear();
      } else {
        filteredUsers = allUsers
            .where((user) => user.toLowerCase().contains(searchTerm))
            .toList();
      }
    });
  }

  void _addUser(String user) {
    setState(() {
      if (!selectedUsers.contains(user)) {
        selectedUsers.add(user);
      }
      _searchController.clear();
      filteredUsers.clear();
    });
    _focusNode.requestFocus();
  }

  void _removeUser(String user) {
    setState(() {
      selectedUsers.remove(user);
    });
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startRecordingTimer() {
    recordingDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordingDuration++;
      });
    });
  }

  void _stopRecordingTimer() {
    _timer?.cancel();
    // setState(() {
    //   recordingDuration = 0;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
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
                          String? path = await audioRecorder.stop();
                          if (path != null) {
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
                            debugPrint('Recording path = $recordingPath');
                          }
                        } else {
                          if (await audioRecorder.hasPermission()) {
                            final Directory? appDocumentDir =
                                await getExternalStorageDirectory();
                            final String filePath = path.join(
                              appDocumentDir!.path,
                              'recording_${DateTime.now().millisecond}.wav',
                            );
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

              // Search Field with Chips
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.start,
                    children: [
                      // Display selected users as chips
                      for (String user in selectedUsers)
                        Chip(
                          backgroundColor: Colors.grey.shade300,
                          label: Text(user),
                          onDeleted: () => _removeUser(user),
                        ),
                      // TextField to input user name
                      TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: selectedUsers.isEmpty ? 'Search Users' : '',
                        ),
                        onEditingComplete: () {
                          if (filteredUsers.isNotEmpty) {
                            _addUser(filteredUsers.first);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Suggested Users List
              if (filteredUsers.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return GestureDetector(
                          onTap: () => _addUser(user),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10),
                            child: Text(
                              user,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 10,
                  // top: 20,
                ),
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
                      Navigator.pop(context);
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
      ),
    );
  }
}

void showVoiceNoteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const VoiceNoteDialog();
    },
  );
}
