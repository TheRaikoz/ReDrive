import 'dart:async';
import 'dart:math';
import '../models/obd_data.dart';

/// Независимый сервис-генератор случайных значений для демо-режима.
class DemoDataGenerator {
  Timer? _timer;
  final _random = Random();

  /// Запускает таймер и передает сгенерированные данные через onData
  void start(void Function(ObdData) onData) {
    stop(); // На всякий случай убиваем старый таймер

    // Отправляем первый пакет без задержки
    onData(_generateData());

    // Запускаем цикл каждые 500мс
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      onData(_generateData());
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  ObdData _generateData() {
    // Каждое значение генерируется абсолютно случайным образом в заданных рамках
    return ObdData(
      speed: _random.nextInt(300), // от 0 до 219 км/ч
      rpm: 800 + _random.nextInt(14000), // от 800 до 6799 об/мин
      engineTemp: 30 + _random.nextInt(80), // от 70 до 109 °C
      voltage: 13.0 + (_random.nextDouble() * 2.5), // от 13.0 до 14.5 V
    );
  }
}
