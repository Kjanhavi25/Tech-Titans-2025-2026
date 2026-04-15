import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityService() {
    _init();
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected != _isConnected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
  }

  Future<bool> checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _isConnected = results.any((r) => r != ConnectivityResult.none);
    return _isConnected;
  }
}
