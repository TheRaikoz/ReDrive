import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent, // основной цвет палитры
      onPrimary: Colors.black,

      surface: AppColors.background, // Основной фон приложения
      surfaceContainer:
          AppColors.cardBg, // Фоновая плашка для карточек/контейнеров

      onSurface:
          AppColors.textMainColor, // Основной текст (заголовки, жирный текст)
      onSurfaceVariant: Color.fromARGB(
        44,
        122,
        114,
        114,
      ), // Второстепенный текст (подзаголовки, описания)

      outlineVariant: Color(0xFF404040), // Главные бордеры (текст-филды)
      outline: Colors.black, // Второстепенные разделители (Divider)
    ),

    // // --- АКЦЕНТЫ (Кнопки, выделения, FAB, активные иконки) ---
    //       primary: AppColors.neonGreen,
    //       onPrimary: Colors.black, // Каким цветом писать текст НА primary-кнопке?

    //       // Второстепенные акценты (например, FloatingActionButton или особые иконки)
    //       secondary: AppColors.neonGreen, // Можно продублировать primary, если палитра узкая
    //       onSecondary: Colors.black,

    //       // --- ФОНЫ (Экраны, карточки, диалоги) ---
    //       surface: AppColors.pitchBlack, // Основной фон приложения
    //       surfaceContainer: AppColors.darkGray, // Фоновая плашка для карточек/контейнеров

    //       // --- ТЕКСТЫ И ИКОНКИ (Что лежит поверх фонов) ---
    //       onSurface: AppColors.white, // Основной текст (заголовки, жирный текст)
    //       onSurfaceVariant: AppColors.textMuted, // Второстепенный текст (подзаголовки, описания)

    //       // --- ОБВОДКИ И РАЗДЕЛИТЕЛИ ---
    //       outline: AppColors.borderGray, // Главные бордеры (текст-филды)
    //       outlineVariant: Colors.black, // Второстепенные разделители (Divider)

    // splashColor: Colors.transparent,
    // highlightColor: Colors.transparent,
  );
}
