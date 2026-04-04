// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redrive/services/bluetooth_obd_connection.dart';
import 'providers/obd_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'core/app_themes.dart';
import 'screens/main_screen.dart';
import 'widget/reconnection_banner.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),

        ChangeNotifierProvider(
          create: (context) => ObdProvider(
            BluetoothObdConnection(context.read<BluetoothProvider>()),
          ),
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
      home: const MainScreen(),

      /// баннер при отключении адаптера elm'ки появляется, трактуя
      /// попытку переподключения к объекту
      builder: (context, child) {
        return Stack(
          children: [
            child!,

            Consumer<BluetoothProvider>(
              builder: (context, provider, _) {
                final isReconnecting = provider.isReconnectingBackground;
                final message = provider.backgroundMessage;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  top: isReconnecting
                      ? MediaQuery.of(context).padding.top + 10
                      : -100,
                  left: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isReconnecting ? 1.0 : 0.0,
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
