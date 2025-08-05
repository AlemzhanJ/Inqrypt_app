import 'package:flutter/material.dart';

/// Цветовая схема приложения Inqrypt
class AppColors {
  // Приватный конструктор для предотвращения создания экземпляров
  AppColors._();

  // Основные цвета
  static const Color primary = Color(0xFF6750A4); // Фиолетовый
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);

  // Вторичные цвета
  static const Color secondary = Color(0xFF625B71);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color onSecondaryContainer = Color(0xFF1D192B);

  // Третичные цвета
  static const Color tertiary = Color(0xFF7D5260);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color onTertiaryContainer = Color(0xFF31111D);

  // Цвета ошибок
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // Цвета фона
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color onSurface = Color(0xFF1C1B1F);

  // Цвета поверхности
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Цвета тени
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);

  // Цвета для безопасности
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Цвета для QR-кодов
  static const Color qrCode = Color(0xFF000000);
  static const Color qrBackground = Color(0xFFFFFFFF);

  // Цвета для кнопок
  static const Color buttonPrimary = Color(0xFF6750A4);
  static const Color buttonSecondary = Color(0xFF625B71);
  static const Color buttonDanger = Color(0xFFBA1A1A);
  static const Color buttonSuccess = Color(0xFF4CAF50);

  // Цвета для текста
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textDisabled = Color(0xFF79747E);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Цвета для карточек
  static const Color cardBackground = Color(0xFFFFFBFE);
  static const Color cardBorder = Color(0xFFE7E0EC);
  static const Color cardShadowColor = Color(0x1A000000);

  // Цвета для инпутов
  static const Color inputBackground = Color(0xFFF7F2FA);
  static const Color inputBorder = Color(0xFFCAC4D0);
  static const Color inputFocused = Color(0xFF6750A4);
  static const Color inputError = Color(0xFFBA1A1A);

  // Цвета для загрузки
  static const Color loadingPrimary = Color(0xFF6750A4);
  static const Color loadingSecondary = Color(0xFFEADDFF);

  // Темная тема
  static const Color darkPrimary = Color(0xFFD0BCFF);
  static const Color darkOnPrimary = Color(0xFF381E72);
  static const Color darkPrimaryContainer = Color(0xFF4F378B);
  static const Color darkOnPrimaryContainer = Color(0xFFEADDFF);

  static const Color darkBackground = Color(0xFF1C1B1F);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkOnSurface = Color(0xFFE6E1E5);

  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
  static const Color darkOutlineVariant = Color(0xFF49454F);

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFFF7F2FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Тени
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
} 