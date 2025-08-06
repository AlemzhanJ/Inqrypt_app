import '../constants/security_constants.dart';
import '../constants/design_constants.dart';
import '../exceptions/app_exceptions.dart';
import '../localization/app_localizations.dart';

/// Утилиты для валидации данных в Inqrypt
class ValidationUtils {
  // Приватный конструктор для предотвращения создания экземпляров
  ValidationUtils._();

  /// Валидация текста для шифрования
  /// 
  /// [text] - текст для проверки
  /// [l10n] - локализация
  /// Возвращает true если текст валиден, иначе выбрасывает ValidationException
  static bool validateTextForEncryption(String text, AppLocalizations l10n) {
    if (text.isEmpty) {
      throw ValidationException(l10n.errorEmptyText);
    }

    if (text.length > DesignConstants.maxTextLength) {
      throw ValidationException(
        l10n.errorTextTooLong,
        'Максимальная длина: ${DesignConstants.maxTextLength} символов',
      );
    }

    if (text.length < DesignConstants.minTextLength) {
      throw ValidationException(
        'Текст слишком короткий',
        'Минимальная длина: ${DesignConstants.minTextLength} символ',
      );
    }

    return true;
  }

  /// Валидация QR-кода
  /// 
  /// [qrData] - данные QR-кода для проверки
  /// [l10n] - локализация
  /// Возвращает true если QR-код валиден, иначе выбрасывает ValidationException
  static bool validateQRCode(String qrData, AppLocalizations l10n) {
    if (qrData.isEmpty) {
      throw ValidationException(l10n.errorInvalidQR);
    }

    // Проверяем, что QR-код содержит зашифрованные данные Inqrypt
    if (!qrData.startsWith('INQRYPT:')) { // encryptedDataPrefix
      throw ValidationException(
        l10n.errorInvalidQR,
        'QR-код не содержит зашифрованные данные Inqrypt',
      );
    }

    return true;
  }

  /// Проверить, является ли содержимое Quill Delta пустым
  /// 
  /// [content] - содержимое в формате Quill Delta (Map с ключом 'ops')
  /// Возвращает true если содержимое пустое или содержит только пробелы
  static bool isQuillContentEmpty(Map<String, dynamic> content) {
    if (content.isEmpty) return true;
    
    // Проверяем, есть ли ключ 'ops' и является ли он списком
    if (!content.containsKey('ops') || content['ops'] is! List) {
      return true;
    }
    
    final ops = content['ops'] as List<dynamic>;
    if (ops.isEmpty) return true;
    
    // Проверяем, содержит ли Delta только пустые строки или пробелы
    String plainText = '';
    for (final op in ops) {
      if (op is Map<String, dynamic> && op.containsKey('insert')) {
        final insert = op['insert'];
        if (insert is String) {
          plainText += insert;
        }
      }
    }
    
    // Удаляем все пробелы, переносы строк и другие whitespace символы
    final trimmedText = plainText.trim();
    
    return trimmedText.isEmpty;
  }

  /// Валидация ключа
  /// 
  /// [key] - ключ для проверки
  /// Возвращает true если ключ валиден, иначе выбрасывает ValidationException
  static bool validateKey(List<int> key) {
    if (key.isEmpty) {
      throw const ValidationException(
        'Ключ не может быть пустым',
      );
    }

    if (key.length != SecurityConstants.keyGenerationLength) {
      throw ValidationException(
        'Неверная длина ключа',
        'Ожидается: ${SecurityConstants.keyGenerationLength} байт, получено: ${key.length}',
      );
    }

    return true;
  }

  /// Валидация длины текста
  /// 
  /// [text] - текст для проверки
  /// [maxLength] - максимальная длина (по умолчанию из констант)
  /// Возвращает true если длина валидна
  static bool validateTextLength(String text, [int? maxLength]) {
    final maxLen = maxLength ?? DesignConstants.maxTextLength;
    
    if (text.length > maxLen) {
      throw ValidationException(
        'Текст слишком длинный',
        'Максимальная длина: $maxLen символов',
      );
    }

    return true;
  }

  /// Проверка, что строка не пустая
  /// 
  /// [value] - строка для проверки
  /// [fieldName] - название поля для сообщения об ошибке
  /// Возвращает true если строка не пустая
  static bool validateNotEmpty(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw ValidationException(
        '$fieldName не может быть пустым',
      );
    }

    return true;
  }

  /// Валидация email (если понадобится в будущем)
  /// 
  /// [email] - email для проверки
  /// Возвращает true если email валиден
  static bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (!emailRegex.hasMatch(email)) {
      throw const ValidationException(
        'Неверный формат email',
      );
    }

    return true;
  }

  /// Валидация пароля (если понадобится в будущем)
  /// 
  /// [password] - пароль для проверки
  /// Возвращает true если пароль валиден
  static bool validatePassword(String password) {
    if (password.length < SecurityConstants.minPasswordLength) {
      throw ValidationException(
        'Пароль слишком короткий',
        'Минимальная длина: ${SecurityConstants.minPasswordLength} символов',
      );
    }

    if (password.length > SecurityConstants.maxPasswordLength) {
      throw ValidationException(
        'Пароль слишком длинный',
        'Максимальная длина: ${SecurityConstants.maxPasswordLength} символов',
      );
    }

    // Проверка на наличие цифр и букв
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    
    if (!hasDigits || !hasLetters) {
      throw const ValidationException(
        'Пароль должен содержать цифры и буквы',
      );
    }

    return true;
  }
} 