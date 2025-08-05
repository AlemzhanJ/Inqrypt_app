import '../repositories/master_key_repository.dart';
import '../entities/master_key.dart';

/// Use case для создания мастер-ключа
class CreateMasterKey {
  final MasterKeyRepository repository;

  CreateMasterKey(this.repository);

  /// Создать новый мастер-ключ
  Future<MasterKey> call() async {
    return await repository.createMasterKey();
  }
} 