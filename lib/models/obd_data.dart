class ObdData {
  final int rpm;
  final int speed;
  final int engineTemp;
  final int cvtTemp;
  final double voltage;

  final int intakeAirTemp;
  final int engineOilTemp;
  final int ambientTemp;
  final double throttlePos;
  final double fuelLevel;
  final double engineLoad;
  final int intakeMap;
  final int barometricPressure;
  final double maf;
  final double controlModuleVoltage;
  final double timingAdvance;
  final double fuelRate;

  const ObdData({
    this.rpm = 0,
    this.speed = 0,
    this.engineTemp = 0,
    this.cvtTemp = 0,
    this.voltage = 0.0,
    this.intakeAirTemp = 0,
    this.engineOilTemp = 0,
    this.ambientTemp = 0,
    this.throttlePos = 0.0,
    this.fuelLevel = 0.0,
    this.engineLoad = 0.0,
    this.intakeMap = 0,
    this.barometricPressure = 0,
    this.maf = 0.0,
    this.controlModuleVoltage = 0.0,
    this.timingAdvance = 0.0,
    this.fuelRate = 0.0,
  });

  ObdData copyWith({
    int? rpm,
    int? speed,
    int? engineTemp,
    int? cvtTemp,
    double? voltage,
    int? intakeAirTemp,
    int? engineOilTemp,
    int? ambientTemp,
    double? throttlePos,
    double? fuelLevel,
    double? engineLoad,
    int? intakeMap,
    int? barometricPressure,
    double? maf,
    double? controlModuleVoltage,
    double? timingAdvance,
    double? fuelRate,
  }) {
    return ObdData(
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      engineTemp: engineTemp ?? this.engineTemp,
      cvtTemp: cvtTemp ?? this.cvtTemp,
      voltage: voltage ?? this.voltage,
      intakeAirTemp: intakeAirTemp ?? this.intakeAirTemp,
      engineOilTemp: engineOilTemp ?? this.engineOilTemp,
      ambientTemp: ambientTemp ?? this.ambientTemp,
      throttlePos: throttlePos ?? this.throttlePos,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      engineLoad: engineLoad ?? this.engineLoad,
      intakeMap: intakeMap ?? this.intakeMap,
      barometricPressure: barometricPressure ?? this.barometricPressure,
      maf: maf ?? this.maf,
      controlModuleVoltage: controlModuleVoltage ?? this.controlModuleVoltage,
      timingAdvance: timingAdvance ?? this.timingAdvance,
      fuelRate: fuelRate ?? this.fuelRate,
    );
  }

  @override
  String toString() {
    return 'ObdData(rpm: $rpm, speed: $speed, engineTemp: $engineTemp°C, '
        'cvtTemp: $cvtTemp°C, voltage: $voltage V, '
        'intakeAirTemp: $intakeAirTemp°C, engineOilTemp: $engineOilTemp°C, '
        'ambientTemp: $ambientTemp°C, throttlePos: $throttlePos%, '
        'fuelLevel: $fuelLevel%, engineLoad: $engineLoad%, '
        'intakeMap: $intakeMap kPa, baro: $barometricPressure kPa, '
        'maf: $maf g/s, controlVoltage: $controlModuleVoltage V, '
        'timingAdvance: $timingAdvance°, fuelRate: $fuelRate L/h)';
  }
}
