import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/obd_data.dart';

class ObdProvider extends ChangeNotifier {
  ObdData _data = const ObdData();
  ObdData get data => _data;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  Timer? _demoTimer;
  final _random = Random();

  void toggleDemoMode() {
    _isDemoMode = !_isDemoMode;

    if (_isDemoMode) {
      _startDemo();
    } else {
      _stopDemo();
    }

    notifyListeners();
  }

  void _startDemo() {
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final randomRpm = 700 + _random.nextInt(3301); // 700..4000
      final randomSpeed = _random.nextInt(281); // 0..280
      final randomTemp = 70 + _random.nextInt(41); // 70..110
      final randomVoltage = 13.5 + _random.nextDouble();

      _data = _data.copyWith(
        rpm: randomRpm,
        speed: randomSpeed,
        engineTemp: randomTemp,
        voltage: randomVoltage,
      );

      notifyListeners();
    });
  }

  void _stopDemo() {
    _demoTimer?.cancel();
    _demoTimer = null;

    _data = const ObdData(rpm: 0, speed: 0, engineTemp: 0, voltage: 0);
    notifyListeners();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }
}
