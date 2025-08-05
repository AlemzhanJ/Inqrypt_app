import '../entities/encryption_key.dart';
import '../../../../core/localization/app_localizations.dart';

/// Интерфейс репозитория для работы с шифрованием
abstract class IEncryptionRepository {
  /// Получение текущего ключа
  Future<EncryptionKey?> getCurrentKey();
  
  /// Сохранение ключа
  Future<void> saveKey(EncryptionKey key);
  
  /// Удаление ключа
  Future<bool> deleteKey();
  
  /// Проверка существования ключа
  Future<bool> keyExists();
  
  /// Шифрование текста
  Future<String> encryptText(String text, EncryptionKey key, AppLocalizations l10n);
  
  /// Расшифровка текста
  Future<String> decryptText(String encryptedData, EncryptionKey key, AppLocalizations l10n);
  
  /// Генерация нового ключа
  Future<EncryptionKey> generateNewKey();
  
  /// Валидация зашифрованных данных
  Future<bool> validateEncryptedData(String encryptedData);
  
  /// Получение информации о ключе
  Future<Map<String, dynamic>> getKeyInfo(EncryptionKey key);
} 