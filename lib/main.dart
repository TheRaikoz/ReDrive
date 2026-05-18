// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/services/bluetooth_obd_connection.dart';
import 'package:redrive/services/ble_obd_connection.dart';
import 'providers/obd_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/ble_provider.dart';
import 'providers/connection_mode_provider.dart';
import 'providers/base_obd_transport_provider.dart';
import 'core/app_themes.dart';
import 'screens/root_screen.dart';
import 'widget/reconnection_banner.dart';

class ActiveConnectionProvider extends ChangeNotifier {
  final BluetoothProvider classic;
  final BleProvider ble;
  ConnectionMode _mode = ConnectionMode.classic;

  ActiveConnectionProvider(this.classic, this.ble);

  ConnectionMode get mode => _mode;
  bool get isClassic => _mode == ConnectionMode.classic;
  bool get isBle => _mode == ConnectionMode.ble;

  BaseObdTransportProvider get active =>
      _mode == ConnectionMode.classic ? classic : ble;

  void setMode(ConnectionMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    _mode = _mode == ConnectionMode.classic
        ? ConnectionMode.ble
        : ConnectionMode.classic;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => BleProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionModeProvider()),

        ProxyProvider3<ConnectionModeProvider, BluetoothProvider, BleProvider,
            ActiveConnectionProvider>(
          update: (_, modeProvider, classic, ble, __) {
            return ActiveConnectionProvider(classic, ble)
              .._mode = modeProvider.mode;
          },
        ),

        ProxyProvider<ActiveConnectionProvider, ObdProvider>(
          create: (context) => ObdProvider(
            BluetoothObdConnection(context.read<BluetoothProvider>()),
          ),
          update: (_, activeProvider, currentObdProvider) {
            final active = activeProvider.active;
            final newConnection = active is BluetoothProvider
                ? BluetoothObdConnection(active)
                : BleObdConnection(active as BleProvider);

            currentObdProvider!.updateConnection(newConnection);
            return currentObdProvider;
          },
        ),
      ],
      child: const RedriveApp(),
    ),
  );
}

class RedriveApp extends StatelessWidget {
  const RedriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redrive OBD2',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme,
      home: const RootScreen(),

      /// баннер при отключении адаптера elm'ки появляется, трактуя
      /// попытку переподключения к объекту
      builder: (context, child) {
        return Stack(
          children: [
            child!,

            Consumer3<BluetoothProvider, BleProvider, ObdProvider>(
              builder: (context, blueProvider, bleProvider, obdProvider, _) {
                final isBlueReconnecting =
                    blueProvider.isReconnectingBackground;
                final isBleReconnecting = bleProvider.isReconnectingBackground;

                final isObdRecovering =
                    obdProvider.isRealMode &&
                    obdProvider.state == ObdConnectionState.initializing;

                final showBanner =
                    isBlueReconnecting || isBleReconnecting || isObdRecovering;

                String message = "";
                if (isBlueReconnecting) {
                  message = blueProvider.backgroundMessage;
                } else if (isBleReconnecting) {
                  message = bleProvider.backgroundMessage;
                } else if (isObdRecovering) {
                  message = obdProvider.initMessage;
                }

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  top: showBanner
                      ? MediaQuery.of(context).padding.top + 10
                      : -100,
                  left: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showBanner ? 1.0 : 0.0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ReconnectionBanner(message: message),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
