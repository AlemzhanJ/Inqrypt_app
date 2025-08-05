import '../../../../core/exceptions/app_exceptions.dart';
import '../repositories/i_encryption_repository.dart';

/// Use case для удаления ключа
class DeleteKey {
  final IEncryptionRepository repository;

  const DeleteKey(this.repository);

  /// Выполнение удаления ключа
  Future<bool> call() async {
    try {
      // Проверка существования ключа
      final exists = await repository.keyExists();
      if (!exists) {
        return false; // Ключ уже не существует
      }

      // Удаление ключа
      final deleted = await repository.deleteKey();
      
      return deleted;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw KeyException(
        'Не удалось удалить ключ',
        e.toString(),
      );
    }
  }
} 