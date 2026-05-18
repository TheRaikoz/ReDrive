import 'package:flutter/foundation.dart';

enum ConnectionMode { classic, ble }

class ConnectionModeProvider extends ChangeNotifier {
  ConnectionMode _mode = ConnectionMode.classic;
  ConnectionMode get mode => _mode;

  bool get isClassic => _mode == ConnectionMode.classic;
  bool get isBle => _mode == ConnectionMode.ble;

  void setMode(ConnectionMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    _mode = _mode == ConnectionMode.classic
        ? ConnectionMode.ble
        : ConnectionMode.classic;
    notifyListeners();
  }
}
