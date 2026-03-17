import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import '../models/obd_device.dart';

class BluetoothProvider extends ChangeNotifier {
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  ObdDevice? _connectedDevice;
  ObdDevice? get connectedDevice => _connectedDevice;

  List<ObdDevice> _discoveredDevices = [];
  List<ObdDevice> get discoveredDevices => _discoveredDevices;

  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _inputSubscription;

  bool _isHardwareOn = false;
  bool get isHardwareOn => _isHardwareOn;

  bool _isToggleOn = false;
  bool get isToggleOn => _isToggleOn;

  BluetoothProvider() {
    FlutterBluetoothSerial.instance.state.then((state) {
      _isHardwareOn = state == BluetoothState.STATE_ON;
      notifyListeners();
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((
      BluetoothState state,
    ) {
      _isHardwareOn = state == BluetoothState.STATE_ON;

      if (state == BluetoothState.STATE_OFF) {
        debugPrint("[reBlue] ⚠️ Bluetooth ВЫКЛЮЧЕН в настройках телефона!");
        _isToggleOn = false;

        disconnect();
        _discoveredDevices.clear();
        _isScanning = false;
      }
      notifyListeners();
    });
  }

  // --- ПОИСК И ВКЛЮЧЕНИЕ ---
  Future<bool> startScan() async {
    if (_isScanning) return true;

    _isToggleOn = true;
    notifyListeners();

    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();

    if (statuses[Permission.bluetoothConnect] == PermissionStatus.denied ||
        statuses[Permission.bluetoothConnect] ==
            PermissionStatus.permanentlyDenied) {
      debugPrint("[reBlue] ❌ Нет доступа к Bluetooth");
      // ОТКАТЫВАЕМ ТУМБЛЕР ЕСЛИ ЗАПРЕТИЛИ
      _isToggleOn = false;
      notifyListeners();
      return false;
    }

    BluetoothState state = await FlutterBluetoothSerial.instance.state;

    if (state == BluetoothState.STATE_OFF) {
      bool? enabled = await FlutterBluetoothSerial.instance.requestEnable();
      if (enabled != true) {
        _isToggleOn = false;
        notifyListeners();
        return false;
      }
    }

    _isScanning = true;
    _discoveredDevices.clear();
    notifyListeners();

    try {
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance
          .getBondedDevices();

      _isConnected = false;
      _connectedDevice = null;

      _discoveredDevices = devices.map((device) {
        ObdDevice obdDevice = ObdDevice(
          name: device.name ?? "Неизвестное устройство",
          address: device.address,
          isBle: false,
        );

        if (device.isConnected) {
          _isConnected = true;
          _connectedDevice = obdDevice;
        }
        return obdDevice;
      }).toList();
    } catch (e) {
      debugPrint("[reBlue] Scan error: $e");
    } finally {
      _isScanning = false;
      notifyListeners();
    }

    return true;
  }

  // --- ПОЛНОЕ ВЫКЛЮЧЕНИЕ ---
  Future<void> turnOffBluetooth() async {
    debugPrint("[reBlue] Выключаем всё!!!!!!!!!!!!!!!");
    _isToggleOn = false; // Выключаем тумблер
    await disconnect();
    _discoveredDevices.clear();
    notifyListeners();
  }

  // --- РЕАЛЬНОЕ ПОДКЛЮЧЕНИЕ (тут без изменений) ---
  // --- РЕАЛЬНОЕ ПОДКЛЮЧЕНИЕ С ЖЕСТКИМ ТАЙМАУТОМ ---
  Future<bool> connectToDevice(
    ObdDevice device, {
    bool isFallback = false,
  }) async {
    if (_isConnected && _connectedDevice?.address == device.address) {
      return true;
    }
    if (_isConnecting) return false;

    _isConnecting = true;
    final previousDevice = _connectedDevice;

    // Отключаем текущее подключение, если оно есть
    await disconnect();

    try {
      // Пытаемся подключиться к новому устройству
      debugPrint("[reBlue] Подключение к ${device.name}");
      _connection = await BluetoothConnection.toAddress(
        device.address,
      ).timeout(const Duration(seconds: 8));

      _connectedDevice = device;
      _isConnected = true;
      _isConnecting = false;
      _setupListen(); // Подключаем поток данных
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("[reBlue] Ошибка при подключении к ${device.name}: $e");
      _connection = null;
      await Future.delayed(
        const Duration(milliseconds: 900),
      ); // Задержка перед повторной попыткой
    }

    // Если подключение не удалось и есть предыдущий девайс, пробуем подключиться к нему
    if (previousDevice != null && !isFallback) {
      debugPrint(
        "[reBlue] Рерол: попытка подключиться к ${previousDevice.name}",
      );
      try {
        _connection = await BluetoothConnection.toAddress(
          previousDevice.address,
        ).timeout(const Duration(seconds: 8));

        _connectedDevice = previousDevice;
        _isConnected = true;
        _isConnecting = false;
        _setupListen(); // Подключаем поток данных
        notifyListeners();
        return false; // Откат на предыдущее устройство, если новое не удалось подключить
      } catch (e) {
        debugPrint(
          "[reBlue] Ошибка при подключении к ${previousDevice.name}: $e",
        );
      }
    }

    // Если ничего не получилось, сбрасываем статус
    _isConnected = false;
    _connectedDevice = null;
    _isConnecting = false;
    notifyListeners();
    return false;
  }

  void _setupListen() {
    _inputSubscription = _connection!.input!.listen(
      (Uint8List data) {
        String incoming = String.fromCharCodes(data);
        debugPrint("[reBlue] RX $incoming");
      },
      onDone: () => disconnect(),
      onError: (e) => disconnect(),
      cancelOnError: true,
    );
  }

  Future<void> disconnect() async {
    try {
      if (_connection != null) {
        await _inputSubscription?.cancel(); // Закрываем подписку на поток
        await _connection!.finish(); // Закрываем соединение
        _connection = null;
      }
      _isConnected = false;
      _connectedDevice = null;
      _isConnecting = false;
      notifyListeners();
    } catch (e) {
      debugPrint("[reBlue] Ошибка при отключении: $e");
      _isConnected = false;
      _connectedDevice = null;
      _isConnecting = false;
      notifyListeners();
    }
  }
}
