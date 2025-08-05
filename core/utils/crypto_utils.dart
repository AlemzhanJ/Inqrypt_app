import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import '../constants/security_constants.dart';
import '../exceptions/app_exceptions.dart';
import 'validation_utils.dart';
import '../localization/app_localizations.dart';

/// Утилиты для криптографических операций в Inqrypt
class CryptoUtils {
  // Приватный конструктор для предотвращения создания экземпляров
  CryptoUtils._();

  /// Генерация криптографически стойкого ключа
  /// 
  /// Возвращает случайный ключ длиной 32 байта (256 бит)
  static List<int> generateSecureKey() {
    try {
      final random = Random.secure();
      final key = List<int>.generate(
        SecurityConstants.keyGenerationLength,
        (index) => random.nextInt(256),
      );
      
      ValidationUtils.validateKey(key);
      return key;
    } catch (e) {
      throw KeyException(
        'Не удалось сгенерировать ключ',
        e.toString(),
      );
    }
  }

  /// Генерация случайного IV (Initialization Vector)
  /// 
  /// Возвращает случайный IV длиной 16 байт (128 бит)
  static List<int> generateIV() {
    try {
      final random = Random.secure();
      return List<int>.generate(
        SecurityConstants.ivSize,
        (index) => random.nextInt(256),
      );
    } catch (e) {
      throw EncryptionException(
        'Не удалось сгенерировать IV',
        e.toString(),
      );
    }
  }

  /// Шифрование текста с использованием AES-256
  /// 
  /// [text] - текст для шифрования
  /// [key] - ключ шифрования (32 байта)
  /// [l10n] - локализация
  /// Возвращает зашифрованные данные в формате base64
  static String encryptText(String text, List<int> key, AppLocalizations l10n) {
    try {
      // Валидация входных данных
      ValidationUtils.validateTextForEncryption(text, l10n);
      ValidationUtils.validateKey(key);
      
      // Генерируем IV
      final iv = generateIV();
      
      // Создаем объект для шифрования
      final encrypter = Encrypter(
        AES(
          Key(Uint8List.fromList(key)),
          mode: AESMode.cbc,
          padding: 'PKCS7',
        ),
      );
      
      // Шифруем текст
      final encrypted = encrypter.encrypt(text, iv: IV(Uint8List.fromList(iv)));
      
      // Формируем результат в формате: INQRYPT:base64(iv)|base64(encrypted_data)
      final ivBase64 = base64Encode(iv);
      final dataBase64 = encrypted.base64;
      
      final result = '${SecurityConstants.encryptedDataPrefix}$ivBase64${SecurityConstants.dataSeparator}$dataBase64';
      
      return result;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw EncryptionException(
        'Не удалось зашифровать текст',
        e.toString(),
      );
    }
  }

  /// Расшифровка текста с использованием AES-256
  /// 
  /// [encryptedData] - зашифрованные данные в формате base64
  /// [key] - ключ дешифрования (32 байта)
  /// [l10n] - локализация
  /// Возвращает расшифрованный текст
  static String decryptText(String encryptedData, List<int> key, AppLocalizations l10n) {
    try {
      // Валидация входных данных
      ValidationUtils.validateQRCode(encryptedData, l10n);
      ValidationUtils.validateKey(key);
      
      // Убираем префикс INQRYPT:
      final dataWithoutPrefix = encryptedData.substring(SecurityConstants.encryptedDataPrefix.length);
      
      // Разделяем IV и зашифрованные данные
      final parts = dataWithoutPrefix.split(SecurityConstants.dataSeparator);
      if (parts.length != 2) {
        throw const DecryptionException(
          'Неверный формат зашифрованных данных',
        );
      }
      
      // Декодируем IV и данные
      final iv = base64Decode(parts[0]);
      base64Decode(parts[1]); // Проверяем, что данные можно декодировать
      
      // Создаем объект для дешифрования
      final encrypter = Encrypter(
        AES(
          Key(Uint8List.fromList(key)),
          mode: AESMode.cbc,
          padding: 'PKCS7',
        ),
      );
      
      // Дешифруем данные
      final decrypted = encrypter.decrypt64(
        parts[1],
        iv: IV(Uint8List.fromList(iv)),
      );
      
      return decrypted;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw DecryptionException(
        'Не удалось расшифровать текст',
        e.toString(),
      );
    }
  }

  /// Создание хеша ключа для отображения
  /// 
  /// [key] - ключ для хеширования
  /// Возвращает короткий хеш ключа (первые 8 символов)
  static String getKeyHash(List<int> key) {
    try {
      ValidationUtils.validateKey(key);
      
      final hash = sha256.convert(key);
      final hashString = hash.toString();
      
      // Возвращаем первые 8 символов хеша
      return hashString.substring(0, 8).toUpperCase();
    } catch (e) {
      throw KeyException(
        'Не удалось создать хеш ключа',
        e.toString(),
      );
    }
  }

  /// Проверка совместимости ключа
  /// 
  /// [key] - ключ для проверки
  /// Возвращает true если ключ совместим с текущей версией
  static bool isKeyCompatible(List<int> key) {
    try {
      ValidationUtils.validateKey(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Создание мастер-ключа из пароля (если понадобится в будущем)
  /// 
  /// [password] - пароль пользователя
  /// [salt] - соль для PBKDF2
  /// Возвращает производный ключ
  static List<int> deriveKeyFromPassword(String password, List<int> salt) {
    try {
      ValidationUtils.validatePassword(password);
      
      // Простая реализация PBKDF2 для демонстрации
      // В реальном приложении лучше использовать готовую библиотеку
      final key = Hmac(sha256, utf8.encode(password));
      final derivedKey = key.convert(salt);
      
      return derivedKey.bytes;
    } catch (e) {
      throw KeyException(
        'Не удалось создать ключ из пароля',
        e.toString(),
      );
    }
  }

  /// Генерация случайной соли
  /// 
  /// Возвращает случайную соль длиной 32 байта
  static List<int> generateSalt() {
    try {
      final random = Random.secure();
      return List<int>.generate(
        SecurityConstants.saltLength,
        (index) => random.nextInt(256),
      );
    } catch (e) {
      throw KeyException(
        'Не удалось сгенерировать соль',
        e.toString(),
      );
    }
  }

  /// Проверка целостности зашифрованных данных
  /// 
  /// [encryptedData] - зашифрованные данные
  /// Возвращает true если данные имеют правильный формат
  static bool validateEncryptedData(String encryptedData) {
    try {
      if (!encryptedData.startsWith(SecurityConstants.encryptedDataPrefix)) {
        return false;
      }
      
      final dataWithoutPrefix = encryptedData.substring(SecurityConstants.encryptedDataPrefix.length);
      final parts = dataWithoutPrefix.split(SecurityConstants.dataSeparator);
      
      if (parts.length != 2) {
        return false;
      }
      
      // Проверяем, что данные можно декодировать из base64
      base64Decode(parts[0]); // IV
      base64Decode(parts[1]); // Encrypted data
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Очистка данных из памяти
  /// 
  /// [data] - данные для очистки
  /// Заполняет массив нулями для предотвращения утечек памяти
  static void secureClear(List<int> data) {
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }

  /// Создание безопасной копии данных
  /// 
  /// [data] - данные для копирования
  /// Возвращает копию данных
  static List<int> secureCopy(List<int> data) {
    return List<int>.from(data);
  }
} 