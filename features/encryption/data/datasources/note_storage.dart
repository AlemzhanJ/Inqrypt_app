import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_image.dart';
import '../../../../shared/services/image_service.dart';

/// Storage для заметок с иерархическим шифрованием
class NoteStorage {
  static const String _notesDir = 'notes';
  static const String _magicSignature = '[MAGIC]::';
  final ImageService _imageService = ImageService();
  
  /// Получить директорию для заметок
  Future<Directory> _getNotesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/$_notesDir');
    
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }
    
    return notesDir;
  }
  
  /// Получить следующий порядковый номер заметки
  Future<int> _getNextSequence() async {
    final notesDir = await _getNotesDirectory();
    final files = notesDir.listSync().whereType<File>();
    int maxSeq = 0;
    for (final file in files) {
      try {
        final noteJson = await file.readAsString();
        final noteMap = jsonDecode(noteJson) as Map<String, dynamic>;
        final seq = (noteMap['sequence'] as int?) ?? 0;
        if (seq > maxSeq) maxSeq = seq;
      } catch (_) {
        // Игнорируем поврежденные/несовместимые файлы
        continue;
      }
    }
    return maxSeq + 1;
  }
  
  /// Создать новую заметку
  Future<(Note, String)> createNote(Map<String, dynamic> content, String masterKey, {List<NoteImage> images = const []}) async {
    
    // Генерируем уникальный ключ для заметки
    final noteKey = _generateNoteKey();
    
    // Конвертируем JSON Delta в строку для шифрования
    final contentString = jsonEncode(content);
    
    // Добавляем сигнатуру для проверки расшифровки
    final contentWithSignature = '$_magicSignature$contentString';
    
    // Шифруем содержимое заметки ключом заметки
    final encryptedContent = _encryptContent(contentWithSignature, noteKey);
    
    // Шифруем ключ заметки мастер-ключом
    final encryptedNoteKey = _encryptNoteKey(noteKey, masterKey);
    
    // Обрабатываем изображения
    List<NoteImage> processedImages = [];
    Map<String, dynamic> updatedContent = content;
    
    if (images.isNotEmpty) {
      for (final image in images) {
        final tempFile = File(image.imagePath);
        if (await tempFile.exists()) {
          // Перешифровываем изображение с правильным ключом заметки
          final newEncryptedPath = await _imageService.encryptImage(tempFile, noteKey);
          if (newEncryptedPath != null) {
            processedImages.add(image.copyWith(
              imagePath: newEncryptedPath,
              isEncrypted: true, // Помечаем как зашифрованное
            ));
            
            // Обновляем ссылку на изображение в JSON Delta
            // TODO: Обновить логику для работы с изображениями в Quill Delta
            // Пока оставляем как есть, позже обновим для интеграции с Quill
            
            // Удаляем временный файл
            await tempFile.delete();
          }
        }
      }
    }
    
    // Вычисляем порядковый номер
    final nextSequence = await _getNextSequence();
    
    // Создаем заметку
    final note = Note(
      id: _generateId(),
      content: updatedContent,
      sequence: nextSequence,
      encryptedContent: encryptedContent,
      images: processedImages,
    );
    
    
    // Сохраняем заметку
    await _saveNote(note);
    
    return (note, encryptedNoteKey);
  }
  
  /// Получить все заметки
  Future<List<Note>> getAllNotes() async {
    final notesDir = await _getNotesDirectory();
    final files = notesDir.listSync().whereType<File>();
    final notes = <Note>[];
    
    for (final file in files) {
      try {
        final noteJson = await file.readAsString();
        final noteMap = jsonDecode(noteJson);
        
        // Парсим изображения
        List<NoteImage> images = [];
        if (noteMap['images'] != null) {
          final imagesList = noteMap['images'] as List;
          images = imagesList.map((imgMap) => NoteImage.fromJson(imgMap)).toList();
        }
        
        notes.add(Note(
          id: noteMap['id'],
          content: {}, // Пустой контент - содержимое загружается только при расшифровке
          sequence: noteMap['sequence'] as int,
          encryptedContent: noteMap['encryptedContent'],
          images: images,
        ));
      } catch (e) {
        // Пропускаем поврежденные файлы
        continue;
      }
    }
    
    return notes;
  }
  
  /// Найти заметку по зашифрованному ключу
  Future<(Note?, String?)> findNoteByEncryptedKey(String encryptedNoteKey, String masterKey) async {
    
    // Сначала расшифровываем ключ из QR мастер-ключом
    final decryptedNoteKey = _decryptNoteKey(encryptedNoteKey, masterKey);
    if (decryptedNoteKey == null) {
      return (null, null);
    }
    
    final notes = await getAllNotes();
    
    for (final note in notes) {
      try {
        
        // Расшифровываем содержимое заметки ключом из QR
        final decryptedContent = _decryptContent(note.encryptedContent, decryptedNoteKey);
        if (decryptedContent == null) {
          continue;
        }
        
        
        // Проверяем сигнатуру
        if (decryptedContent.startsWith(_magicSignature)) {
          final contentString = decryptedContent.substring(_magicSignature.length);
          final content = jsonDecode(contentString) as Map<String, dynamic>;
          return (note.copyWith(content: content), decryptedNoteKey);
        } else {
        }
      } catch (e) {
        // Продолжаем поиск
        continue;
      }
    }
    
    return (null, null);
  }
  
  /// Обновить заметку
  Future<(Note, String)> updateNote(Note note, String masterKey, {String? existingNoteKey}) async {
    // Используем существующий ключ или генерируем новый
    final noteKey = existingNoteKey ?? _generateNoteKey();
    
    // Конвертируем JSON Delta в строку для шифрования
    final contentString = jsonEncode(note.content);
    
    // Добавляем сигнатуру
    final contentWithSignature = '$_magicSignature$contentString';
    
    // Шифруем содержимое
    final encryptedContent = _encryptContent(contentWithSignature, noteKey);
    
    // Шифруем ключ заметки
    final encryptedNoteKey = _encryptNoteKey(noteKey, masterKey);
    
    // Обрабатываем изображения
    List<NoteImage> processedImages = [];
    Map<String, dynamic> updatedContent = note.content;
    
    // Список старых путей к файлам для последующей очистки
    List<String> oldImagePaths = [];
    
    if (note.images.isNotEmpty) {
      for (final image in note.images) {
        final imageFile = File(image.imagePath);
        if (await imageFile.exists()) {
          String? newEncryptedPath;
          
          if (image.isEncrypted) {
            // Изображение уже зашифровано - нужно расшифровать и перешифровать
            
            // Расшифровываем изображение со старым ключом
            final decryptedBytes = await _imageService.decryptImage(image.imagePath, existingNoteKey ?? noteKey);
            if (decryptedBytes != null) {
              // Создаем временный файл с расшифрованными данными
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/temp_${image.id}.jpg');
              await tempFile.writeAsBytes(decryptedBytes);
              
              // Перешифровываем с новым ключом
              newEncryptedPath = await _imageService.encryptImage(tempFile, noteKey);
              
              // Удаляем временный файл
              await tempFile.delete();
            } else {
            }
          } else {
            // Изображение не зашифровано - шифруем как обычно
            newEncryptedPath = await _imageService.encryptImage(imageFile, noteKey);
          }
          
          if (newEncryptedPath != null) {
            processedImages.add(image.copyWith(
              imagePath: newEncryptedPath,
              isEncrypted: true, // Помечаем как зашифрованное
            ));
            
            // Добавляем старый путь для последующей очистки
            if (image.imagePath != newEncryptedPath) {
              oldImagePaths.add(image.imagePath);
            }
          } else {
            // Добавляем изображение без изменений, если не удалось перешифровать
            processedImages.add(image);
          }
        } else {
          // Добавляем изображение без изменений, если файл не найден
          processedImages.add(image);
        }
      }
    }
    
    // Обновляем заметку с обновленным контентом
    final updatedNote = note.copyWith(
      content: updatedContent,
      encryptedContent: encryptedContent,
      // Не обновляем modifiedAt: по требованиям безопасности/приватности время редактирования не хранится
      images: processedImages,
    );
    
    // Сохраняем заметку
    await _saveNote(updatedNote);
    
    // Очищаем старые файлы изображений только после успешного сохранения
    for (final oldPath in oldImagePaths) {
      try {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        // Игнорируем ошибки при удалении старых изображений
        // Это не критично для работы приложения
      }
    }
    
    return (updatedNote, encryptedNoteKey);
  }
  
  /// Удалить заметку
  Future<void> deleteNote(String id) async {
    final notesDir = await _getNotesDirectory();
    final file = File('${notesDir.path}/$id.json');
    
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  /// Сохранить заметку в файл
  Future<void> _saveNote(Note note) async {
    final notesDir = await _getNotesDirectory();
    final file = File('${notesDir.path}/${note.id}.json');
    
    // Преобразуем изображения в JSON
    final imagesJson = note.images.map((img) => img.toJson()).toList();
    
    final noteJson = jsonEncode({
      'id': note.id,
      // 'content': note.content, // УДАЛЕНО: содержимое не должно храниться в открытом виде
      'sequence': note.sequence,
      // Не храним 'modifiedAt' умышленно: время редактирования не должно сохраняться
      'encryptedContent': note.encryptedContent,
      'images': imagesJson,
    });
    
    await file.writeAsString(noteJson);
  }
  
  /// Генерировать уникальный ключ для заметки
  String _generateNoteKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }
  
  /// Генерировать уникальный ID
  String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }
  
  /// Шифровать содержимое заметки
  String _encryptContent(String content, String key) {
    final keyBytes = utf8.encode(key);
    final keyHash = sha256.convert(keyBytes);
    final encryptionKey = Key.fromUtf8(keyHash.toString().substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(encryptionKey));
    
    final encrypted = encrypter.encrypt(content, iv: iv);
    // Сохраняем IV вместе с зашифрованными данными: base64(iv) + ":" + base64(data)
    return '${base64Encode(iv.bytes)}:${encrypted.base64}';
  }
  
  /// Расшифровать содержимое заметки
  String? _decryptContent(String encryptedContent, String key) {
    try {
      final keyBytes = utf8.encode(key);
      final keyHash = sha256.convert(keyBytes);
      final encryptionKey = Key.fromUtf8(keyHash.toString().substring(0, 32));
      final encrypter = Encrypter(AES(encryptionKey));
      
      // Проверяем формат данных
      if (encryptedContent.contains(':')) {
        // Новый формат: base64(iv):base64(data)
        final parts = encryptedContent.split(':');
        if (parts.length != 2) {
          return null;
        }
        
        final ivBytes = base64Decode(parts[0]);
        final encryptedBytes = base64Decode(parts[1]);
        
        final iv = IV(ivBytes);
        final encrypted = Encrypted(encryptedBytes);
        
        return encrypter.decrypt(encrypted, iv: iv);
      } else {
        // Старый формат: только base64(data) - не поддерживается
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  /// Шифровать ключ заметки мастер-ключом
  String _encryptNoteKey(String noteKey, String masterKey) {
    final masterKeyBytes = utf8.encode(masterKey);
    final masterKeyHash = sha256.convert(masterKeyBytes);
    final encryptionKey = Key.fromUtf8(masterKeyHash.toString().substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(encryptionKey));
    
    final encrypted = encrypter.encrypt(noteKey, iv: iv);
    // Сохраняем IV вместе с зашифрованными данными: base64(iv) + ":" + base64(data)
    return '${base64Encode(iv.bytes)}:${encrypted.base64}';
  }
  
  /// Расшифровать ключ заметки мастер-ключом
  String? _decryptNoteKey(String encryptedNoteKey, String masterKey) {
    try {
      final masterKeyBytes = utf8.encode(masterKey);
      final masterKeyHash = sha256.convert(masterKeyBytes);
      final encryptionKey = Key.fromUtf8(masterKeyHash.toString().substring(0, 32));
      final encrypter = Encrypter(AES(encryptionKey));
      
      // Проверяем формат данных
      if (encryptedNoteKey.contains(':')) {
        // Новый формат: base64(iv):base64(data)
        final parts = encryptedNoteKey.split(':');
        if (parts.length != 2) {
          return null;
        }
        
        final ivBytes = base64Decode(parts[0]);
        final encryptedBytes = base64Decode(parts[1]);
        
        final iv = IV(ivBytes);
        final encrypted = Encrypted(encryptedBytes);
        
        return encrypter.decrypt(encrypted, iv: iv);
      } else {
        // Старый формат: только base64(data) - не поддерживается
        return null;
      }
    } catch (e) {
      return null;
    }
  }
} 