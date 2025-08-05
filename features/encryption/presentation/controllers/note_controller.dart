import 'package:flutter/foundation.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_image.dart';
import '../../domain/repositories/note_repository.dart';
import '../../../../shared/services/image_service.dart';

/// Контроллер для работы с заметками
class NoteController extends ChangeNotifier {
  final NoteRepository _repository;
  final ImageService _imageService = ImageService();
  
  Note? _currentNote;
  bool _isLoading = false;
  String? _error;
  String? _qrCodeData;
  String? _decryptedNoteKey; // Добавляем поле для расшифрованного ключа
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
  String? get decryptedNoteKey => _decryptedNoteKey; // Геттер для расшифрованного ключа
  bool get isFoundNote => _isFoundNote; // Геттер для флага найденной заметки
  bool get hasCurrentNote => _currentNote != null;
  bool get isEditing => _isEditing;
  
  // Геттеры для временных данных
  Map<String, dynamic> get tempContent => _tempContent;
  List<NoteImage> get tempImages => _tempImages;

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
    print('NoteController: updateTempData вызван');
    print('NoteController: Новый контент: $content');
    print('NoteController: Новых изображений: ${images.length}');
    
    _tempContent = content;
    _tempImages = images;
    notifyListeners();
    
    print('NoteController: Временные данные обновлены');
  }

  /// ПОЛНАЯ ОЧИСТКА ВСЕГО КОНТЕКСТА (включая содержимое)
  void clearAllContent() {
    print('NoteController: ПОЛНАЯ ОЧИСТКА КОНТЕКСТА');
    
    // Очищаем все данные заметки
    _currentNote = null;
    _qrCodeData = null;
    _decryptedNoteKey = null;
    _isFoundNote = false;
    _isEditing = false;
    
    // Очищаем временные данные
    _tempContent = {};
    _tempImages = [];
    
    // Очищаем ошибки
    _clearError();
    
    print('NoteController: Контекст полностью очищен');
    notifyListeners();
  }

  /// ОЧИСТКА ТОЛЬКО СОДЕРЖИМОГО (сохраняет QR-код)
  void clearContentOnly() {
    print('NoteController: ОЧИСТКА ТОЛЬКО СОДЕРЖИМОГО');
    
    // Очищаем только содержимое заметки, но сохраняем QR-код
    _currentNote = null;
    _decryptedNoteKey = null;
    _isFoundNote = false;
    _isEditing = false;
    
    // Очищаем временные данные
    _tempContent = {};
    _tempImages = [];
    
    // Очищаем ошибки
    _clearError();
    
    // QR-код НЕ очищаем - он нужен для отображения
    print('NoteController: Содержимое очищено, QR-код сохранен: $_qrCodeData');
    notifyListeners();
  }

  /// Создать новую заметку
  Future<bool> createNote(Map<String, dynamic> content, String masterKey, {List<NoteImage> images = const []}) async {
    _setLoading(true);
    try {
      print('NoteController: Создание заметки');
      print('NoteController: Контент: $content');
      print('NoteController: Изображений: ${images.length}');
      
      _currentNote = await _repository.createNote(content, masterKey, images: images);
      _qrCodeData = _currentNote!.encryptedNoteKey;
      _isFoundNote = false; // Сбрасываем флаг для новой заметки
      
      print('NoteController: Заметка создана');
      print('NoteController: ID: ${_currentNote!.id}');
      print('NoteController: QR код: $_qrCodeData');
      
      // ОЧИСТКА ТОЛЬКО СОДЕРЖИМОГО ПОСЛЕ СОЗДАНИЯ QR-КОДА
      // Содержимое заметки больше не нужно в открытом виде, но QR-код сохраняем
      clearContentOnly();
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      print('NoteController: Ошибка создания заметки: $e');
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
      
      // Если это найденная заметка, используем существующий ключ
      final existingNoteKey = _isFoundNote ? _decryptedNoteKey : null;
      
      _currentNote = await _repository.updateNote(updatedNote, masterKey, existingNoteKey: existingNoteKey);
      
      // Если это найденная заметка, QR-код остается тем же
      // Если это новая заметка, обновляем QR-код
      if (!_isFoundNote) {
        _qrCodeData = _currentNote!.encryptedNoteKey;
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
    if (_tempContent.isEmpty) {
      _setError('Заметка не может быть пустой');
      return false;
    }

    _setLoading(true);
    try {
      print('NoteController: saveNoteWithImages - начало');
      print('NoteController: Временный контент: $_tempContent');
      print('NoteController: Временные изображения: ${_tempImages.length}');
      print('NoteController: Текущая заметка: ${_currentNote?.id}');
      
      // Создаем или обновляем заметку
      bool success;
      if (_currentNote == null) {
        print('NoteController: Создаем новую заметку');
        success = await createNote(_tempContent, masterKey, images: _tempImages);
      } else {
        print('NoteController: Обновляем существующую заметку');
        success = await updateCurrentNote(_tempContent, masterKey, images: _tempImages);
      }

      print('NoteController: Результат операции: $success');
      print('NoteController: Ошибка: $_error');

      if (success) {
        _isEditing = false;
        _tempContent = {};
        _tempImages = [];
      }

      return success;
    } catch (e) {
      print('NoteController: Исключение в saveNoteWithImages: $e');
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
      _decryptedNoteKey = decryptedKey; // Сохраняем расшифрованный ключ
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
    _currentNote = null;
    _qrCodeData = null;
    _decryptedNoteKey = null; // Очищаем расшифрованный ключ
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
    _decryptedNoteKey = decryptedKey;
    _qrCodeData = note.encryptedNoteKey;
    _isFoundNote = true; // Устанавливаем флаг найденной заметки
    _isEditing = false; // Начинаем в режиме просмотра
    _tempContent = note.content;
    _tempImages = List.from(note.images);
    _clearError();
    notifyListeners();
    
    print('NoteController: Загружена найденная заметка');
    print('NoteController: ID: ${note.id}');
    print('NoteController: Расшифрованный ключ: $decryptedKey');
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
      _currentNote = null;
      _qrCodeData = null;
      _decryptedNoteKey = null; // Очищаем расшифрованный ключ
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
      print('NoteController: Удалено изображение $imageId');
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