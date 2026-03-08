import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  static final darkTheme = ThemeData(
    useMaterial3: true,

    // Делаем тему тёмной (было закомментировано — теперь работает)
    // brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,

    // Правильный цветовой акцент + тёмная схема
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      // brightness: Brightness.dark,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: AppColors.vehicleValue,
      ),
      titleMedium: TextStyle(fontSize: 18, color: Colors.grey),
    ),

    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );
}
