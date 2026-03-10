import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent, // основной цвет палитры
      surface: AppColors.background, // основной фон
      surfaceContainer: AppColors.cardBg, // фон карточек
      onSurface: AppColors.textMainColor, // цвет текста
      secondary:
          AppColors.accentIconsBottomBar, // основной цвет иконок bottom bar
    ),

    // splashColor: Colors.transparent,
    // highlightColor: Colors.transparent,
  );
}
