import '../../../../core/exceptions/app_exceptions.dart';
import '../entities/encryption_key.dart';
import '../repositories/i_encryption_repository.dart';

/// Use case для генерации нового ключа
class GenerateKey {
  final IEncryptionRepository repository;

  const GenerateKey(this.repository);

  /// Выполнение генерации ключа
  Future<EncryptionKey> call() async {
    try {
      // Генерация нового ключа
      final newKey = await repository.generateNewKey();
      
      // Сохранение ключа
      await repository.saveKey(newKey);
      
      return newKey;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw KeyException(
        'Не удалось сгенерировать ключ',
        e.toString(),
      );
    }
  }
} 