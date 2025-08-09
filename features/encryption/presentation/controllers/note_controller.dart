import 'package:flutter/foundation.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_image.dart';
import '../../domain/repositories/note_repository.dart';
import '../../../../shared/services/image_service.dart';
import '../../../../shared/services/note_key_storage.dart';
import '../../../../core/utils/validation_utils.dart';

/// Контроллер для работы с заметками
class NoteController extends ChangeNotifier {
  final NoteRepository _repository;
  final ImageService _imageService = ImageService();
  
  Note? _currentNote;
  bool _isLoading = false;
  String? _error;
  String? _qrCodeData;
  bool _isFoundNote = false; // Флаг для найденной заметки
  
  // Временные данные для редактирования
  Map<String, dynamic> _tempContent = {};
  List<NoteImage> _tempImages = [];
  bool _isEditing = false;

  NoteController(this._repository);

  // Геттеры
  Note? get currentNote => _currentNote;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get qrCodeData => _qrCodeData;
  bool get isFoundNote => _isFoundNote; // Геттер для флага найденной заметки
  bool get hasCurrentNote => _currentNote != null;
  bool get isEditing => _isEditing;
  
  // Геттеры для временных данных
  Map<String, dynamic> get tempContent => _tempContent;
  List<NoteImage> get tempImages => _tempImages;

  /// Получить расшифрованный ключ текущей заметки из secure storage
  Future<String?> get decryptedNoteKey async {
    if (_currentNote == null) return null;
    return await NoteKeyStorage.getNoteKey(_currentNote!.id);
  }

  /// Начать редактирование заметки
  void startEditing() {
    if (_currentNote != null) {
      _tempContent = _currentNote!.content;
      _tempImages = List.from(_currentNote!.images);
      _isEditing = true;
      notifyListeners();
    }
  }

  /// Отменить редактирование
  void cancelEditing() {
    _isEditing = false;
    _tempContent = {};
    _tempImages = [];
    notifyListeners();
  }

  /// Обновить временные данные
  void updateTempData(Map<String, dynamic> content, List<NoteImage> images) {
    
    _tempContent = content;
    _tempImages = images;
    notifyListeners();
    
  }

  /// ПОЛНАЯ ОЧИСТКА ВСЕГО КОНТЕКСТА (включая содержимое)
  void clearAllContent() {
    
    // Очищаем все данные заметки
    _currentNote = null;
    _qrCodeData = null;
    _isFoundNote = false;
    _isEditing = false;
    
    // Очищаем временные данные
    _tempContent = {};
    _tempImages = [];
    
    // Очищаем ключи из secure storage
    NoteKeyStorage.clearAllNoteKeys();
    
    // Очищаем ошибки
    _clearError();
    
    notifyListeners();
  }

  /// ОЧИСТКА ТОЛЬКО СОДЕРЖИМОГО (сохраняет QR-код)
  void clearContentOnly() {
    
    // Очищаем только содержимое заметки, но сохраняем QR-код
    _currentNote = null;
    _isFoundNote = false;
    _isEditing = false;
    
    // Очищаем временные данные
    _tempContent = {};
    _tempImages = [];
    
    // Очищаем ключи из secure storage
    NoteKeyStorage.clearAllNoteKeys();
    
    // Очищаем ошибки
    _clearError();
    
    // QR-код НЕ очищаем - он нужен для отображения
    notifyListeners();
  }

  /// Создать новую заметку
  Future<bool> createNote(Map<String, dynamic> content, String masterKey, {List<NoteImage> images = const []}) async {
    _setLoading(true);
    try {
      
      final result = await _repository.createNote(content, masterKey, images: images);
      _currentNote = result.$1;
      _qrCodeData = result.$2; // Зашифрованный ключ для QR-кода
      _isFoundNote = false; // Сбрасываем флаг для новой заметки
      
      
      // ОЧИСТКА ТОЛЬКО СОДЕРЖИМОГО ПОСЛЕ СОЗДАНИЯ QR-КОДА
      // Содержимое заметки больше не нужно в открытом виде, но QR-код сохраняем
      clearContentOnly();
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка создания заметки: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Обновить текущую заметку
  Future<bool> updateCurrentNote(Map<String, dynamic> content, String masterKey, {List<NoteImage> images = const []}) async {
    if (_currentNote == null) {
      _setError('Нет активной заметки');
      return false;
    }

    _setLoading(true);
    try {
      final updatedNote = _currentNote!.copyWith(
        content: content,
        images: images,
      );
      
      // Если это найденная заметка, используем существующий ключ из secure storage
      String? existingNoteKey;
      if (_isFoundNote) {
        existingNoteKey = await NoteKeyStorage.getNoteKey(_currentNote!.id);
      }
      
      final result = await _repository.updateNote(updatedNote, masterKey, existingNoteKey: existingNoteKey);
      _currentNote = result.$1;
      
      // Если это найденная заметка, QR-код остается тем же
      // Если это новая заметка, обновляем QR-код
      if (!_isFoundNote) {
        _qrCodeData = result.$2;
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка обновления заметки: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Сохранить заметку с изображениями
  Future<bool> saveNoteWithImages(String masterKey) async {
    if (ValidationUtils.isQuillContentEmpty(_tempContent) && _tempImages.isEmpty) {
      _setError('Заметка не может быть пустой');
      return false;
    }

    _setLoading(true);
    try {
      
      // Создаем или обновляем заметку
      bool success;
      if (_currentNote == null) {
        success = await createNote(_tempContent, masterKey, images: _tempImages);
      } else {
        success = await updateCurrentNote(_tempContent, masterKey, images: _tempImages);
      }


      if (success) {
        _isEditing = false;
        _tempContent = {};
        _tempImages = [];
      }

      return success;
    } catch (e) {
      _setError('Ошибка сохранения заметки: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Найти заметку по QR-коду
  Future<bool> findNoteByQR(String encryptedNoteKey, String masterKey) async {
    _setLoading(true);
    try {
      final result = await _repository.findNoteByEncryptedKey(encryptedNoteKey, masterKey);
      final note = result.$1;
      final decryptedKey = result.$2;
      
      if (note == null || decryptedKey == null) {
        _setError('Заметка не найдена');
        return false;
      }
      
      _currentNote = note;
      // Сохраняем расшифрованный ключ в secure storage
      await NoteKeyStorage.saveNoteKey(note.id, decryptedKey);
      _isFoundNote = true; // Устанавливаем флаг найденной заметки
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка поиска заметки: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Очистить текущую заметку
  void clearCurrentNote() {
    // Удаляем ключ из secure storage перед очисткой
    if (_currentNote != null) {
      NoteKeyStorage.removeNoteKey(_currentNote!.id);
    }
    
    _currentNote = null;
    _qrCodeData = null;
    _isFoundNote = false; // Сбрасываем флаг найденной заметки
    _isEditing = false;
    _tempContent = {};
    _tempImages = [];
    _clearError();
    notifyListeners();
  }

  /// Загрузить найденную заметку со сканера
  void loadFoundNote(Note note, String decryptedKey) {
    _currentNote = note;
    // Сохраняем расшифрованный ключ в secure storage
    NoteKeyStorage.saveNoteKey(note.id, decryptedKey);
    _isFoundNote = true; // Устанавливаем флаг найденной заметки
    _isEditing = false; // Начинаем в режиме просмотра
    _tempContent = note.content;
    _tempImages = List.from(note.images);
    _clearError();
    notifyListeners();
    
  }

  /// Удалить текущую заметку
  Future<bool> deleteCurrentNote() async {
    if (_currentNote == null) {
      _setError('Нет активной заметки');
      return false;
    }

    _setLoading(true);
    try {
      // Удаляем все изображения заметки
      for (final image in _currentNote!.images) {
        await _imageService.deleteEncryptedImage(image.imagePath);
      }
      
      await _repository.deleteNote(_currentNote!.id);
      
      // Удаляем ключ из secure storage
      await NoteKeyStorage.removeNoteKey(_currentNote!.id);
      
      _currentNote = null;
      _qrCodeData = null;
      _isFoundNote = false; // Сбрасываем флаг найденной заметки
      _isEditing = false;
      _tempContent = {};
      _tempImages = [];
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка удаления заметки: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Удалить изображение из временных данных
  void removeTempImage(String imageId) {
    _tempImages.removeWhere((img) => img.id == imageId);
    notifyListeners();
  }

  /// Удалить изображение из текущей заметки
  void removeImage(String imageId) {
    if (_currentNote != null) {
      // Удаляем изображение из текущей заметки
      _currentNote = _currentNote!.removeImage(imageId);
      
      // Также удаляем из временных данных, если они есть
      _tempImages.removeWhere((img) => img.id == imageId);
      
      notifyListeners();
    }
  }

  // Приватные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
} 