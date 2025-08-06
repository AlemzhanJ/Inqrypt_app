import '../../domain/entities/note.dart';
import '../../domain/entities/note_image.dart';

/// Интерфейс репозитория для работы с заметками
abstract class NoteRepository {
  /// Получить все заметки
  Future<List<Note>> getAllNotes();
  
  /// Получить заметку по ID
  Future<Note?> getNoteById(String id);
  
  /// Создать новую заметку
  Future<(Note, String)> createNote(Map<String, dynamic> content, String masterKey, {List<NoteImage> images = const []});
  
  /// Обновить заметку
  Future<(Note, String)> updateNote(Note note, String masterKey, {String? existingNoteKey});
  
  /// Удалить заметку
  Future<void> deleteNote(String id);
  
  /// Расшифровать заметку с ключом (устаревший метод)
  @Deprecated('Используйте findNoteByEncryptedKey')
  Future<Note?> decryptNoteWithKey(String encryptedNoteKey, String masterKey);
  
  /// Найти заметку по зашифрованному ключу и вернуть пару (заметка, расшифрованный ключ)
  Future<(Note?, String?)> findNoteByEncryptedKey(String encryptedNoteKey, String masterKey);
} 