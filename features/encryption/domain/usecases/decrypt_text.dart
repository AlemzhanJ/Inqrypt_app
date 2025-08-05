import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/localization/app_localizations.dart';
import '../entities/encryption_key.dart';
import '../repositories/i_encryption_repository.dart';

/// Use case для расшифровки текста
class DecryptText {
  final IEncryptionRepository repository;

  const DecryptText(this.repository);

  /// Выполнение расшифровки
  Future<String> call(String encryptedData, EncryptionKey key, AppLocalizations l10n) async {
    try {
      // Валидация входных данных
      ValidationUtils.validateQRCode(encryptedData, l10n);
      
      if (!key.isValid) {
        throw const KeyException('Ключ недействителен');
      }

      // Проверка валидности зашифрованных данных
      final isValid = await repository.validateEncryptedData(encryptedData);
      if (!isValid) {
        throw const DecryptionException('Неверный формат зашифрованных данных');
      }

      // Расшифровка текста
      final decryptedText = await repository.decryptText(encryptedData, key, l10n);
      
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
} 