/// Entity для ключа шифрования
class EncryptionKey {
  final List<int> keyData;
  final DateTime createdAt;
  final String hash;
  final bool isActive;

  const EncryptionKey({
    required this.keyData,
    required this.createdAt,
    required this.hash,
    this.isActive = true,
  });

  /// Создание нового ключа
  factory EncryptionKey.create(List<int> keyData) {
    return EncryptionKey(
      keyData: List<int>.from(keyData), // Создаем копию для безопасности
      createdAt: DateTime.now(),
      hash: _generateHash(keyData),
    );
  }

  /// Создание ключа из сохраненных данных
  factory EncryptionKey.fromSaved({
    required List<int> keyData,
    required DateTime createdAt,
    required String hash,
    bool isActive = true,
  }) {
    return EncryptionKey(
      keyData: List<int>.from(keyData),
      createdAt: createdAt,
      hash: hash,
      isActive: isActive,
    );
  }

  /// Генерация хеша ключа
  static String _generateHash(List<int> keyData) {
    // Используем простой хеш для отображения
    final hash = keyData.take(8).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return hash.toUpperCase();
  }

  /// Получение размера ключа в байтах
  int get size => keyData.length;

  /// Проверка, что ключ валиден
  bool get isValid => keyData.length == 32 && isActive;

  /// Получение информации о ключе
  Map<String, dynamic> toMap() {
    return {
      'keyData': keyData,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'hash': hash,
      'isActive': isActive,
    };
  }

  /// Создание ключа из Map
  factory EncryptionKey.fromMap(Map<String, dynamic> map) {
    return EncryptionKey.fromSaved(
      keyData: List<int>.from(map['keyData']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      hash: map['hash'],
      isActive: map['isActive'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EncryptionKey &&
        other.hash == hash &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => hash.hashCode ^ createdAt.hashCode;

  @override
  String toString() {
    return 'EncryptionKey(hash: $hash, createdAt: $createdAt, isActive: $isActive)';
  }
} 