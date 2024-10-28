import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:advocate_todo_list/dialogs/search_dialog.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:toastification/toastification.dart';
import 'package:advocate_todo_list/widgets/toast_message.dart';
import 'package:advocate_todo_list/widgets/visual_component.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/const.dart';

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
  bool isPlaying = false;
  bool recordingExists = false;
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  String? recordingPath;
  Timer? _timer;
  int recordingDuration = 0;
  String? loginUserId;
  late RecorderController recorderController;
  late PlayerController playerController;

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
    _initializeRecorder();
    _initializePlayer();
    _initializeWaveformController(); // Initialize waveform controller
  }

  Future<void> _initializeRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
    debugPrint('Audio recorder initialized.');
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();
    debugPrint('Audio player initialized.');
  }

  Future<void> _getLoginUserId() async {
    debugPrint('Fetching login user ID from shared preferences...');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginUserId = prefs.getString('login_user_id');
    });
    debugPrint('Login user ID: $loginUserId');
  }

  void _initializeWaveformController() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
    playerController = PlayerController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    if (isPlaying) {
      playerController.stopPlayer(); // Stop any playing audio
    }
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    recorderController.dispose();
    playerController.dispose();
    debugPrint('Disposing resources...');
    super.dispose();
  }

  Future<void> _createVoiceBulletin() async {
    if (loginUserId == null || recordingPath == null) {
      debugPrint('Error: User not logged in or no recording found.');
      showCustomToastification(
        context: context,
        type: ToastificationType.error,
        title: 'Please Record Audio',
        icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onTap: () {
          // Optional: Navigate to a specific page or handle onTap event
        },
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
      var file =
      await http.MultipartFile.fromPath('voice_note', recordingPath!);
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
      widget.refreshCallback();

      Navigator.pop(context);
    } else {
      debugPrint(
          'Failed to create voice note. Status code: ${response.statusCode}');
      showCustomToastification(
        context: context,
        type: ToastificationType.error,
        title: 'Failed To Create',
        icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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

  void _startPlaybackTimer() {
    debugPrint('Starting playback timer...');
    recordingDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        recordingDuration++;
      });
      debugPrint('Playback duration: ${_formatDuration(recordingDuration)}');
    });
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _playRecording() async {
    if (recordingPath == null) return;

    try {
      await playerController.preparePlayer(path: recordingPath!);
      setState(() {
        isPlaying = true; // Set the state to playing
      });
      _startPlaybackTimer();
      await playerController.startPlayer();

      playerController.onCompletion.listen((_) {
        setState(() {
          isPlaying = false; // Stop playing when complete
        });
        // Reset the player for replaying
        playerController.stopPlayer(); // Ensure player is stopped
      });
    } catch (e) {
      debugPrint('Failed to play recording: $e');
      setState(() {
        isPlaying = false; // Ensure state is reset in case of an error
      });
      _stopRecordingTimer();
    }
  }

  void _deleteRecording() {
    setState(() {
      recordingExists = false;
      recordingPath = null;
    });
    debugPrint('Recording deleted.');
  }

  Future<void> _startRecording() async {
    if (_audioRecorder == null) return;

    final Directory? appDocumentDir = await getExternalStorageDirectory();
    final String filePath = path.join(
      appDocumentDir!.path,
      'recording_${DateTime.now().millisecondsSinceEpoch}.wav',
    );

    try {
      await _audioRecorder!.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
      );
      await recorderController.record();
      _startRecordingTimer();
      setState(() {
        isRecording = true;
        recordingPath = null;
      });
    } catch (e) {
      debugPrint('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_audioRecorder == null) return;

    try {
      String? filePath = await _audioRecorder!.stopRecorder();
      debugPrint('Recording stopped, file saved at: $filePath');
      _stopRecordingTimer();
      await recorderController.stop();
      setState(() {
        isRecording = false;
        recordingExists = true;
        recordingPath = filePath;
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
    } catch (e) {
      debugPrint('Failed to stop recording: $e');
      showCustomToastification(
        context: context,
        type: ToastificationType.error,
        title: 'Failed To Stop Recording',
        icon: Icons.error,
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }
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
        child: SingleChildScrollView(
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
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (isRecording) {
                          await _stopRecording();
                        } else if (isPlaying) {
                          await playerController
                              .stopPlayer(); // Stop the player if it is playing
                          setState(() {
                            isPlaying =
                                false; // Update the state to reflect that playback has stopped
                          });
                        } else if (recordingExists) {
                          await _playRecording(); // Start playback if a recording exists
                        } else {
                          await _startRecording(); // Start recording if nothing else is happening
                        }
                      },
                      icon: Icon(
                        isRecording
                            ? Icons.stop
                            : recordingExists
                                ? (isPlaying
                                    ? Icons.pause
                                    : Icons
                                        .play_arrow) // Change icon based on state
                                : Icons.mic,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Audio waveforms display
                    Expanded(
                      child: isRecording
                          ? AudioWaveforms(
                              enableGesture: true,
                              size: Size(
                                  MediaQuery.of(context).size.width / 2, 50),
                              recorderController: recorderController,
                              waveStyle: const WaveStyle(
                                waveColor: Color(0xFF545454),
                                extendWaveform: true,
                                showMiddleLine: false,
                              ),
                              padding: const EdgeInsets.only(left: 18),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                            )
                          : isPlaying
                              ? AudioFileWaveforms(
                                  size: Size(
                                      MediaQuery.of(context).size.width * 0.6,
                                      40),
                                  playerController: playerController,
                                  waveformType: WaveformType.fitWidth,
                                  playerWaveStyle: const PlayerWaveStyle(
                                    fixedWaveColor: Color(0xFF545454),
                                    liveWaveColor: Color(0xFF545454),
                                  ),
                                )
                              : Text(
                                  recordingExists
                                      ? 'Press play to preview'
                                      : 'Not recording',
                                  style: const TextStyle(fontSize: 16),
                                ),
                    ),

                    const SizedBox(width: 10),

                    // Delete button
                    if (recordingExists)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            recordingExists = false;
                            recordingPath = null;
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text(
                  'Tag Users',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              UserSearch(
                selectedUsers: selectedUsers,
                onUserSelected: (user) {
                  setState(() {
                    selectedUsers.add(user);
                  });
                },
                onUserRemoved: (user) {
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
                    onPressed: () async {
                      if (isRecording) {
                        await _stopRecording();
                      }
                      _createVoiceBulletin();
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

void showVoiceNoteDialog(
  BuildContext context,
  Function refreshCallback,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return VoiceNoteDialog(refreshCallback: refreshCallback);
    },
  );
}
