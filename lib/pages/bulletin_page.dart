import 'dart:convert';
import 'dart:io';
import 'package:advocate_todo_list/const.dart';
import 'package:advocate_todo_list/dialogs/text_note_dialog.dart';
import 'package:advocate_todo_list/dialogs/voice_note_dialog.dart';
import 'package:advocate_todo_list/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  _BulletinPageState createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  List bulletinData = [];
  bool isLoading = true;
  String? loginUserId;
  FlutterSoundPlayer? _audioPlayer;
  String? playingVoiceNote;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getLoginUserIdAndFetchData();
    _audioPlayer = FlutterSoundPlayer();
    _audioPlayer!.openPlayer();
  }

  Future<void> _getLoginUserIdAndFetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginUserId = prefs.getString('login_user_id');
    });

    if (loginUserId != null) {
      await fetchBulletinData(loginUserId!);
      await _downloadAllVoiceNotes(); // Download all voice notes after data fetch
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchBulletinData(String empId) async {
    const String url = ApiConstants.bulletinList;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'enc_key': encKey, 'emp_id': empId},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'Success') {
          setState(() {
            bulletinData = responseBody['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Download all voice notes immediately after fetching bulletin data
  Future<void> _downloadAllVoiceNotes() async {
    for (var item in bulletinData) {
      if (item['type'] == 'Voice' && item['voice_note_file'] != null) {
        String voiceNoteUrl = item['voice_note_file'];
        String fileName = basename(voiceNoteUrl);
        final filePath = await _getLocalFilePath(fileName);

        if (!File(filePath).existsSync()) {
          print('Downloading new voice note: $fileName');
          await _downloadAndSaveAudio(voiceNoteUrl, fileName);
        } else {
          print('File already exists: $fileName');
        }
      }
    }
  }

  Future<void> _togglePlayPause(String voiceNoteUrl, String fileName) async {
    final filePath = await _getLocalFilePath(fileName);

    if (playingVoiceNote == voiceNoteUrl) {
      await _audioPlayer!.stopPlayer();
      setState(() {
        playingVoiceNote = null;
      });
    } else {
      if (File(filePath).existsSync()) {
        await _playAudio(filePath);
      } else {
        await _downloadAndSaveAudio(voiceNoteUrl, fileName);
        await _playAudio(filePath);
      }

      setState(() {
        playingVoiceNote = voiceNoteUrl;
      });
    }
  }

  Future<void> _playAudio(String filePath) async {
    try {
      await _audioPlayer!.startPlayer(
        fromURI: filePath,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          setState(() {
            playingVoiceNote = null;
          });
        },
      );
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<String> _getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, fileName);

    print('File will be saved at: $path');
    return path;
  }

  Future<void> _downloadAndSaveAudio(
      String voiceNoteUrl, String fileName) async {
    try {
      final response = await http.get(Uri.parse(voiceNoteUrl));

      if (response.statusCode == 200) {
        final filePath = await _getLocalFilePath(fileName);
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('Downloaded file size: ${file.lengthSync()} bytes');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'download_time_$fileName', DateTime.now().toIso8601String());

        _scheduleFileDeletion(fileName);
      } else {
        print('Failed to download file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading voice note: $e');
    }
  }

  void _scheduleFileDeletion(String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? downloadTime = prefs.getString('download_time_$fileName');

    if (downloadTime != null) {
      DateTime downloadDateTime = DateTime.parse(downloadTime);
      if (DateTime.now().difference(downloadDateTime).inHours >= 24) {
        final filePath = await _getLocalFilePath(fileName);
        final file = File(filePath);

        if (await file.exists()) {
          await file.delete();
        }

        prefs.remove('download_time_$fileName');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer?.closePlayer();
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshBulletinData() {
    if (loginUserId != null) {
      setState(() {
        isLoading = true;
      });

      fetchBulletinData(loginUserId!).then((_) async {
        // Download any new voice notes after fetching updated data
        await _downloadAllVoiceNotes();
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<void> _handleRefresh() async {
    await fetchBulletinData(loginUserId!);
    await _downloadAllVoiceNotes(); // Check and download new voice notes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      showDialogAtTopRight(context, _refreshBulletinData);
                    },
                    child: SvgPicture.asset('assets/icons/horn.svg'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        // In the ListView.builder inside BulletinPage
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: bulletinData.length,
                          itemBuilder: (context, index) {
                            final item = bulletinData[index];
                            final isVoiceNote = item['type'] == 'Voice';
                            final voiceNoteUrl = item['voice_note_file'];
                            final fileName = voiceNoteUrl != null
                                ? voiceNoteUrl.split('/').last
                                : null;

                            // Extract tagged users
                            final List<String> taggedUsers =
                                item['users'] != null
                                    ? List<String>.from(item['users'])
                                    : []; // Ensure it's a list of strings

                            return CustomContainer(
                              creatorName: item['creator_name'] ?? 'Unknown',
                              updatedTime: item['updated_time'] ?? 'N/A',
                              bulletinContent: isVoiceNote
                                  ? 'Voice Note'
                                  : item['bulletin_content'] ?? '',
                              bulletinType: item['type'] ?? 'Text',
                              taggedUsers: taggedUsers, // Pass the tagged users
                              extraWidget: isVoiceNote && voiceNoteUrl != null
                                  ? IconButton(
                                      icon: Icon(
                                        playingVoiceNote == voiceNoteUrl
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: playingVoiceNote == voiceNoteUrl
                                            ? Colors.green
                                            : Colors.red,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        _togglePlayPause(
                                            voiceNoteUrl, fileName!);
                                      },
                                    )
                                  : null,
                            );
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

void showDialogAtTopRight(BuildContext context, Function refreshCallback) {
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
                width: 180,
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
                    // Voice Note Option
                    Material(
                      color: Colors.transparent,
                      child: ClipRect(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                              10), // Add border radius to match the container
                          onTap: () {
                            Navigator.pop(context);
                            showVoiceNoteDialog(context, refreshCallback);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
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
                        ),
                      ),
                    ),

                    // Text Note Option
                    Material(
                      color: Colors.transparent,
                      child: ClipRect(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                              10), // Add border radius to match the container
                          onTap: () {
                            Navigator.pop(context);
                            showTextNoteDialog(context, refreshCallback);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 25,
                                ),
                                Text(
                                  'Text Note',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
