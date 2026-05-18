import 'dart:async';
import 'dart:math';
import '../models/obd_data.dart';

class DemoDataGenerator {
  Timer? _timer;
  final _random = Random();

  void start(Function(ObdData) onData) {
    stop();

    onData(_generateData());

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      onData(_generateData());
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  ObdData _generateData() {
    return ObdData(
      speed: 30 + _random.nextInt(270),
      rpm: 800 + _random.nextInt(14000),
      engineTemp: 30 + _random.nextInt(80),
      cvtTemp: 40 + _random.nextInt(60),
      voltage: 13.0 + (_random.nextDouble() * 2.5),
      intakeAirTemp: 10 + _random.nextInt(40),
      engineOilTemp: 40 + _random.nextInt(60),
      ambientTemp: -5 + _random.nextInt(40),
      throttlePos: _random.nextDouble() * 100,
      fuelLevel: 20 + _random.nextDouble() * 80,
      engineLoad: 10 + _random.nextDouble() * 80,
      intakeMap: 30 + _random.nextInt(70),
      barometricPressure: 95 + _random.nextInt(15),
      maf: 2.0 + _random.nextDouble() * 18,
      controlModuleVoltage: 13.0 + (_random.nextDouble() * 2.5),
      timingAdvance: _random.nextDouble() * 40,
      fuelRate: 1.0 + _random.nextDouble() * 20,
    );
  }
}
