import 'package:flutter/material.dart';
import 'logger.dart'; // Import your Logger class here

class LoggerRead extends StatefulWidget {
  const LoggerRead({super.key});

  @override
  State<LoggerRead> createState() => _LoggerReadState();
}

class _LoggerReadState extends State<LoggerRead> {
  String _logs = 'Loading...'; // Initial message

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    String logs = await Logger().readLogs(); // Read logs from the Logger
    setState(() {
      _logs = logs.isEmpty ? 'No logs available.' : logs; // Update logs
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            _logs,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
