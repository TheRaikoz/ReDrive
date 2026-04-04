import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/obd_data.dart';
import '../services/obd_connection.dart';
import '../services/demo_obd_connection.dart';

class ObdProvider extends ChangeNotifier {
  final ObdConnection realConnection;
  late ObdConnection _connection;

  StreamSubscription<String>? _rxSubscription;

  ObdData _data = const ObdData();
  ObdData get data => _data;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  bool _isRealMode = false;
  bool get isRealMode => _isRealMode;

  Timer? _pollTimer;

  ObdProvider(this.realConnection) {
    _connection = realConnection;
    _listen();
  }

  /// подписка на входящий поток
  void _listen() {
    _rxSubscription?.cancel();
    _rxSubscription = _connection.incoming.listen(_handleIncomingData);
  }

  /// ===================== ПАРСИНГ =====================

  void _handleIncomingData(String rawData) {
    if (!_isRealMode && !_isDemoMode) return;

    final cleanData = rawData.replaceAll('>', '').trim();

    if (cleanData.isEmpty ||
        cleanData == "OK" ||
        cleanData.contains("ELM327")) {
      return;
    }

    developer.log("⬇️ ОТВЕТ: $cleanData", name: 'ObdLogic');

    final parts = cleanData.split(' ');

    try {
      // SPEED
      if (parts.length >= 3 && parts[0] == "41" && parts[1] == "0D") {
        _data = _data.copyWith(speed: int.parse(parts[2], radix: 16));
        notifyListeners();
      }
      // RPM
      else if (parts.length >= 4 && parts[0] == "41" && parts[1] == "0C") {
        final a = int.parse(parts[2], radix: 16);
        final b = int.parse(parts[3], radix: 16);
        _data = _data.copyWith(rpm: ((a * 256) + b) ~/ 4);
        notifyListeners();
      }
      // ENGINE TEMP
      else if (parts.length >= 3 && parts[0] == "41" && parts[1] == "05") {
        _data = _data.copyWith(engineTemp: int.parse(parts[2], radix: 16) - 40);
        notifyListeners();
      }
      // VOLTAGE
      else if (cleanData.contains('V')) {
        final voltValue = double.tryParse(cleanData.replaceAll('V', ''));

        if (voltValue != null) {
          _data = _data.copyWith(voltage: voltValue);
          notifyListeners();
        }
      }
    } catch (e) {
      developer.log("Ошибка парсинга: $e", name: 'ObdLogic');
    }
  }

  /// ===================== REAL MODE =====================

  Future<void> toggleRealMode() async {
    if (!realConnection.isConnected) return;

    if (_isRealMode) {
      await stopRealData();
      return;
    }

    /// если был demo → выключаем
    if (_isDemoMode) {
      await _connection.disconnect();
      _isDemoMode = false;
    }

    _connection = realConnection;
    _listen();

    startRealData();
  }

  void startRealData() {
    _isRealMode = true;
    _pollTimer?.cancel();

    int step = 0;

    _pollTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!_connection.isConnected) {
        stopRealData();
        return;
      }

      switch (step) {
        case 0:
          _connection.send("010D");
          break;
        case 1:
          _connection.send("010C");
          break;
        case 2:
          _connection.send("0105");
          break;
        case 3:
          _connection.send("ATRV");
          break;
      }

      step = (step + 1) % 4;
    });

    notifyListeners();
  }

  Future<void> stopRealData() async {
    _pollTimer?.cancel();
    _pollTimer = null;

    _isRealMode = false;

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _data = const ObdData();
    notifyListeners();
  }

  /// ===================== DEMO MODE =====================

  Future<void> toggleDemoMode() async {
    if (_isRealMode) {
      return;
    }

    if (_isDemoMode) {
      await _connection.disconnect();
      _isDemoMode = false;
      _data = const ObdData();
      notifyListeners();
      return;
    }

    _connection = DemoObdConnection();
    await _connection.connect();
    _isDemoMode = true;
    _listen();
    notifyListeners();
  }

  /// ===================== CLEANUP =====================

  @override
  void dispose() {
    _rxSubscription?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }
}
