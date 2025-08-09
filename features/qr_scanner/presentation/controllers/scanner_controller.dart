import 'package:flutter/foundation.dart';
import '../../../encryption/domain/entities/note.dart';
import '../../../encryption/domain/repositories/note_repository.dart';
import '../../../encryption/domain/repositories/master_key_repository.dart';
import '../../../encryption/presentation/controllers/note_controller.dart';
import '../../../../shared/services/biometric_service.dart';
import '../../../../core/localization/app_localizations.dart';

/// Контроллер для работы с QR сканером
class ScannerController extends ChangeNotifier {
  final NoteRepository _noteRepository;
  final MasterKeyRepository _masterKeyRepository;
  NoteController? _noteController; // Добавляем ссылку на контроллер заметок
  
  String? _scannedData;
  Note? _foundNote;
  String? _decryptedNoteKey; // Добавляем поле для расшифрованного ключа
  bool _isScanning = false;
  bool _isProcessing = false;
  String? _error;

  ScannerController(this._noteRepository, this._masterKeyRepository);

  // Геттеры
  String? get scannedData => _scannedData;
  Note? get foundNote => _foundNote;
  String? get decryptedNoteKey => _decryptedNoteKey; // Геттер для расшифрованного ключа
  bool get isScanning => _isScanning;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  bool get hasResults => _foundNote != null;

  /// Установить контроллер заметок
  void setNoteController(NoteController noteController) {
    _noteController = noteController;
  }

  /// Начать сканирование
  void startScanning() {
    _isScanning = true;
    notifyListeners();
  }

  /// Остановить сканирование
  void stopScanning() {
    _isScanning = false;
    notifyListeners();
  }

  /// Обработка отсканированного QR кода
  Future<void> processQRCode(String data, AppLocalizations l10n) async {
    if (_isProcessing) return;

    try {
      _setProcessing(true);
      _scannedData = data;
      
      
      // Запрашиваем биометрию для доступа к мастер-ключу
      
      final isAuthenticated = await BiometricService.authenticate(
        reason: l10n.biometricReason,
      );
      
      if (!isAuthenticated) {
        
        _setError(l10n.errorAuthenticationFailed);
        return;
      }
      
      
      // Получаем мастер-ключ
      final masterKey = await _masterKeyRepository.decryptMasterKey();
      if (masterKey == null) {
        
        _setError(l10n.errorMasterKeyAccess);
        return;
      }
      
      
      // Ищем заметку по зашифрованному ключу
      final result = await _noteRepository.findNoteByEncryptedKey(data, masterKey);
      final note = result.$1;
      final decryptedKey = result.$2;
      
      if (note != null && decryptedKey != null) {
        
        _foundNote = note;
        _decryptedNoteKey = decryptedKey; // Сохраняем расшифрованный ключ
        _clearError();
        
        // Передаем найденную заметку в контроллер заметок
        _noteController?.loadFoundNote(note, decryptedKey);
      } else {
        
        _setError(l10n.noteNotFound);
      }
      
    } catch (e) {
      
      _setError(l10n.errorInvalidQR);
    } finally {
      _setProcessing(false);
    }
  }

  /// Очистить результаты
  void clearResults() {
    _clearResults();
    notifyListeners();
  }

  /// Очистить результаты (внутренний метод)
  void _clearResults() {
    _scannedData = null;
    _foundNote = null;
    _decryptedNoteKey = null; // Очищаем расшифрованный ключ
    _clearError();
  }

  // Приватные методы
  void _setProcessing(bool processing) {
    _isProcessing = processing;
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