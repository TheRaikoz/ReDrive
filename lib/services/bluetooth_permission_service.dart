import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Запрос разрешений для Classic Bluetooth и BLE.
///
/// Для BLE на Android 12+ требуется BLUETOOTH_SCAN без флага neverForLocation,
/// т.к. BLE-сканирование может определять местоположение.
/// Этот флаг уже убран из AndroidManifest.xml.
Future<bool> requestBluetoothPermissions() async {
  if (!Platform.isAndroid) return true;

  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  final sdk = androidInfo.version.sdkInt;

  Map<Permission, PermissionStatus> statuses = {};

  if (sdk >= 31) {
    // Android 12+: BLUETOOTH_SCAN + BLUETOOTH_CONNECT
    // BLUETOOTH_SCAN без neverForLocation — покрывает и Classic, и BLE
    statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  } else if (sdk >= 29) {
    // Android 10–11
    statuses = await [Permission.location, Permission.bluetooth].request();
  } else {
    // Android 9 и ниже
    statuses = await [Permission.location].request();
  }

  final granted = statuses.values.every((s) => s.isGranted);
  return granted;
}
