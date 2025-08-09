import 'package:flutter/foundation.dart';
import '../../domain/repositories/master_key_repository.dart';
import '../../domain/entities/master_key.dart';
import '../../../../shared/services/biometric_service.dart';

/// Контроллер для работы с мастер-ключом
class MasterKeyController extends ChangeNotifier {
  final MasterKeyRepository _repository;
  
  MasterKey? _masterKey;
  bool _isLoading = false;
  String? _error;

  MasterKeyController(this._repository);

  // Геттеры
  MasterKey? get masterKey => _masterKey;
  bool get hasMasterKey => _masterKey != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Инициализация контроллера
  Future<void> initialize() async {
    try {
      _masterKey = await _repository.getMasterKey();
      notifyListeners();
    } catch (e) {
      // Игнорируем ошибки при инициализации
      // Мастер-ключ может не существовать при первом запуске
    }
  }

  /// Создать мастер-ключ
  Future<bool> createMasterKey() async {
    _setLoading(true);
    try {
      
      // Запрашиваем подтверждение через биометрию
      final isAuthenticated = await BiometricService.authenticate(
        reason: 'Подтвердите создание мастер-ключа',
      );
      
      if (!isAuthenticated) {
        _setError('Аутентификация не удалась');
        return false;
      }

      // Создаем мастер-ключ
      _masterKey = await _repository.createMasterKey();
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка создания мастер-ключа. Попробуйте еще раз.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Удалить мастер-ключ
  Future<bool> deleteMasterKey() async {
    _setLoading(true);
    try {
      
      // Запрашиваем подтверждение через биометрию
      final isAuthenticated = await BiometricService.authenticate(
        reason: 'Подтвердите удаление мастер-ключа',
      );
      
      if (!isAuthenticated) {
        _setError('Аутентификация не удалась');
        return false;
      }

      await _repository.deleteMasterKey();
      _masterKey = null;
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка удаления. Попробуйте еще раз.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Получить расшифрованный мастер-ключ (только для внутреннего использования)
  Future<String?> getDecryptedMasterKey() async {
    try {
      return await _repository.decryptMasterKey();
    } catch (e) {
      return null;
    }
  }

  /// Получить мастер-ключ с аутентификацией (для заметок)
  Future<String?> getMasterKeyWithAuth() async {
    try {
      
      if (!hasMasterKey) {
        return null;
      }

      // Запрашиваем биометрию
      final isAuthenticated = await BiometricService.authenticate(
        reason: 'Подтвердите доступ к заметкам',
      );
      
      if (!isAuthenticated) {
        return null;
      }

      // Получаем расшифрованный мастер-ключ
      final masterKey = await _repository.decryptMasterKey();
      
      return masterKey;
    } catch (e) {
      return null;
    }
  }

  // Приватные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 