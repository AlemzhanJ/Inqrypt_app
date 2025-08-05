/// Константы приложения Inqrypt
class AppConstants {
  // Приватный конструктор для предотвращения создания экземпляров
  AppConstants._();

  // Название приложения
  static const String appName = 'Inqrypt';
  
  // Версия приложения
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  
  // Размеры и ограничения
  static const int maxTextLength = 10000; // Максимальная длина текста для шифрования
  static const int minTextLength = 1; // Минимальная длина текста
  static const int qrCodeSize = 300; // Размер QR-кода в пикселях
  
  // Таймауты
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration autoHideDuration = Duration(seconds: 3);
  
  // Файлы
  static const String keyFileName = 'inqrypt_key.dat';
  static const String qrFileName = 'inqrypt_qr_';
  
  // Настройки Material 3
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
} 