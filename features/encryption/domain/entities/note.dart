import 'note_image.dart';

/// Заметка с иерархическим шифрованием
class Note {
  final String id;
  final Map<String, dynamic> content; // JSON Delta формат для Quill
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final String encryptedContent;
  final String encryptedNoteKey;
  final List<NoteImage> images; // Список изображений в заметке

  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    this.modifiedAt,
    required this.encryptedContent,
    required this.encryptedNoteKey,
    this.images = const [], // По умолчанию пустой список
  });

  Note copyWith({
    String? id,
    Map<String, dynamic>? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? encryptedContent,
    String? encryptedNoteKey,
    List<NoteImage>? images,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      encryptedNoteKey: encryptedNoteKey ?? this.encryptedNoteKey,
      images: images ?? this.images,
    );
  }

  /// Добавить изображение в заметку
  Note addImage(NoteImage image) {
    final updatedImages = List<NoteImage>.from(images)..add(image);
    return copyWith(images: updatedImages);
  }

  /// Удалить изображение из заметки
  Note removeImage(String imageId) {
    final updatedImages = images.where((img) => img.id != imageId).toList();
    return copyWith(images: updatedImages);
  }

  /// Получить изображения, отсортированные по позиции
  List<NoteImage> get sortedImages {
    final sorted = List<NoteImage>.from(images);
    sorted.sort((a, b) => a.position.compareTo(b.position));
    return sorted;
  }

  /// Проверить, есть ли изображения в заметке
  bool get hasImages => images.isNotEmpty;
} 