import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _startMonitoring();
  }

  void _startMonitoring() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      _isConnected = await InternetConnectionChecker().hasConnection;
      notifyListeners();
    });
  }
}
