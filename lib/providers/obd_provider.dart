import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/obd_data.dart';
import '../services/obd_connection.dart';
import '../services/demo_obd_connection.dart';

enum ObdConnectionState { disconnected, initializing, ready, error }

class ObdProvider extends ChangeNotifier {
  final ObdConnection currentConnection;
  late ObdConnection _connection;

  StreamSubscription<String>? _rxSubscription;

  Completer<String>? _commandCompleter;
  final StringBuffer _commandBuffer = StringBuffer();

  ObdConnectionState _state = ObdConnectionState.disconnected;
  ObdConnectionState get state => _state;

  ObdData _data = const ObdData();
  ObdData get data => _data;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  bool _isRealMode = false;
  bool get isRealMode => _isRealMode;

  /// For debug    ///
  /// Для откладки ///
  set state(ObdConnectionState value) {
    if (_state == value) return;

    developer.log('🔄 СМЕНА СОСТОЯНИЯ: $_state -> $value', name: 'ObdProvider');

    _state = value;
    notifyListeners();
  }

  ObdProvider(this.currentConnection) {
    _connection = currentConnection;
    _listen();
  }

  void _listen() {
    _rxSubscription?.cancel();
    _rxSubscription = _connection.incoming.listen(_handleIncomingData);
  }

  /// ======= Парсинг ======== ///

  void _handleIncomingData(String rawData) {
    /// буфер для команд отправляемых
    /// без demo режима пишутся в буфер и по
    /// завершению отправляют состояние "выполнено"
    _commandBuffer.write(rawData);
    if (rawData.contains(">")) {
      if (_commandCompleter?.isCompleted == false) {
        _commandCompleter?.complete(_commandBuffer.toString());
      }
    }

    /// если режим демонстрации то мы
    /// просто отправялем пустой объект
    /// obdData и целиком обновляем его
    if (_isDemoMode) {
      final cleanData = rawData.replaceAll('>', '').trim();
      if (cleanData.isNotEmpty &&
          cleanData != "OK" &&
          !cleanData.contains("ELM327")) {
        _data = _parseResponse(cleanData, _data);
        notifyListeners();
      }
    }
  }

  /// получаем команду -> ставим новый обработчик "успешности"
  /// отправляем в текущее соединение команду и ждём ответ
  Future<String> _sendAndWait(String command) async {
    _commandBuffer.clear();
    _commandCompleter = Completer<String>();

    _connection.send("$command\r");

    try {
      return await _commandCompleter!.future.timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      developer.log("таймаут команды $command: $e", name: 'ObdLogic');
      return "";
    }
  }

  /// парсим значения от нашего текущего подключения, и возвращаем объект
  /// пакета данных если всё прошло корректно
  /// сейчас уже умеет парсить: скорость, обороты движка
  /// температуру движка и напряжение сети ( акб'шку )
  ObdData _parseResponse(String rawData, ObdData currentBatchData) {
    final cleanData = rawData.replaceAll('>', '').trim();

    if (cleanData.isEmpty ||
        cleanData == "OK" ||
        cleanData.contains("ELM327")) {
      return currentBatchData;
    }

    developer.log("⬇️ ОТВЕТ: $cleanData", name: 'ObdLogic');

    final parts = cleanData.split(RegExp(r'\s+'));

    try {
      /// скорость
      if (parts.length >= 3 && parts[0] == "41" && parts[1] == "0D") {
        return currentBatchData.copyWith(speed: int.parse(parts[2], radix: 16));

        /// обороты
      } else if (parts.length >= 4 && parts[0] == "41" && parts[1] == "0C") {
        final a = int.parse(parts[2], radix: 16);
        final b = int.parse(parts[3], radix: 16);
        return currentBatchData.copyWith(rpm: ((a * 256) + b) ~/ 4);

        /// температура
      } else if (parts.length >= 3 && parts[0] == "41" && parts[1] == "05") {
        return currentBatchData.copyWith(
          engineTemp: int.parse(parts[2], radix: 16) - 40,
        );

        /// напряжение сети
      } else if (cleanData.contains('V')) {
        final voltValue = double.tryParse(cleanData.replaceAll('V', ''));
        if (voltValue != null) {
          return currentBatchData.copyWith(voltage: voltValue);
        }
      }
    } catch (e) {
      developer.log("ошибка парсинга: $e", name: 'ObdLogic');
    }

    return currentBatchData;
  }

  /// ======= REAL MODE ========= ///

  /// если у нас есть реальное подключенное устройство, то
  /// мы отправляем запросы "инициализации" и после этого крутим
  /// цикл обработки запросов от нашего elm327 по obd2 разьёму
  Future<void> toggleRealMode() async {
    if (!currentConnection.isConnected) return;

    if (_isRealMode) {
      stopRealData();
      state = ObdConnectionState.disconnected;
      return;
    }

    if (_isDemoMode) {
      await _connection.disconnect();
      _isDemoMode = false;
      _data = const ObdData();
    }

    _connection = currentConnection;
    _listen();

    bool isSuccessHandshake = await runHandshake();

    if (isSuccessHandshake) {
      _isRealMode = true;
      state = ObdConnectionState.ready;
      _startPollingLoop();
    } else {
      state = ObdConnectionState.error;
    }
  }

  ///
  Future<void> _startPollingLoop() async {
    while (_isRealMode && _connection.isConnected) {
      ObdData batchData = _data;

      String speedRes = await _sendAndWait("010D");
      batchData = _parseResponse(speedRes, batchData);

      String rpmRes = await _sendAndWait("010C");
      batchData = _parseResponse(rpmRes, batchData);

      String tempRes = await _sendAndWait("0105");
      batchData = _parseResponse(tempRes, batchData);

      String voltRes = await _sendAndWait("ATRV");
      batchData = _parseResponse(voltRes, batchData);

      if (!isRealMode) return;

      _data = batchData;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void stopRealData() {
    _isRealMode = false;
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
    _isDemoMode = true;
    _listen();

    await _connection.connect();

    notifyListeners();
  }

  Future<bool> runHandshake() async {
    try {
      state = ObdConnectionState.initializing;
      notifyListeners();

      String atz = await _sendAndWait("ATZ");
      if (!atz.toUpperCase().contains("ELM327")) return false;

      String ate0 = await _sendAndWait("ATE0");
      if (!ate0.toUpperCase().contains("OK")) return false;

      String atl0 = await _sendAndWait("ATL0");
      if (!atl0.toUpperCase().contains("OK")) return false;

      String atsp0 = await _sendAndWait("ATSP0");
      if (!atsp0.toUpperCase().contains("OK")) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// ===================== CLEANUP =====================

  @override
  void dispose() {
    _isRealMode = false;
    _rxSubscription?.cancel();
    super.dispose();
  }
}
