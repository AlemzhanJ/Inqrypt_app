import '../../domain/entities/note.dart';
import '../../domain/entities/note_image.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_storage.dart';

/// Реализация репозитория заметок
class NoteRepositoryImpl implements NoteRepository {
  final NoteStorage _storage;

  NoteRepositoryImpl(this._storage);

  @override
  Future<List<Note>> getAllNotes() async {
    return await _storage.getAllNotes();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final notes = await _storage.getAllNotes();
    try {
      final note = notes.firstWhere((note) => note.id == id);
      // Возвращаем заметку с пустым содержимым - содержимое загружается только при расшифровке
      return note.copyWith(content: {});
    } catch (e) {
      return null;
    }
  }

  @override
  Future<(Note, String)> createNote(Map<String, dynamic> content, String masterKey, {List<NoteImage> images = const []}) async {
    print('NoteRepositoryImpl: createNote - начало');
    print('NoteRepositoryImpl: Контент: $content');
    print('NoteRepositoryImpl: Изображений: ${images.length}');
    
    try {
      final result = await _storage.createNote(content, masterKey, images: images);
      print('NoteRepositoryImpl: Заметка создана успешно');
      print('NoteRepositoryImpl: ID: ${result.$1.id}');
      print('NoteRepositoryImpl: Зашифрованный ключ: ${result.$2}');
      return result;
    } catch (e) {
      print('NoteRepositoryImpl: Ошибка создания заметки: $e');
      rethrow;
    }
  }

  @override
  Future<(Note, String)> updateNote(Note note, String masterKey, {String? existingNoteKey}) async {
    print('NoteRepositoryImpl: updateNote - начало');
    print('NoteRepositoryImpl: ID заметки: ${note.id}');
    print('NoteRepositoryImpl: Контент: ${note.content}');
    print('NoteRepositoryImpl: Изображений: ${note.images.length}');
    print('NoteRepositoryImpl: Используем существующий ключ: ${existingNoteKey != null}');
    
    try {
      final result = await _storage.updateNote(note, masterKey, existingNoteKey: existingNoteKey);
      print('NoteRepositoryImpl: Заметка обновлена успешно');
      return result;
    } catch (e) {
      print('NoteRepositoryImpl: Ошибка обновления заметки: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    await _storage.deleteNote(id);
  }

  @override
  Future<Note?> decryptNoteWithKey(String encryptedNoteKey, String masterKey) async {
    final result = await _storage.findNoteByEncryptedKey(encryptedNoteKey, masterKey);
    return result.$1;
  }

  @override
  Future<(Note?, String?)> findNoteByEncryptedKey(String encryptedNoteKey, String masterKey) async {
    return await _storage.findNoteByEncryptedKey(encryptedNoteKey, masterKey);
  }
} 