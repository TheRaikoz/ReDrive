import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/obd_data.dart';
import '../services/obd_connection.dart';
import '../services/demo_obd_connection.dart';

enum ObdConnectionState { disconnected, initializing, ready, error }

class ObdProvider extends ChangeNotifier {
  final ObdConnection realConnection;
  late ObdConnection _connection;

  StreamSubscription<String>? _rxSubscription;

  Completer<String>? _initCompleter;
  final StringBuffer _initBuffer = StringBuffer();

  ObdConnectionState _state = ObdConnectionState.disconnected;
  ObdConnectionState get state => _state;

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
    if (_state == ObdConnectionState.initializing) {
      _initBuffer.write(rawData);
      if (rawData.contains(">")) {
        _initCompleter?.complete(_initBuffer.toString());
      }
      return;
    }

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

  Future<String> _sendAndWait(String command) async {
    _initBuffer.clear();
    _initCompleter = Completer<String>();

    _connection.send("$command\r");

    return await _initCompleter!.future.timeout(const Duration(seconds: 3));
  }

  Future<bool> runHandshake() async {
    try {
      _state = ObdConnectionState.initializing;
      notifyListeners();

      String atz = await _sendAndWait("ATZ");
      if (!atz.contains("ELM327")) {
        developer.log("Ошибка: Адаптер не представился как ELM. Ответ: $atz");
        return false;
      }

      String ate0 = await _sendAndWait("ATE0");
      if (!ate0.contains("OK")) {
        developer.log("Ошибка: Не удалось выключить ЭХО. Ответ: $ate0");
        return false;
      }

      String atl0 = await _sendAndWait("ATL0");
      if (!atl0.contains("OK")) return false;

      String atsp0 = await _sendAndWait("ATSP0");
      if (!atsp0.contains("OK")) {
        developer.log("Ошибка: Машина не приняла протокол. Ответ: $atsp0");
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// ===================== REAL MODE =====================

  Future<void> toggleRealMode() async {
    if (!realConnection.isConnected) return;

    if (_isRealMode) {
      await stopRealData();
      _state = ObdConnectionState.disconnected;
      notifyListeners();
      return;
    }

    if (_isDemoMode) {
      await _connection.disconnect();
      _isDemoMode = false;
      _data = const ObdData();
    }

    _connection = realConnection;
    _listen();

    bool isSuccesHandshake = await runHandshake();

    if (isSuccesHandshake) {
      startRealData();
      _state = ObdConnectionState.ready;
    } else {
      _state = ObdConnectionState.error;
      notifyListeners();
    }
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
