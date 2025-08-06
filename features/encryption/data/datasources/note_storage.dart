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
  
  /// Создать новую заметку
  Future<(Note, String)> createNote(Map<String, dynamic> content, String masterKey, {List<NoteImage> images = const []}) async {
    print('NoteStorage: Создаем новую заметку...');
    
    // Генерируем уникальный ключ для заметки
    final noteKey = _generateNoteKey();
    print('NoteStorage: Сгенерирован ключ заметки');
    
    // Конвертируем JSON Delta в строку для шифрования
    final contentString = jsonEncode(content);
    
    // Добавляем сигнатуру для проверки расшифровки
    final contentWithSignature = '$_magicSignature$contentString';
    print('NoteStorage: Добавлена сигнатура к содержимому');
    
    // Шифруем содержимое заметки ключом заметки
    final encryptedContent = _encryptContent(contentWithSignature, noteKey);
    print('NoteStorage: Содержимое зашифровано');
    
    // Шифруем ключ заметки мастер-ключом
    final encryptedNoteKey = _encryptNoteKey(noteKey, masterKey);
    print('NoteStorage: Ключ заметки зашифрован мастер-ключом');
    
    // Обрабатываем изображения
    List<NoteImage> processedImages = [];
    Map<String, dynamic> updatedContent = content;
    
    if (images.isNotEmpty) {
      print('NoteStorage: Обрабатываем ${images.length} изображений...');
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
            print('NoteStorage: 🗑️ Удален временный файл изображения: ${tempFile.path}');
          }
        }
      }
      print('NoteStorage: Обработано ${processedImages.length} изображений');
    }
    
    // Создаем заметку
    final note = Note(
      id: _generateId(),
      content: updatedContent,
      createdAt: DateTime.now(),
      encryptedContent: encryptedContent,
      images: processedImages,
    );
    
    print('NoteStorage: Заметка создана с ID: ${note.id}');
    
    // Сохраняем заметку
    await _saveNote(note);
    print('NoteStorage: Заметка сохранена в файл');
    
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
          createdAt: DateTime.parse(noteMap['createdAt']),
          modifiedAt: noteMap['modifiedAt'] != null 
            ? DateTime.parse(noteMap['modifiedAt']) 
            : null,
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
    print('NoteStorage: Ищем заметку по зашифрованному ключу...');
    
    // Сначала расшифровываем ключ из QR мастер-ключом
    print('NoteStorage: Расшифровываем ключ из QR...');
    final decryptedNoteKey = _decryptNoteKey(encryptedNoteKey, masterKey);
    if (decryptedNoteKey == null) {
      print('NoteStorage: Не удалось расшифровать ключ из QR');
      return (null, null);
    }
    print('NoteStorage: Ключ из QR расшифрован');
    
    final notes = await getAllNotes();
    print('NoteStorage: Найдено заметок: ${notes.length}');
    
    for (final note in notes) {
      try {
        print('NoteStorage: Проверяем заметку ${note.id}...');
        
        // Расшифровываем содержимое заметки ключом из QR
        final decryptedContent = _decryptContent(note.encryptedContent, decryptedNoteKey);
        if (decryptedContent == null) {
          print('NoteStorage: Не удалось расшифровать содержимое заметки');
          continue;
        }
        
        print('NoteStorage: Содержимое заметки расшифровано');
        
        // Проверяем сигнатуру
        if (decryptedContent.startsWith(_magicSignature)) {
          print('NoteStorage: Сигнатура найдена! Заметка найдена!');
          final contentString = decryptedContent.substring(_magicSignature.length);
          final content = jsonDecode(contentString) as Map<String, dynamic>;
          return (note.copyWith(content: content), decryptedNoteKey);
        } else {
          print('NoteStorage: Сигнатура не найдена');
        }
      } catch (e) {
        print('NoteStorage: Ошибка при проверке заметки: $e');
        // Продолжаем поиск
        continue;
      }
    }
    
    print('NoteStorage: Заметка не найдена');
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
            print('NoteStorage: Перешифровываем зашифрованное изображение: ${image.id}');
            
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
              print('NoteStorage: Не удалось расшифровать изображение: ${image.id}');
            }
          } else {
            // Изображение не зашифровано - шифруем как обычно
            print('NoteStorage: Шифруем незашифрованное изображение: ${image.id}');
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
            print('NoteStorage: Не удалось обработать изображение: ${image.id}');
            // Добавляем изображение без изменений, если не удалось перешифровать
            processedImages.add(image);
          }
        } else {
          print('NoteStorage: Файл изображения не найден: ${image.imagePath}');
          // Добавляем изображение без изменений, если файл не найден
          processedImages.add(image);
        }
      }
    }
    
    // Обновляем заметку с обновленным контентом
    final updatedNote = note.copyWith(
      content: updatedContent,
      encryptedContent: encryptedContent,
      modifiedAt: DateTime.now(),
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
          print('NoteStorage: 🗑️ Удален старый файл изображения: $oldPath');
        }
      } catch (e) {
        print('NoteStorage: ❌ Ошибка удаления старого файла $oldPath: $e');
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
      'createdAt': note.createdAt.toIso8601String(),
      'modifiedAt': note.modifiedAt?.toIso8601String(),
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