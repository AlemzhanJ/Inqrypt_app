import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/crypto_utils.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/encryption_key.dart';
import '../../domain/repositories/i_encryption_repository.dart';
import '../datasources/local_key_storage.dart';

/// Репозиторий для работы с шифрованием
class EncryptionRepository implements IEncryptionRepository {
  final LocalKeyStorage _localStorage;

  const EncryptionRepository(this._localStorage);

  @override
  Future<EncryptionKey?> getCurrentKey() async {
    return await _localStorage.getCurrentKey();
  }

  @override
  Future<void> saveKey(EncryptionKey key) async {
    await _localStorage.saveKey(key);
  }

  @override
  Future<bool> deleteKey() async {
    return await _localStorage.deleteKey();
  }

  @override
  Future<bool> keyExists() async {
    return await _localStorage.keyExists();
  }

  @override
  Future<String> encryptText(String text, EncryptionKey key, AppLocalizations l10n) async {
    try {
      // Используем криптографические утилиты для шифрования
      final encryptedData = CryptoUtils.encryptText(text, key.keyData, l10n);
      return encryptedData;
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

  @override
  Future<String> decryptText(String encryptedData, EncryptionKey key, AppLocalizations l10n) async {
    try {
      // Используем криптографические утилиты для расшифровки
      final decryptedText = CryptoUtils.decryptText(encryptedData, key.keyData, l10n);
      return decryptedText;
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

  @override
  Future<EncryptionKey> generateNewKey() async {
    return await _localStorage.generateNewKey();
  }

  @override
  Future<bool> validateEncryptedData(String encryptedData) async {
    try {
      return CryptoUtils.validateEncryptedData(encryptedData);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getKeyInfo(EncryptionKey key) async {
    return await _localStorage.getKeyInfo(key);
  }
} 