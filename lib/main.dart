// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/obd_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'core/app_themes.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ObdProvider()),
        ChangeNotifierProvider(create: (context) => BluetoothProvider()),
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
    );
  }
}
