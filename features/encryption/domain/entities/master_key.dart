/// Мастер-ключ для иерархического шифрования
class MasterKey {
  final String id;
  final String encryptedKey;
  final DateTime createdAt;
  final bool isProtected;

  const MasterKey({
    required this.id,
    required this.encryptedKey,
    required this.createdAt,
    required this.isProtected,
  });

  MasterKey copyWith({
    String? id,
    String? encryptedKey,
    DateTime? createdAt,
    bool? isProtected,
  }) {
    return MasterKey(
      id: id ?? this.id,
      encryptedKey: encryptedKey ?? this.encryptedKey,
      createdAt: createdAt ?? this.createdAt,
      isProtected: isProtected ?? this.isProtected,
    );
  }
} 