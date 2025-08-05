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
      print('MasterKeyController: Инициализация...');
      _masterKey = await _repository.getMasterKey();
      print('MasterKeyController: Мастер-ключ загружен: ${_masterKey != null}');
      notifyListeners();
    } catch (e) {
      print('MasterKeyController: Ошибка инициализации: $e');
    }
  }

  /// Создать мастер-ключ
  Future<bool> createMasterKey() async {
    _setLoading(true);
    try {
      print('Создаем мастер-ключ...');
      
      // Запрашиваем подтверждение через биометрию
      print('Запрашиваем биометрию для создания...');
      final isAuthenticated = await BiometricService.authenticate(
        reason: 'Подтвердите создание мастер-ключа',
      );
      
      if (!isAuthenticated) {
        print('Аутентификация не удалась');
        _setError('Аутентификация не удалась');
        return false;
      }

      // Создаем мастер-ключ
      print('Создаем мастер-ключ...');
      _masterKey = await _repository.createMasterKey();
      print('Мастер-ключ создан успешно!');
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка создания мастер-ключа: $e');
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
      print('Удаляем мастер-ключ...');
      
      // Запрашиваем подтверждение через биометрию
      print('Запрашиваем биометрию для удаления...');
      final isAuthenticated = await BiometricService.authenticate(
        reason: 'Подтвердите удаление мастер-ключа',
      );
      
      if (!isAuthenticated) {
        print('Аутентификация не удалась');
        _setError('Аутентификация не удалась');
        return false;
      }

      print('Удаляем мастер-ключ...');
      await _repository.deleteMasterKey();
      _masterKey = null;
      print('Мастер-ключ удален успешно!');
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      print('Ошибка удаления мастер-ключа: $e');
      _setError('Ошибка удаления. Попробуйте еще раз.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Получить расшифрованный мастер-ключ (только для внутреннего использования)
  Future<String?> getDecryptedMasterKey() async {
    try {
      print('Получаем расшифрованный мастер-ключ...');
      return await _repository.decryptMasterKey();
    } catch (e) {
      print('Ошибка получения мастер-ключа: $e');
      return null;
    }
  }

  /// Получить мастер-ключ с аутентификацией (для заметок)
  Future<String?> getMasterKeyWithAuth() async {
    try {
      print('Запрашиваем мастер-ключ с аутентификацией...');
      
      if (!hasMasterKey) {
        print('Мастер-ключ не создан');
        return null;
      }

      // Запрашиваем биометрию
      print('Запрашиваем биометрию для доступа к заметкам...');
      final isAuthenticated = await BiometricService.authenticate(
        reason: 'Подтвердите доступ к заметкам',
      );
      
      if (!isAuthenticated) {
        print('Аутентификация не удалась');
        return null;
      }

      // Получаем расшифрованный мастер-ключ
      final masterKey = await _repository.decryptMasterKey();
      print('Мастер-ключ получен: ${masterKey != null}');
      
      return masterKey;
    } catch (e) {
      print('Ошибка получения мастер-ключа с аутентификацией: $e');
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