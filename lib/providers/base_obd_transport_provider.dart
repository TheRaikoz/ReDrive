import 'package:flutter/foundation.dart';
import 'package:redrive/models/obd_device.dart';

abstract class BaseObdTransportProvider extends ChangeNotifier {
  bool get isScanning;
  bool get isConnected;
  bool get isConnecting;
  bool get isHardwareOn;
  bool get isToggleOn;
  bool get isReconnectingBackground;
  String get connectionMessage;
  String get backgroundMessage;
  List<ObdDevice> get discoveredDevices;
  ObdDevice? get connectedDevice;

  Future<bool> startScan();
  Future<bool> connectToDevice(ObdDevice device);
  Future<void> disconnect({bool isIntentional = true});
  void cancelConnection();
  void sendCommand(String command);
  Future<void> turnOffBluetooth();
}
