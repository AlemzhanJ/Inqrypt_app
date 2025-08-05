import '../../../../core/exceptions/app_exceptions.dart';
import '../entities/encryption_key.dart';
import '../repositories/i_encryption_repository.dart';

/// Use case для получения информации о ключе
class GetKeyInfo {
  final IEncryptionRepository repository;

  const GetKeyInfo(this.repository);

  /// Выполнение получения информации
  Future<Map<String, dynamic>> call(EncryptionKey key) async {
    try {
      if (!key.isValid) {
        throw const KeyException('Ключ недействителен');
      }

      // Получение информации о ключе
      final info = await repository.getKeyInfo(key);
      
      return info;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw KeyException(
        'Не удалось получить информацию о ключе',
        e.toString(),
      );
    }
  }
} 