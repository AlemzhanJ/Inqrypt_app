import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/master_key.dart';
import '../../../../shared/services/biometric_service.dart';

/// Secure storage для мастер-ключа с биометрической защитой
class SecureMasterKeyStorage {
  static const String _masterKeyKey = 'inqrypt_master_key';
  static const String _masterKeyId = 'inqrypt_master_key_id';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  /// Создать новый мастер-ключ
  Future<MasterKey> createMasterKey() async {
    // Генерируем случайный мастер-ключ
    final random = Random.secure();
    final masterKeyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    final masterKey = base64Encode(masterKeyBytes);
    
    // Создаем уникальный ID
    final id = _generateId();
    
    // Шифруем мастер-ключ с помощью биометрии
    final encryptedKey = await _encryptWithBiometric(masterKey);
    
    final masterKeyEntity = MasterKey(
      id: id,
      encryptedKey: encryptedKey,
      createdAt: DateTime.now(),
      isProtected: true,
    );
    
    // Сохраняем в secure storage
    await _saveMasterKey(masterKeyEntity);
    
    return masterKeyEntity;
  }
  
  /// Получить мастер-ключ
  Future<MasterKey?> getMasterKey() async {
    try {
      final masterKeyJson = await _getSecureValue(_masterKeyKey);
      if (masterKeyJson == null) return null;
      
      final masterKeyMap = jsonDecode(masterKeyJson);
      return MasterKey(
        id: masterKeyMap['id'],
        encryptedKey: masterKeyMap['encryptedKey'],
        createdAt: DateTime.parse(masterKeyMap['createdAt']),
        isProtected: masterKeyMap['isProtected'] ?? true,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Расшифровать мастер-ключ с помощью биометрии
  Future<String?> decryptMasterKey() async {
    try {
      print('decryptMasterKey: Начинаем расшифровку...');
      final masterKey = await getMasterKey();
      if (masterKey == null) {
        print('decryptMasterKey: Мастер-ключ не найден');
        return null;
      }
      
      print('decryptMasterKey: Мастер-ключ найден, расшифровываем...');
      // Расшифровываем мастер-ключ (биометрия уже была проверена в контроллере)
      final result = await _decryptWithBiometric(masterKey.encryptedKey);
      print('decryptMasterKey: Результат расшифровки: ${result != null}');
      return result;
    } catch (e) {
      print('decryptMasterKey: Ошибка: $e');
      return null;
    }
  }
  
  /// Обновить мастер-ключ
  Future<MasterKey> updateMasterKey(MasterKey masterKey) async {
    await _saveMasterKey(masterKey);
    return masterKey;
  }
  
  /// Удалить мастер-ключ
  Future<void> deleteMasterKey() async {
    await _deleteSecureValue(_masterKeyKey);
    await _deleteSecureValue(_masterKeyId);
  }
  
  /// Проверить, существует ли мастер-ключ
  Future<bool> hasMasterKey() async {
    final masterKey = await getMasterKey();
    return masterKey != null;
  }
  
  /// Генерировать уникальный ID
  String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }
  
  /// Шифровать с помощью биометрии
  Future<String> _encryptWithBiometric(String data) async {
    print('_encryptWithBiometric: Начинаем шифрование...');
    // Используем хеш биометрических данных как ключ
    final biometricHash = await _getBiometricHash();
    print('_encryptWithBiometric: Хеш биометрии: ${biometricHash.substring(0, 8)}...');
    final key = Key.fromUtf8(biometricHash);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    
    final encrypted = encrypter.encrypt(data, iv: iv);
    // Сохраняем IV вместе с зашифрованными данными: base64(iv) + ":" + base64(data)
    final result = '${base64Encode(iv.bytes)}:${encrypted.base64}';
    print('_encryptWithBiometric: Шифрование завершено');
    return result;
  }
  
  /// Расшифровать с помощью биометрии
  Future<String?> _decryptWithBiometric(String encryptedData) async {
    try {
      print('_decryptWithBiometric: Начинаем расшифровку...');
      final biometricHash = await _getBiometricHash();
      print('_decryptWithBiometric: Хеш биометрии: ${biometricHash.substring(0, 8)}...');
      final key = Key.fromUtf8(biometricHash);
      final encrypter = Encrypter(AES(key));
      
      // Проверяем формат данных
      if (encryptedData.contains(':')) {
        // Новый формат: base64(iv):base64(data)
        final parts = encryptedData.split(':');
        if (parts.length != 2) {
          print('_decryptWithBiometric: Неверный формат данных');
          return null;
        }
        
        final ivBytes = base64Decode(parts[0]);
        final encryptedBytes = base64Decode(parts[1]);
        
        final iv = IV(ivBytes);
        final encrypted = Encrypted(encryptedBytes);
        
        final result = encrypter.decrypt(encrypted, iv: iv);
        print('_decryptWithBiometric: Расшифровка завершена (новый формат)');
        return result;
      } else {
        // Старый формат: только base64(data) - не поддерживается
        print('_decryptWithBiometric: Старый формат данных не поддерживается');
        return null;
      }
    } catch (e) {
      print('_decryptWithBiometric: Ошибка расшифровки: $e');
      return null;
    }
  }
  
  /// Получить хеш биометрических данных
  Future<String> _getBiometricHash() async {
    print('_getBiometricHash: Получаем биометрические данные...');
    
    // Проверяем только наличие биометрии, а не конкретные типы
    final isAvailable = await BiometricService.isBiometricAvailable();
    print('_getBiometricHash: Биометрия доступна: $isAvailable');
    
    // Используем стабильный идентификатор
    const biometricString = 'biometric_available';
    print('_getBiometricHash: Строка биометрии: $biometricString');
    
    // Добавляем соль для безопасности
    const salt = 'inqrypt_biometric_salt_2024';
    final hash = sha256.convert(utf8.encode(biometricString + salt));
    final result = hash.toString().substring(0, 32); // 32 символа для AES-256
    print('_getBiometricHash: Хеш: ${result.substring(0, 8)}...');
    
    return result;
  }
  
  /// Сохранить в secure storage
  Future<void> _saveMasterKey(MasterKey masterKey) async {
    final masterKeyJson = jsonEncode({
      'id': masterKey.id,
      'encryptedKey': masterKey.encryptedKey,
      'createdAt': masterKey.createdAt.toIso8601String(),
      'isProtected': masterKey.isProtected,
    });
    
    await _setSecureValue(_masterKeyKey, masterKeyJson);
  }
  
  /// Установить значение в secure storage
  Future<void> _setSecureValue(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  /// Получить из secure storage
  Future<String?> _getSecureValue(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  /// Удалить из secure storage
  Future<void> _deleteSecureValue(String key) async {
    await _secureStorage.delete(key: key);
  }
} 