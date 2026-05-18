import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:redrive/models/obd_device.dart';
import 'package:redrive/providers/base_obd_transport_provider.dart';
import 'package:redrive/services/bluetooth_permission_service.dart';

/// [BleProvider] — центральный узел управления Bluetooth Low Energy (BLE).
///
/// Обеспечивает жизненный цикл соединений: от сканирования до обмена данными.
/// Реализует защиту от race conditions с помощью системы уникальных ID вызовов.
class BleProvider extends BaseObdTransportProvider {
  /// Nordic UART Service UUID (стандарт для ELM327 BLE)
  static final Guid _uartServiceUuid =
      Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid _uartTxCharacteristicUuid =
      Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid _uartRxCharacteristicUuid =
      Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');

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

  final Map<String, BluetoothDevice> _deviceMap = {};

  BluetoothDevice? _connectedBleDevice;
  BluetoothCharacteristic? _txCharacteristic;
  BluetoothCharacteristic? _rxCharacteristic;
  StreamSubscription<List<int>>? _txSubscription;

  final _rxController = StreamController<String>.broadcast();
  Stream<String> get rxStream => _rxController.stream;

  int _connectionId = 0;

  String _connectionMessage = "";
  String get connectionMessage => _connectionMessage;

  String _backgroundMessage = "";
  String get backgroundMessage => _backgroundMessage;

  bool _isReconnectingBackground = false;
  bool get isReconnectingBackground => _isReconnectingBackground;

  Timer? _scanTimer;

  bool _isHardwareOn = false;
  bool get isHardwareOn => _isHardwareOn;

  bool _isToggleOn = false;
  bool get isToggleOn => _isToggleOn;

  bool _pendingScan = false;

  BleProvider() {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      _isHardwareOn = state == BluetoothAdapterState.on;

      if (state == BluetoothAdapterState.off) {
        developer.log("⚠️ Bluetooth ВЫКЛЮЧЕН!", name: 'reBle');
        _isToggleOn = false;
        disconnect();
        _stopScan();
        _discoveredDevices.clear();
        _deviceMap.clear();
      } else if (state == BluetoothAdapterState.on) {
        developer.log("✅ Bluetooth ВКЛЮЧЕН!", name: 'reBle');
        if (_pendingScan) {
          _pendingScan = false;
          startScan();
        }
      }
      notifyListeners();
    });

    _isHardwareOn = FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on;
    notifyListeners();
  }

  void _addDeviceToList(ScanResult result) {
    final deviceId = result.device.remoteId.str;
    if (_deviceMap.containsKey(deviceId)) return;

    _deviceMap[deviceId] = result.device;
    _discoveredDevices.add(
      ObdDevice(
        name: result.device.platformName.isNotEmpty
            ? result.device.platformName
            : "Неизвестное устройство",
        address: deviceId,
        connectionType: ConnectionType.ble,
      ),
    );
  }

  Future<bool> startScan() async {
    if (_isScanning) return true;

    developer.log("Запрашиваем доступ к разрешениям", name: 'reBle');
    final permissionsGranted = await requestBluetoothPermissions();

    if (!permissionsGranted) {
      _isScanning = false;
      notifyListeners();
      return false;
    }

    if (!_isHardwareOn) {
      _pendingScan = true;
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        developer.log("Ошибка вызова turnOn: $e", name: 'reBle', error: e);
      }
      return false;
    }

    _isToggleOn = true;
    _isScanning = true;
    _pendingScan = false;

    final activePhysicalDevice = (_isConnected && _connectedDevice != null)
        ? _deviceMap[_connectedDevice!.address]
        : null;

    _discoveredDevices.clear();
    _deviceMap.clear();

    if (activePhysicalDevice != null && _connectedDevice != null) {
      _deviceMap[activePhysicalDevice.remoteId.str] = activePhysicalDevice;
      _discoveredDevices.add(_connectedDevice!);
    }

    notifyListeners();

    try {
      await FlutterBluePlus.stopScan();

      developer.log("Сканирование запущено", name: 'reBle');

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [_uartServiceUuid],
      );

      _scanTimer?.cancel();
      _scanTimer = Timer(const Duration(seconds: 15), () {
        if (_isScanning) {
          developer.log("Таймер: 15 секунд прошло, авто-стоп", name: 'reBle');
          _stopScan();
        }
      });

      FlutterBluePlus.onScanResults.listen(
        (List<ScanResult> results) {
          for (final result in results) {
            if (result.device.platformName.isNotEmpty ||
                result.advertisementData.serviceUuids
                    .contains(_uartServiceUuid)) {
              _addDeviceToList(result);
              notifyListeners();
            }
          }
        },
        onError: (err) {
          developer.log(
            "Ошибка в стриме сканирования",
            name: 'reBle',
            error: err,
          );
          _stopScan();
        },
      );

      FlutterBluePlus.isScanning.listen((isScanning) {
        if (!isScanning && _isScanning) {
          _stopScan();
        }
      });
    } catch (e) {
      developer.log("Scan error: $e", name: 'reBle', error: e);
      _isScanning = false;
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> _stopScan() async {
    _scanTimer?.cancel();
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      developer.log("Ошибка остановки скана: $e", name: 'reBle', error: e);
    }
    _isScanning = false;
    notifyListeners();
    developer.log("Сканирование остановлено", name: 'reBle');
  }

  Future<bool> connectToDevice(ObdDevice device) async {
    if (_isConnected && _connectedDevice?.address == device.address) {
      return true;
    }
    if (_isConnecting) return false;

    _connectionId++;
    final int currentId = _connectionId;

    _isReconnectingBackground = false;

    _isConnecting = true;
    _connectionMessage = "Подключение к ${device.name}...";

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    await disconnect();

    if (currentId != _connectionId) return false;

    final bleDevice = _deviceMap[device.address];
    if (bleDevice == null) {
      _isConnecting = false;
      notifyListeners();
      return false;
    }

    for (int i = 1; i <= 3; i++) {
      try {
        developer.log(
          "Попытка подключения к ${device.name} (${device.address}) №$i",
          name: 'reBle',
        );

        if (i > 1) {
          _connectionMessage = "Попытка подключения №${i - 1}";
        } else {
          _connectionMessage = "Обмен данными...";
        }
        notifyListeners();

        await bleDevice.connect(
          license: License.free,
          autoConnect: false,
          mtu: null,
        ).timeout(const Duration(seconds: 10));

        if (currentId != _connectionId) {
          await bleDevice.disconnect();
          return false;
        }

        developer.log("Поиск UART сервиса...", name: 'reBle');

        List<BluetoothService> services;
        try {
          services = await bleDevice.discoverServices().timeout(
            const Duration(seconds: 10),
          );
        } catch (e) {
          developer.log("Ошибка discovery сервисов: $e", name: 'reBle');
          await bleDevice.disconnect();
          continue;
        }

        BluetoothService? uartService;
        for (final service in services) {
          if (service.uuid == _uartServiceUuid) {
            uartService = service;
            break;
          }
        }

        if (uartService == null) {
          developer.log("UART сервис не найден", name: 'reBle');
          await bleDevice.disconnect();
          continue;
        }

        BluetoothCharacteristic? txChar;
        BluetoothCharacteristic? rxChar;

        for (final characteristic in uartService.characteristics) {
          if (characteristic.uuid == _uartTxCharacteristicUuid) {
            txChar = characteristic;
          } else if (characteristic.uuid == _uartRxCharacteristicUuid) {
            rxChar = characteristic;
          }
        }

        if (txChar == null || rxChar == null) {
          developer.log("TX/RX характеристики не найдены", name: 'reBle');
          await bleDevice.disconnect();
          continue;
        }

        _txCharacteristic = txChar;
        _rxCharacteristic = rxChar;
        _connectedBleDevice = bleDevice;
        _connectedDevice = device;
        _isConnected = true;

        await _setupListen();

        _discoveredDevices.removeWhere((d) => d.address == device.address);
        _discoveredDevices.insert(0, device);

        developer.log("✅ УСПЕШНО подключено к ${device.name}", name: 'reBle');
        if (currentId == _connectionId) {
          _isConnecting = false;
        }
        notifyListeners();
        return true;
      } catch (e) {
        developer.log(
          "❌ Ошибка подключения к ${device.name}: $e",
          name: 'reBle',
          error: e,
        );

        if (currentId != _connectionId) return false;
        if (i < 3) {
          await Future.delayed(const Duration(milliseconds: 2000));
        } else {
          _isConnected = false;
          _connectedDevice = null;
          _isConnecting = false;
          notifyListeners();
          return false;
        }
      }
    }

    _isConnecting = false;
    notifyListeners();
    return false;
  }

  Future<void> _setupListen() async {
    try {
      await _txCharacteristic!.setNotifyValue(true);

      _txSubscription = _txCharacteristic!.onValueReceived.listen(
        (List<int> data) {
          final incoming = String.fromCharCodes(data);
          _rxController.add(incoming);
        },
        onDone: () {
          developer.log("Поток данных закрыт (onDone)", name: 'reBle');
          disconnect(isIntentional: false);
        },
        onError: (e) {
          developer.log("Ошибка в потоке данных", name: 'reBle', error: e);
          disconnect(isIntentional: false);
        },
        cancelOnError: true,
      );
    } catch (e) {
      developer.log("Ошибка настройки listen: $e", name: 'reBle', error: e);
      disconnect(isIntentional: false);
    }
  }

  void sendCommand(String command) {
    if (!_isConnected || _rxCharacteristic == null) return;

    try {
      final data = Uint8List.fromList('$command\r'.codeUnits);
      _rxCharacteristic!.write(data, withoutResponse: true);
      developer.log("➡️ Отправлено: $command", name: 'reBle');
    } catch (e) {
      developer.log("❌ Ошибка отправки команды: $e", name: 'reBle');
    }
  }

  Future<void> disconnect({bool isIntentional = true}) async {
    try {
      await _txSubscription?.cancel();
      _txSubscription = null;

      if (_connectedBleDevice != null) {
        await _connectedBleDevice!.disconnect();
      }

      _connectedBleDevice = null;
      _txCharacteristic = null;
      _rxCharacteristic = null;
      developer.log("Соединение разорвано", name: 'reBle');
    } catch (e) {
      developer.log("Ошибка при отключении: $e", name: 'reBle', error: e);
    }

    if (isIntentional) {
      _isConnected = false;
      _connectedDevice = null;
      _isConnecting = false;
      notifyListeners();
    } else {
      _startBackgroundReconnect();
    }
  }

  Future<void> _startBackgroundReconnect() async {
    if (_connectedDevice == null) return;

    _connectionId++;
    final int currentId = _connectionId;

    _isReconnectingBackground = true;
    _backgroundMessage = "переподключение...";
    notifyListeners();

    final bleDevice = _deviceMap[_connectedDevice!.address];
    if (bleDevice == null) {
      _isReconnectingBackground = false;
      disconnect(isIntentional: true);
      return;
    }

    for (int i = 1; i <= 3; i++) {
      try {
        await Future.delayed(const Duration(milliseconds: 4000));

        if (currentId != _connectionId) {
          _isReconnectingBackground = false;
          notifyListeners();
          return;
        }
        _backgroundMessage = "переподключение... №$i";
        notifyListeners();

        await bleDevice.connect(
          license: License.free,
          autoConnect: false,
          mtu: null,
        ).timeout(const Duration(seconds: 10));

        if (currentId != _connectionId) {
          await bleDevice.disconnect();
          _isReconnectingBackground = false;
          notifyListeners();
          return;
        }

        List<BluetoothService> services;
        try {
          services = await bleDevice.discoverServices().timeout(
            const Duration(seconds: 10),
          );
        } catch (e) {
          await bleDevice.disconnect();
          continue;
        }

        BluetoothService? uartService;
        for (final service in services) {
          if (service.uuid == _uartServiceUuid) {
            uartService = service;
            break;
          }
        }

        if (uartService == null) {
          await bleDevice.disconnect();
          continue;
        }

        BluetoothCharacteristic? txChar;
        BluetoothCharacteristic? rxChar;

        for (final characteristic in uartService.characteristics) {
          if (characteristic.uuid == _uartTxCharacteristicUuid) {
            txChar = characteristic;
          } else if (characteristic.uuid == _uartRxCharacteristicUuid) {
            rxChar = characteristic;
          }
        }

        if (txChar == null || rxChar == null) {
          await bleDevice.disconnect();
          continue;
        }

        _txCharacteristic = txChar;
        _rxCharacteristic = rxChar;
        _connectedBleDevice = bleDevice;
        _isConnected = true;
        _isReconnectingBackground = false;
        await _setupListen();
        notifyListeners();
        return;
      } catch (e) {
        developer.log("переподключение аварийное №$i", name: "reBle");
        if (currentId != _connectionId) {
          _isReconnectingBackground = false;
          notifyListeners();
          return;
        }
        if (i == 3) {
          _isReconnectingBackground = false;
          await disconnect();
        }
      }
    }
  }

  void cancelConnection() {
    _connectionId++;
    _isConnecting = false;
    _isReconnectingBackground = false;
    disconnect();
    notifyListeners();
    developer.log("Подключение отменено пользователем", name: 'reBle');
  }

  Future<void> turnOffBluetooth() async {
    _isToggleOn = false;
    cancelConnection();
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
