import '../repositories/note_repository.dart';
import '../entities/note.dart';

/// Use case для поиска заметки по QR-коду
class FindNoteByQR {
  final NoteRepository repository;

  FindNoteByQR(this.repository);

  /// Найти заметку по зашифрованному ключу из QR-кода
  Future<(Note?, String?)> call(String encryptedNoteKey, String masterKey) async {
    return await repository.findNoteByEncryptedKey(encryptedNoteKey, masterKey);
  }
} 