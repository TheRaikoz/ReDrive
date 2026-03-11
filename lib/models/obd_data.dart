class ObdData {
  final int rpm;
  final int speed;
  final int engineTemp;

  const ObdData({this.rpm = 0, this.speed = 0, this.engineTemp = 0});

  ObdData copyWith({int? rpm, int? speed, int? engineTemp}) {
    return ObdData(
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      engineTemp: engineTemp ?? this.engineTemp,
    );
  }

  @override
  String toString() {
    return 'ObdData(rpm: $rpm, speed: $speed km/h, temp: $engineTemp°C)';
  }
}
