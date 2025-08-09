import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Сервис для временного хранения ключей заметок в secure storage
class NoteKeyStorage {
  static const String _keyPrefix = 'note_key_';
  static const String _currentNoteKey = 'current_note_key';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  /// Сохранить ключ заметки для текущей сессии
  /// 
  /// [noteId] - ID заметки
  /// [noteKey] - расшифрованный ключ заметки
  static Future<void> saveNoteKey(String noteId, String noteKey) async {
    try {
      // Сохраняем ключ с привязкой к ID заметки
      await _storage.write(
        key: '$_keyPrefix$noteId',
        value: noteKey,
      );
      
      // Также сохраняем как текущий активный ключ
      await _storage.write(
        key: _currentNoteKey,
        value: noteKey,
      );
      
    } catch (e) {
      rethrow;
    }
  }
  
  /// Получить ключ заметки по ID
  /// 
  /// [noteId] - ID заметки
  /// Возвращает расшифрованный ключ заметки или null
  static Future<String?> getNoteKey(String noteId) async {
    try {
      final noteKey = await _storage.read(key: '$_keyPrefix$noteId');
      return noteKey;
    } catch (e) {
      return null;
    }
  }
  
  /// Получить текущий активный ключ заметки
  /// 
  /// Возвращает расшифрованный ключ текущей заметки или null
  static Future<String?> getCurrentNoteKey() async {
    try {
      final noteKey = await _storage.read(key: _currentNoteKey);
      return noteKey;
    } catch (e) {
      return null;
    }
  }
  
  /// Удалить ключ заметки по ID
  /// 
  /// [noteId] - ID заметки
  static Future<void> removeNoteKey(String noteId) async {
    try {
      await _storage.delete(key: '$_keyPrefix$noteId');
    } catch (e) {
      // Игнорируем ошибки при удалении ключей
      // Это не критично для работы приложения
    }
  }
  
  /// Удалить текущий активный ключ заметки
  static Future<void> removeCurrentNoteKey() async {
    try {
      await _storage.delete(key: _currentNoteKey);
    } catch (e) {
      // Игнорируем ошибки при удалении текущего ключа
      // Это не критично для работы приложения
    }
  }
  
  /// Очистить все ключи заметок
  /// 
  /// Удаляет все сохраненные ключи заметок из secure storage
  static Future<void> clearAllNoteKeys() async {
    try {
      // Получаем все ключи
      final allKeys = await _storage.readAll();
      
      // Удаляем все ключи, связанные с заметками
      for (final key in allKeys.keys) {
        if (key.startsWith(_keyPrefix) || key == _currentNoteKey) {
          await _storage.delete(key: key);
        }
      }
      
    } catch (e) {
      // Игнорируем ошибки при очистке ключей
      // Это не критично для работы приложения
    }
  }
  
  /// Проверить, есть ли сохраненный ключ для заметки
  /// 
  /// [noteId] - ID заметки
  /// Возвращает true, если ключ существует
  static Future<bool> hasNoteKey(String noteId) async {
    try {
      final noteKey = await _storage.read(key: '$_keyPrefix$noteId');
      return noteKey != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Проверить, есть ли текущий активный ключ заметки
  /// 
  /// Возвращает true, если текущий ключ существует
  static Future<bool> hasCurrentNoteKey() async {
    try {
      final noteKey = await _storage.read(key: _currentNoteKey);
      return noteKey != null;
    } catch (e) {
      return false;
    }
  }
} 