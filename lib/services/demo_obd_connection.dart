import 'dart:async';
import 'dart:math';
import 'obd_connection.dart';

class DemoObdConnection implements ObdConnection {
  final _controller = StreamController<String>.broadcast();
  final _random = Random();

  Timer? _timer;

  @override
  bool get isReconnecting => false;

  @override
  Stream<String> get incoming => _controller.stream;

  @override
  bool get isConnected => _timer != null;

  @override
  Future<void> connect() async {
    _timer?.cancel();

    /// первый раз отправляем
    /// чтобы не было так, что demo режим
    /// уже нажат, а отправляется с задержкой.
    final rpm = 700 + _random.nextInt(3300);
    final speed = _random.nextInt(280);
    final temp = 70 + _random.nextInt(40);

    final rpmRaw = rpm * 4;
    final a = (rpmRaw ~/ 256).toRadixString(16).padLeft(2, '0');
    final b = (rpmRaw % 256).toRadixString(16).padLeft(2, '0');

    _controller.add("41 0C $a $b");
    _controller.add("41 0D ${speed.toRadixString(16)}");
    _controller.add("41 05 ${(temp + 40).toRadixString(16)}");
    _controller.add("${(13.5 + _random.nextDouble()).toStringAsFixed(2)}V");

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final rpm = 700 + _random.nextInt(3300);
      final speed = _random.nextInt(280);
      final temp = 70 + _random.nextInt(40);

      final rpmRaw = rpm * 4;
      final a = (rpmRaw ~/ 256).toRadixString(16).padLeft(2, '0');
      final b = (rpmRaw % 256).toRadixString(16).padLeft(2, '0');

      _controller.add("41 0C $a $b");
      _controller.add("41 0D ${speed.toRadixString(16)}");
      _controller.add("41 05 ${(temp + 40).toRadixString(16)}");
      _controller.add("${(13.5 + _random.nextDouble()).toStringAsFixed(2)}V");
    });
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    _timer = null;
  }

  /// DONT IMPLENTS
  @override
  Future<void> send(String command) async {}
}
