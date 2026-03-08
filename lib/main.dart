// lib/main.dart
import 'package:flutter/material.dart';
import 'core/app_themes.dart';

import 'screens/main_screen.dart';

void main() {
  runApp(const RedriveApp());
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
