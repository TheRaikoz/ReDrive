import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:redrive/services/bluetooth_permission_service.dart';
import '../models/obd_device.dart';

class BluetoothProvider extends ChangeNotifier {
  final FlutterBlueClassic _bluetooth = FlutterBlueClassic();

  /// сканируется ?
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// подключается ?
  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  ObdDevice? _connectedDevice;
  ObdDevice? get connectedDevice => _connectedDevice;

  final List<ObdDevice> _discoveredDevices = [];
  List<ObdDevice> get discoveredDevices => _discoveredDevices;

  final Map<String, BluetoothDevice> _deviceMap = {};

  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _inputSubscription;
  StreamSubscription<BluetoothDevice>? _scanSubscription;

  Timer? _scanTimer;

  bool _isHardwareOn = false;
  bool get isHardwareOn => _isHardwareOn;

  bool _isToggleOn = false;
  bool get isToggleOn => _isToggleOn;

  bool _pendingScan = false;

  BluetoothProvider() {
    _bluetooth.adapterStateNow.then((BluetoothAdapterState state) {
      _isHardwareOn = state == BluetoothAdapterState.on;
      notifyListeners();
    });

    _bluetooth.adapterState.listen((BluetoothAdapterState state) {
      _isHardwareOn = state == BluetoothAdapterState.on;

      if (state == BluetoothAdapterState.off) {
        developer.log("⚠️ Bluetooth ВЫКЛЮЧЕН!", name: 'reBlue');
        _isToggleOn = false;
        disconnect();
        _stopScan();
        _discoveredDevices.clear();
        _deviceMap.clear();
      } else if (state == BluetoothAdapterState.on) {
        developer.log("✅ Bluetooth ВКЛЮЧЕН!", name: 'reBlue');
        if (_pendingScan) {
          _pendingScan = false;
          startScan();
        }
      }
      notifyListeners();
    });
  }

  void _addDeviceToList(BluetoothDevice device, {bool connected = false}) {
    if (_deviceMap.containsKey(device.address)) return;

    _deviceMap[device.address] = device;
    _discoveredDevices.add(
      ObdDevice(
        name: device.name ?? "Неизвестное устройство",
        address: device.address,
        isBle: false,
      ),
    );
  }

  // когда добавим обновление сканирования
  // void _addObdDeviceToTop(ObdDevice device) {
  //   final exists = _discoveredDevices.any((d) => d.address == device.address);
  //   if (exists) return;

  //   _discoveredDevices.insert(0, device);
  // }

  Future<bool> startScan() async {
    if (_isScanning) return true;

    developer.log("Запрашиваем доступ к разрешениям", name: 'reBlue');
    final permissionsGranted = await requestBluetoothPermissions();

    if (!permissionsGranted) {
      _isScanning = false;
      notifyListeners();
      return false;
    }

    if (!_isHardwareOn) {
      _pendingScan = true;
      try {
        _bluetooth.turnOn();
      } catch (e) {
        developer.log("Ошибка вызова turnOn: $e", name: 'reBlue', error: e);
      }
      return false;
    }

    _isToggleOn = true;
    _isScanning = true;
    _pendingScan = false;
    _discoveredDevices.clear();
    _deviceMap.clear();

    /// добавить когда в ui появиться кнопка обновления
    /// if (_isConnected && _connectedDevice != null) {
    ///   _addObdDeviceToTop(_connectedDevice!);
    /// }
    notifyListeners();

    try {
      try {
        final bonded = await _bluetooth.bondedDevices;
        if (bonded != null) {
          for (final device in bonded) {
            _addDeviceToList(device);
          }
        }
      } catch (e) {
        developer.log(
          "Ошибка получения bonded devices",
          name: 'reBlue',
          error: e,
        );
      }

      notifyListeners();

      _bluetooth.startScan();
      developer.log("Сканирование запущено", name: 'reBlue');

      await _scanSubscription?.cancel();
      _scanSubscription = _bluetooth.scanResults.listen(
        (BluetoothDevice device) {
          if (!_deviceMap.containsKey(device.address)) {
            _addDeviceToList(
              device,
              connected: _connectedDevice?.address == device.address,
            );
            notifyListeners();
          }
        },
        onError: (err) {
          developer.log(
            "Ошибка в стриме сканирования",
            name: 'reBlue',
            error: err,
          );
          _stopScan();
        },
      );

      _scanTimer?.cancel();
      _scanTimer = Timer(const Duration(seconds: 15), () {
        if (_isScanning) {
          developer.log("Таймер: 15 секунд прошло, авто-стоп", name: 'reBlue');
          _stopScan();
        }
      });
    } catch (e) {
      developer.log("Scan error: $e", name: 'reBlue', error: e);
      _isScanning = false;
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> _stopScan() async {
    _scanTimer?.cancel();
    _bluetooth.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
    notifyListeners();
    developer.log("Сканирование остановлено", name: 'reBlue');
  }

  Future<bool> connectToDevice(ObdDevice device) async {
    if (_isConnected && _connectedDevice?.address == device.address) {
      return true;
    }
    if (_isConnecting) return false;

    _isConnecting = true;
    notifyListeners();

    await disconnect();

    final physicalDevice = _deviceMap[device.address];
    if (physicalDevice == null) {
      _isConnecting = false;
      notifyListeners();
      return false;
    }

    try {
      developer.log(
        "Попытка подключения к ${device.name} (${device.address})",
        name: 'reBlue',
      );

      await _bluetooth.bondDevice(physicalDevice.address);
      _connection = await _bluetooth
          .connect(physicalDevice.address)
          .timeout(const Duration(seconds: 15));

      _connectedDevice = device;
      _isConnected = true;
      _setupListen();

      _discoveredDevices.removeWhere((d) => d.address == device.address);
      _discoveredDevices.insert(0, device);

      developer.log("✅ УСПЕШНО подключено к ${device.name}", name: 'reBlue');
      notifyListeners();
      return true;
    } catch (e) {
      developer.log(
        "❌ Ошибка подключения к ${device.name}: $e",
        name: 'reBlue',
        error: e,
      );

      if (e.toString().contains("read failed") ||
          e.toString().contains("socket") ||
          e.toString().contains("couldNotConnect")) {
        developer.log(
          "Классическая ошибка Android BT (таймаут или занято)",
          name: 'reBlue',
        );
      }

      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void _setupListen() {
    _inputSubscription = _connection!.input!.listen(
      (Uint8List data) {
        final incoming = String.fromCharCodes(data);
        developer.log("RX: $incoming", name: 'reBlue');
      },
      onDone: () {
        developer.log("Поток данных закрыт (onDone)", name: 'reBlue');
        disconnect();
      },
      onError: (e) {
        developer.log("Ошибка в потоке данных", name: 'reBlue', error: e);
        disconnect();
      },
      cancelOnError: true,
    );
  }

  Future<void> disconnect() async {
    try {
      await _inputSubscription?.cancel();
      await _connection?.finish();
      _connection = null;
      developer.log("Соединение разорвано", name: 'reBlue');
    } catch (e) {
      developer.log("Ошибка при отключении: $e", name: 'reBlue', error: e);
    }

    _isConnected = false;
    _connectedDevice = null;
    _isConnecting = false;
    notifyListeners();
  }

  Future<void> turnOffBluetooth() async {
    _isToggleOn = false;
    await disconnect();
    await _stopScan();
    _discoveredDevices.clear();
    _deviceMap.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopScan();
    disconnect();
    super.dispose();
  }
}
