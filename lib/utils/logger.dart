import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;

  Logger._internal();

  late File _logFile;

  Future<void> init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    _logFile = File('${appDocDir.path}/app_logs.txt');
    if (!await _logFile.exists()) {
      await _logFile.create();
    }
  }

  Future<void> log(String message) async {
    String timeStamp = DateTime.now().toString();
    await _logFile.writeAsString('$timeStamp: $message\n',
        mode: FileMode.append);
  }

  Future<String> readLogs() async {
    return await _logFile.readAsString();
  }
}
