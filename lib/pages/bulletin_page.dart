import 'dart:convert';
import 'package:advocate_todo_list/const.dart';
import 'package:advocate_todo_list/dialogs/text_note_dialog.dart';
import 'package:advocate_todo_list/dialogs/voice_note_dialog.dart';
import 'package:advocate_todo_list/widgets/custom_container.dart';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      fetchBulletinData(loginUserId!);
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

  Future<void> _togglePlayPause(String voiceNoteUrl) async {
    if (playingVoiceNote == voiceNoteUrl) {
      await _audioPlayer!.stopPlayer();
      setState(() {
        playingVoiceNote = null;
      });
    } else {
      await _audioPlayer!.startPlayer(
        fromURI: voiceNoteUrl,
        whenFinished: () {
          setState(() {
            playingVoiceNote = null;
          });
        },
      );
      setState(() {
        playingVoiceNote = voiceNoteUrl;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer?.closePlayer();
    super.dispose();
  }

  void _refreshBulletinData() {
    if (loginUserId != null) {
      setState(() {
        isLoading = true;
      });
      fetchBulletinData(loginUserId!);
    }
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
                child: ListView.builder(
                  itemCount: bulletinData.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = bulletinData[index];
                    final isVoiceNote = item['type'] == 'Voice';
                    final voiceNoteUrl = item['voice_note_file'];
                    final fileName = voiceNoteUrl
                        ?.split('/')
                        ?.last ?? '';

                    return CustomContainer(
                      creatorName: item['creator_name'] ?? 'Unknown',
                      updatedTime: item['updated_time'] ?? 'N/A',
                      bulletinContent: isVoiceNote
                          ? fileName
                          : item['bulletin_content'] ?? '',
                      bulletinType: item['type'] ?? 'Text',
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
                          _togglePlayPause(voiceNoteUrl);
                        },
                      )
                          : null,
                    );
                  },
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
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 30,
                  bottom: 20,
                  right: 40,
                ),
                width: 220,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showVoiceNoteDialog(context, refreshCallback);
                      },
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
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showTextNoteDialog(context, refreshCallback);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.add,
                            size: 25,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Text(
                              'Text Note',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
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