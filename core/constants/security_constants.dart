/// Константы безопасности для Inqrypt
class SecurityConstants {
  // Приватный конструктор для предотвращения создания экземпляров
  SecurityConstants._();

  // Алгоритмы шифрования
  static const String encryptionAlgorithm = 'AES';
  static const String encryptionMode = 'CBC';
  static const String padding = 'PKCS7';
  
  // Размеры ключей
  static const int keySize = 256; // AES-256
  static const int ivSize = 16; // 128 бит для IV
  
  // Настройки безопасности
  static const int saltLength = 32; // Длина соли для PBKDF2
  static const int iterations = 100000; // Количество итераций PBKDF2
  
  // Форматы данных
  static const String encryptedDataPrefix = 'INQRYPT:';
  static const String dataSeparator = '|';
  
  // Ограничения безопасности
  static const int maxKeyAttempts = 3; // Максимальное количество попыток расшифровки
  static const Duration keyLockoutDuration = Duration(minutes: 5); // Блокировка после неудачных попыток
  
  // Сообщения безопасности
  static const String securityWarning = '⚠️ Внимание: При удалении ключа все зашифрованные данные станут недоступны';
  static const String keyBackupWarning = '🔐 Рекомендуется сохранить ключ в безопасном месте';
  static const String noDataStored = '✅ Данные не сохраняются на устройстве';
  
  // Хеш-алгоритмы
  static const String hashAlgorithm = 'SHA-256';
  
  // Настройки генерации ключей
  static const int keyGenerationLength = 32; // Длина генерируемого ключа в байтах
  static const bool useSecureRandom = true; // Использовать криптографически стойкий генератор
  
  // Валидация
  static const int minPasswordLength = 8; // Минимальная длина пароля (если будет добавлен)
  static const int maxPasswordLength = 128; // Максимальная длина пароля
  
  // Логирование (только для отладки)
  static const bool enableSecurityLogging = false; // Отключено для безопасности
  static const String logPrefix = '[SECURITY]';
} 