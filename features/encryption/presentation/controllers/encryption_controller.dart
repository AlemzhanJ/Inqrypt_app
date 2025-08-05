import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/local_key_storage.dart';
import '../../domain/entities/encryption_key.dart';
import '../../domain/usecases/encrypt_text.dart';
import '../../domain/usecases/decrypt_text.dart';
import '../../domain/usecases/generate_key.dart';
import '../../domain/usecases/delete_key.dart';
import '../../domain/usecases/get_key_info.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/repositories/i_encryption_repository.dart';

/// Контроллер для страницы шифрования
class EncryptionController extends ChangeNotifier {
  // Use cases
  late final EncryptText _encryptText;
  late final DecryptText _decryptText;
  late final GenerateKey _generateKey;
  late final DeleteKey _deleteKey;
  late final GetKeyInfo _getKeyInfo;

  final IEncryptionRepository _repository;
  final AppLocalizations _l10n;

  // Состояние
  String _inputText = '';
  String _encryptedData = '';
  String _decryptedText = '';
  EncryptionKey? _currentKey;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _keyInfo;

  // Геттеры
  String get inputText => _inputText;
  String get encryptedData => _encryptedData;
  String get decryptedText => _decryptedText;
  EncryptionKey? get currentKey => _currentKey;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get keyInfo => _keyInfo;
  bool get hasKey => _currentKey != null && _currentKey!.isValid;

  /// Инициализация контроллера
  EncryptionController(this._repository, this._l10n) {
    _encryptText = EncryptText(_repository);
    _decryptText = DecryptText(_repository);
    _generateKey = GenerateKey(_repository);
    _deleteKey = DeleteKey(_repository);
    _getKeyInfo = GetKeyInfo(_repository);
    
    _initialize();
  }

  /// Инициализация
  Future<void> _initialize() async {
    try {
      _setLoading(true);
      await _loadCurrentKey();
    } catch (e) {
      _setError('Ошибка инициализации: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Загрузка текущего ключа
  Future<void> _loadCurrentKey() async {
    try {
      final key = await _getCurrentKey();
      _currentKey = key;
      
      if (key != null) {
        await _loadKeyInfo(key);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки ключа: ${e.toString()}');
    }
  }

  /// Получение текущего ключа
  Future<EncryptionKey?> _getCurrentKey() async {
    final localStorage = LocalKeyStorage();
    return await localStorage.getCurrentKey();
  }

  /// Загрузка информации о ключе
  Future<void> _loadKeyInfo(EncryptionKey key) async {
    try {
      _keyInfo = await _getKeyInfo(key);
      notifyListeners();
    } catch (e) {
      // Игнорируем ошибки загрузки информации о ключе
    }
  }

  /// Установка текста для шифрования
  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  /// Шифрование текста
  Future<void> encryptText() async {
    if (_currentKey == null) {
      _setError('Ключ не найден. Сгенерируйте новый ключ.');
      return;
    }

    if (_inputText.trim().isEmpty) {
      _setError('Введите текст для шифрования');
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      
      final encrypted = await _encryptText(_inputText, _currentKey!, _l10n);
      _encryptedData = encrypted;
      
      notifyListeners();
    } catch (e) {
      _setError('Ошибка шифрования: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Расшифровка текста
  Future<void> decryptText(String encryptedData) async {
    if (_currentKey == null) {
      _setError('Ключ не найден. Сгенерируйте новый ключ.');
      return;
    }

    if (encryptedData.trim().isEmpty) {
      _setError('Введите зашифрованные данные');
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      
      final decrypted = await _decryptText(encryptedData, _currentKey!, _l10n);
      _decryptedText = decrypted;
      
      notifyListeners();
    } catch (e) {
      _setError('Ошибка расшифровки: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Генерация нового ключа
  Future<void> generateNewKey() async {
    try {
      _setLoading(true);
      _clearError();
      
      final newKey = await _generateKey();
      _currentKey = newKey;
      
      await _loadKeyInfo(newKey);
      
      // Очищаем данные после смены ключа
      _clearData();
      
      notifyListeners();
    } catch (e) {
      _setError('Ошибка генерации ключа: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Удаление ключа
  Future<void> deleteKey() async {
    try {
      _setLoading(true);
      _clearError();
      
      final deleted = await _deleteKey();
      
      if (deleted) {
        _currentKey = null;
        _keyInfo = null;
        _clearData();
        notifyListeners();
      }
    } catch (e) {
      _setError('Ошибка удаления ключа: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Очистка данных
  void _clearData() {
    _inputText = '';
    _encryptedData = '';
    _decryptedText = '';
    notifyListeners();
  }

  /// Установка состояния загрузки
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Установка ошибки
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Очистка ошибки
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Обновление состояния
  Future<void> refresh() async {
    await _initialize();
  }
} 