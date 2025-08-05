/// Изображение в заметке
class NoteImage {
  final String id;
  final String imagePath; // Путь к изображению (зашифрованному или незашифрованному)
  final int position; // Позиция в тексте (индекс символа)
  final DateTime createdAt;
  final int originalSize; // Размер оригинального изображения в байтах
  final String originalName; // Оригинальное имя файла
  final bool isEncrypted; // Флаг, указывающий зашифрован ли файл

  const NoteImage({
    required this.id,
    required this.imagePath,
    required this.position,
    required this.createdAt,
    required this.originalSize,
    required this.originalName,
    this.isEncrypted = false, // По умолчанию незашифрованное
  });

  NoteImage copyWith({
    String? id,
    String? imagePath,
    int? position,
    DateTime? createdAt,
    int? originalSize,
    String? originalName,
    bool? isEncrypted,
  }) {
    return NoteImage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      originalSize: originalSize ?? this.originalSize,
      originalName: originalName ?? this.originalName,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  /// Преобразование в JSON для хранения
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'position': position,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'originalSize': originalSize,
      'originalName': originalName,
      'isEncrypted': isEncrypted,
    };
  }

  /// Создание из JSON
  factory NoteImage.fromJson(Map<String, dynamic> json) {
    return NoteImage(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      position: json['position'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      originalSize: json['originalSize'] as int,
      originalName: json['originalName'] as String,
      isEncrypted: json['isEncrypted'] as bool? ?? false, // Обратная совместимость
    );
  }
} 