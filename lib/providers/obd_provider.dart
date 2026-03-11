import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart'; // Отсюда берем ChangeNotifier
import '../models/obd_data.dart'; // Импортируем нашу модель

// ChangeNotifier - это аналог ViewModel. Он умеет оповещать UI об изменениях.
class ObdProvider extends ChangeNotifier {
  // 1. НАШЕ СОСТОЯНИЕ (аналог StateFlow)
  ObdData _data = const ObdData();
  ObdData get data =>
      _data; // Геттер, чтобы UI мог только читать данные, но не менять их напрямую

  // 2. СТАТУС ДЕМО-РЕЖИМА
  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  Timer? _demoTimer; // Аналог корутины (Job) из Kotlin
  final Random _random = Random();

  // 3. УПРАВЛЕНИЕ ДЕМО-РЕЖИМОМ
  void toggleDemoMode() {
    _isDemoMode = !_isDemoMode;

    if (_isDemoMode) {
      _startDemo();
    } else {
      _stopDemo();
    }

    // ВАЖНО: Сообщаем экрану, что статус изменился (чтобы переключатель Demo сменил цвет)
    notifyListeners();
  }

  void _startDemo() {
    // Timer.periodic - это идеальная замена твоему viewModelScope.launch { while(isActive) { delay(1000) ... } }
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final randomRpm = 700 + _random.nextInt(3301); // 700..4000
      final randomSpeed = _random.nextInt(281); // 0..280
      final randomTemp = 70 + _random.nextInt(41); // 70..110

      // ВОТ ОН, COPYWITH В ДЕЙСТВИИ!
      // Мы не трогаем старый объект, мы создаем новый с новыми цифрами.
      _data = _data.copyWith(
        rpm: randomRpm,
        speed: randomSpeed,
        engineTemp: randomTemp,
      );

      // КРИЧИМ ЭКРАНАМ: "Данные обновились, срочно перерисуйте спидометры!"
      notifyListeners();
    });
  }

  void _stopDemo() {
    _demoTimer?.cancel();
    _demoTimer = null;

    // Сбрасываем данные в нули при выключении
    _data = const ObdData(rpm: 0, speed: 0, engineTemp: 0);
    notifyListeners();
  }

  // Очистка памяти при уничтожении провайдера (аналог onCleared в ViewModel)
  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }
}
