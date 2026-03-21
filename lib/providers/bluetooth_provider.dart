import 'dart:async';
// import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redrive/services/bluetooth_permission_service.dart';
import '../models/obd_device.dart';

class BluetoothProvider extends ChangeNotifier {
  final FlutterBlueClassic _bluetooth = FlutterBlueClassic();

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  ObdDevice? _connectedDevice;
  ObdDevice? get connectedDevice => _connectedDevice;

  final List<ObdDevice> _discoveredDevices = [];
  List<ObdDevice> get discoveredDevices => _discoveredDevices;

  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _inputSubscription;
  StreamSubscription<BluetoothDevice>? _scanSubscription;

  bool _isHardwareOn = false;
  bool get isHardwareOn => _isHardwareOn;

  bool _isToggleOn = false;
  bool get isToggleOn => _isToggleOn;

  bool _pendingScan = false;

  final Map<String, BluetoothDevice> _deviceMap = {};

  BluetoothProvider() {
    _bluetooth.adapterStateNow.then((BluetoothAdapterState state) {
      _isHardwareOn = state == BluetoothAdapterState.on;
      notifyListeners();
    });

    _bluetooth.adapterState.listen((BluetoothAdapterState state) {
      _isHardwareOn = state == BluetoothAdapterState.on;

      if (state == BluetoothAdapterState.off) {
        debugPrint("[reBlue] ⚠️ Bluetooth ВЫКЛЮЧЕН!");
        _isToggleOn = false;
        disconnect();
        _discoveredDevices.clear();
        _deviceMap.clear();
        _isScanning = false;
      } else if (state == BluetoothAdapterState.on) {
        debugPrint("[reBlue] ✅ Bluetooth ВКЛЮЧЕН!");
        if (_pendingScan) {
          _pendingScan = false;
          startScan();
        }
      }
      notifyListeners();
    });
  }

  // ==================== HELPERS ====================
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

  void _addObdDeviceToTop(ObdDevice device) {
    final exists = _discoveredDevices.any((d) => d.address == device.address);
    if (exists) return;

    _discoveredDevices.insert(0, device);
  }

  // ==================== ПОИСК ====================
  Future<bool> startScan() async {
    if (_isScanning) return true;

    debugPrint("[reBlue] запрашиваем доступ к разрешениям");
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
        debugPrint("[reBlue] Ошибка вызова turnOn: $e");
      }

      return false;
    }

    _isToggleOn = true;
    _isScanning = true;
    _pendingScan = false;
    _discoveredDevices.clear();
    _deviceMap.clear();

    if (_isConnected && _connectedDevice != null) {
      _addObdDeviceToTop(_connectedDevice!);
    }
    notifyListeners();

    try {
      // 2) СРАЗУ показываем все спаренные устройства
      final bonded = await _bluetooth.bondedDevices ?? [];
      for (final device in bonded) {
        _addDeviceToList(
          device,
          connected: _connectedDevice?.address == device.address,
        );
      }

      notifyListeners();

      // 3) Потом запускаем живой скан
      _bluetooth.startScan();

      await _scanSubscription?.cancel();
      _scanSubscription = _bluetooth.scanResults.listen((
        BluetoothDevice device,
      ) {
        if (!_deviceMap.containsKey(device.address)) {
          _addDeviceToList(
            device,
            connected: _connectedDevice?.address == device.address,
          );
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint("[reBlue] Scan error: $e");
      _isScanning = false;
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> _stopScan() async {
    _bluetooth.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
    notifyListeners();
  }

  // ==================== ПОДКЛЮЧЕНИЕ ====================
  Future<bool> connectToDevice(ObdDevice device) async {
    if (_isConnected && _connectedDevice?.address == device.address) {
      return true;
    }
    if (_isConnecting) return false;

    _isConnecting = true;
    notifyListeners();

    await disconnect();

    final btDevice = _deviceMap[device.address];
    if (btDevice == null) {
      _isConnecting = false;
      notifyListeners();
      return false;
    }

    try {
      debugPrint("[reBlue] Спаривание + подключение к ${device.name}");

      await _bluetooth.bondDevice(btDevice.address);
      _connection = await _bluetooth
          .connect(btDevice.address)
          .timeout(const Duration(seconds: 15));

      _connectedDevice = device;
      _isConnected = true;
      _setupListen();

      // Чтобы подключенное устройство сразу было первым в списке
      _discoveredDevices.removeWhere((d) => d.address == device.address);
      _discoveredDevices.insert(0, device);

      debugPrint("[reBlue] ✅ УСПЕШНО подключено к ${device.name}");
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("[reBlue] ❌ Ошибка подключения к ${device.name}: $e");

      if (e.toString().contains("read failed") ||
          e.toString().contains("socket") ||
          e.toString().contains("couldNotConnect")) {
        debugPrint(
          "[reBlue] Классическая ошибка Android BT (таймаут или уже занято)",
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
        debugPrint("[reBlue] RX: $incoming");
      },
      onDone: () => disconnect(),
      onError: (e) => disconnect(),
      cancelOnError: true,
    );
  }

  Future<void> disconnect() async {
    try {
      await _inputSubscription?.cancel();
      await _connection?.finish();
      _connection = null;
    } catch (e) {
      debugPrint("[reBlue] Ошибка отключения: $e");
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
