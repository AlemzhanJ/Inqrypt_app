import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/localization/app_localizations.dart';
import '../entities/encryption_key.dart';
import '../repositories/i_encryption_repository.dart';

/// Use case для шифрования текста
class EncryptText {
  final IEncryptionRepository repository;

  const EncryptText(this.repository);

  /// Выполнение шифрования
  Future<String> call(String text, EncryptionKey key, AppLocalizations l10n) async {
    try {
      // Валидация входных данных
      ValidationUtils.validateTextForEncryption(text, l10n);
      
      if (!key.isValid) {
        throw const KeyException('Ключ недействителен');
      }

      // Шифрование текста
      final encryptedData = await repository.encryptText(text, key, l10n);
      
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
} 