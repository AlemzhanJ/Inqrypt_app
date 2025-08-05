import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../../domain/entities/encryption_key.dart';

/// Источник данных для локального хранения ключей
class LocalKeyStorage {
  /// Получение текущего ключа
  Future<EncryptionKey?> getCurrentKey() async {
    try {
      final keyData = await FileUtils.loadKey();
      if (keyData == null) {
        return null;
      }

      // Создаем ключ из сохраненных данных
      final key = EncryptionKey.create(keyData);
      return key;
    } catch (e) {
      throw FileException(
        'Не удалось загрузить ключ',
        e.toString(),
      );
    }
  }

  /// Сохранение ключа
  Future<void> saveKey(EncryptionKey key) async {
    try {
      await FileUtils.saveKey(key.keyData);
    } catch (e) {
      throw FileException(
        'Не удалось сохранить ключ',
        e.toString(),
      );
    }
  }

  /// Удаление ключа
  Future<bool> deleteKey() async {
    try {
      return await FileUtils.deleteKey();
    } catch (e) {
      throw FileException(
        'Не удалось удалить ключ',
        e.toString(),
      );
    }
  }

  /// Проверка существования ключа
  Future<bool> keyExists() async {
    try {
      return await FileUtils.keyExists();
    } catch (e) {
      return false;
    }
  }

  /// Генерация нового ключа
  Future<EncryptionKey> generateNewKey() async {
    try {
      final keyData = CryptoUtils.generateSecureKey();
      final key = EncryptionKey.create(keyData);
      return key;
    } catch (e) {
      throw KeyException(
        'Не удалось сгенерировать ключ',
        e.toString(),
      );
    }
  }

  /// Получение информации о ключе
  Future<Map<String, dynamic>> getKeyInfo(EncryptionKey key) async {
    try {
      final hash = CryptoUtils.getKeyHash(key.keyData);
      final size = key.size;
      final createdAt = key.createdAt;
      final isActive = key.isActive;

      return {
        'hash': hash,
        'size': size,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'algorithm': 'AES-256',
        'mode': 'CBC',
        'padding': 'PKCS7',
      };
    } catch (e) {
      throw KeyException(
        'Не удалось получить информацию о ключе',
        e.toString(),
      );
    }
  }
} 