import 'note_image.dart';

/// Заметка с иерархическим шифрованием
class Note {
  final String id;
  final Map<String, dynamic> content; // JSON Delta формат для Quill
  final int sequence; // Порядковый номер заметки (монотонный, заменяет время создания)
  final DateTime? modifiedAt;
  final String encryptedContent;
  final List<NoteImage> images; // Список изображений в заметке

  const Note({
    required this.id,
    required this.content,
    required this.sequence,
    this.modifiedAt,
    required this.encryptedContent,
    this.images = const [], // По умолчанию пустой список
  });

  Note copyWith({
    String? id,
    Map<String, dynamic>? content,
    int? sequence,
    DateTime? modifiedAt,
    String? encryptedContent,
    List<NoteImage>? images,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      sequence: sequence ?? this.sequence,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      encryptedContent: encryptedContent ?? this.encryptedContent,
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