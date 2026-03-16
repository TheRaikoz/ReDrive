import 'package:flutter/foundation.dart';
import '../models/obd_device.dart';
import '../services/obd_connection.dart';

class BluetoothProvider extends ChangeNotifier {
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // адресс на текущий момент подключенного устройства, null // device
  ObdDevice? _connectedDevice;
  ObdDevice? get connectedDevice => _connectedDevice;

  // список из подключенных устройств
  List<ObdDevice> _discoveredDevices = [];
  List<ObdDevice> get discoveredDevices => _discoveredDevices;

  ObdConnection? _connection;

  Future<void> startScan() async {
    if (_isScanning) return;

    _isScanning = true;
    _discoveredDevices.clear();
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _discoveredDevices = [
      const ObdDevice(
        name: "OBDII",
        address: "00:11:22:33:44:55",
        isBle: false,
      ),
      const ObdDevice(
        name: "Vgate iCar Pro",
        address: "AA:BB:CC:DD:EE:FF",
        isBle: true,
      ),
      const ObdDevice(
        name: "Vgate iCar Pro2",
        address: "AA:BB:CC:DD:EE:FF",
        isBle: true,
      ),
      const ObdDevice(
        name: "Vgate iCar Pro3",
        address: "AA:BB:CC:DD:EE:FF",
        isBle: true,
      ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro4",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro5",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro6",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro7",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro8",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro9",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro10",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro11",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
      // const ObdDevice(
      //   name: "Vgate iCar Pro12",
      //   address: "AA:BB:CC:DD:EE:FF",
      //   isBle: true,
      // ),
    ];

    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(ObdDevice device) async {
    _isScanning = false;
    notifyListeners();

    // Позже здесь будет логика:
    // if (device.isBle) _connection = BleService(); else _connection = ClassicService();
    // await _connection!.connect(device.address);

    _isConnected = true;
    _connectedDevice = device;
    notifyListeners();
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _connectedDevice = null;
    notifyListeners();
  }
}
