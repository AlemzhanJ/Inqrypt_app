import '../repositories/note_repository.dart';
import '../entities/note.dart';
import '../entities/note_image.dart';

/// Use case для создания заметки
class CreateNote {
  final NoteRepository repository;

  CreateNote(this.repository);

  /// Создать новую заметку с иерархическим шифрованием
  Future<Note> call(Map<String, dynamic> content, String masterKey, {List<NoteImage> images = const []}) async {
    return await repository.createNote(content, masterKey, images: images);
  }
} 