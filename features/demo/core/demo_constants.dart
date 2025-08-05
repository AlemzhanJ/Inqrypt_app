/// Константы для демо-режима приложения
/// Изолированы от основной логики приложения
class DemoConstants {
  // Приватный конструктор для предотвращения создания экземпляров
  DemoConstants._();
  
  /// Демо QR-код для App Review
  static const String demoQRCode = 'DEMO_QR_CODE_INQRYPT_2024';
  
  /// Цвет демо-кнопки (основной синий)
  static const int demoButtonColor = 0xFF007AFF;
  
  /// Цвета для демо-кнопки в стиле кнопки удаления
  static const int demoButtonBackgroundColor = 0xFF007AFF; // Синий фон
  static const int demoButtonBorderColor = 0xFF007AFF; // Синий контур
  static const int demoButtonIconColor = 0xFF007AFF; // Синяя иконка
  static const int demoButtonTextColor = 0xFF007AFF; // Синий текст
  
  /// Задержки для анимаций (в миллисекундах)
  static const int scannerInitDelay = 2000;
  static const int scanningDelay = 3000;
  static const int foundAnimationDelay = 2000;
  
  /// Размеры для QR-кода и сканера
  static const double qrCodeSize = 200.0;
  static const double scannerFrameSize = 250.0;
  static const double cornerMarkerSize = 30.0;
} 