import '../../domain/entities/master_key.dart';
import '../../domain/repositories/master_key_repository.dart';
import '../datasources/secure_master_key_storage.dart';

/// Реализация репозитория мастер-ключа
class MasterKeyRepositoryImpl implements MasterKeyRepository {
  final SecureMasterKeyStorage _storage;

  MasterKeyRepositoryImpl(this._storage);

  @override
  Future<MasterKey?> getMasterKey() async {
    return await _storage.getMasterKey();
  }

  @override
  Future<MasterKey> createMasterKey() async {
    return await _storage.createMasterKey();
  }

  @override
  Future<MasterKey> updateMasterKey(MasterKey masterKey) async {
    return await _storage.updateMasterKey(masterKey);
  }

  @override
  Future<void> deleteMasterKey() async {
    await _storage.deleteMasterKey();
  }

  @override
  Future<bool> hasMasterKey() async {
    return await _storage.hasMasterKey();
  }

  @override
  Future<String?> decryptMasterKey() async {
    return await _storage.decryptMasterKey();
  }
} 