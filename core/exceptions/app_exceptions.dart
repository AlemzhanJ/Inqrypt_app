/// Базовое исключение приложения
class AppException implements Exception {
  final String message;
  final String? details;

  const AppException(this.message, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'AppException: $message\nDetails: $details';
    }
    return 'AppException: $message';
  }
}

/// Исключение шифрования
class EncryptionException extends AppException {
  const EncryptionException(super.message, [super.details]);
}

/// Исключение расшифровки
class DecryptionException extends AppException {
  const DecryptionException(super.message, [super.details]);
}

/// Исключение ключа
class KeyException extends AppException {
  const KeyException(super.message, [super.details]);
}

/// Исключение файла
class FileException extends AppException {
  const FileException(super.message, [super.details]);
}

/// Исключение QR кода
class QRException extends AppException {
  const QRException(super.message, [super.details]);
}

/// Исключение разрешений
class PermissionException extends AppException {
  const PermissionException(super.message, [super.details]);
}

/// Исключение валидации
class ValidationException extends AppException {
  const ValidationException(super.message, [super.details]);
}

/// Исключение сети
class NetworkException extends AppException {
  const NetworkException(super.message, [super.details]);
}

/// Неизвестное исключение
class UnknownException extends AppException {
  const UnknownException(super.message, [super.details]);
} 