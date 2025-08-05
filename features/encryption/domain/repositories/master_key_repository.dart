import '../entities/master_key.dart';

/// Репозиторий для работы с мастер-ключом
abstract class MasterKeyRepository {
  /// Получить мастер-ключ
  Future<MasterKey?> getMasterKey();
  
  /// Создать мастер-ключ
  Future<MasterKey> createMasterKey();
  
  /// Обновить мастер-ключ
  Future<MasterKey> updateMasterKey(MasterKey masterKey);
  
  /// Удалить мастер-ключ
  Future<void> deleteMasterKey();
  
  /// Проверить, существует ли мастер-ключ
  Future<bool> hasMasterKey();
  
  /// Расшифровать мастер-ключ с помощью биометрии/PIN
  Future<String?> decryptMasterKey();
} 