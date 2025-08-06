import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/note_controller.dart';
import '../controllers/master_key_controller.dart';
import '../widgets/quill_note_editor.dart';
import '../widgets/qr_display_widget.dart';
import '../../domain/entities/note_image.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../../shared/services/vibration_service.dart';
import '../../../../core/utils/validation_utils.dart';

/// Страница создания и редактирования заметки в стиле Apple Notes
class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final GlobalKey<QuillNoteEditorState> _editorKey = GlobalKey<QuillNoteEditorState>();
  
  Map<String, dynamic> _currentContent = {};
  List<NoteImage> _currentImages = [];
  bool _isEditing = true;
  
  // Кэш для Future редактора, чтобы избежать бесконечного цикла
  Future<Widget>? _editorFuture;
  NoteController? _cachedNoteController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final noteController = Provider.of<NoteController>(context, listen: false);
    
    // Проверяем, есть ли уже загруженная заметка (например, найденная через сканер)
    if (noteController.currentNote != null) {
      // Если заметка уже загружена, загружаем её
      _loadFoundNote(noteController);
    } else {
      // ПОЛНАЯ ОЧИСТКА СОСТОЯНИЯ ДЛЯ НОВОЙ ЗАМЕТКИ
      noteController.clearAllContent();
      print('NotePage: Состояние контроллера полностью очищено для новой заметки');
      
      // Инициализируем локальное состояние пустыми значениями
      setState(() {
        _currentContent = {};
        _currentImages = [];
        _isEditing = true; // Начинаем в режиме редактирования для новой заметки
      });
    }
    
    print('NotePage: Контроллеры инициализированы');
  }

  /// Загрузить найденную заметку
  void _loadFoundNote(NoteController noteController) {
    setState(() {
      // Используем реальное содержимое заметки, а не tempContent
      _currentContent = noteController.currentNote!.content;
      _currentImages = List.from(noteController.currentNote!.images);
      // Для найденных заметок начинаем в режиме редактирования, чтобы можно было переключаться
      _isEditing = noteController.isFoundNote ? true : noteController.isEditing;
    });
    print('NotePage: Загружена существующая заметка (ID: ${noteController.currentNote?.id})');
    print('NotePage: Содержимое заметки: ${noteController.currentNote!.content}');
    print('NotePage: isFoundNote: ${noteController.isFoundNote}');
    print('NotePage: _isEditing установлен в: $_isEditing');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context);
    
    return AppBar(
      title: Text(l10n.notePageTitle),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          final navigatorContext = context;
          await VibrationService().navigationBackVibration();
          
          // ПОЛНАЯ ОЧИСТКА КОНТЕКСТА ПРИ ВЫХОДЕ ИЗ СТРАНИЦЫ
          if (navigatorContext.mounted) {
            final noteController = Provider.of<NoteController>(navigatorContext, listen: false);
            noteController.clearAllContent(); // Полная очистка контекста включая QR-код
            Navigator.of(navigatorContext).pop();
          }
        },
      ),
      actions: [
        Consumer2<NoteController, MasterKeyController>(
          builder: (context, noteController, masterKeyController, child) {
            final hasContent = _currentContent.isNotEmpty || _currentImages.isNotEmpty;
            final hasMasterKey = masterKeyController.hasMasterKey;
            final isEncrypted = noteController.qrCodeData != null;
            
            // Отладочная информация
            print('NotePage AppBar Debug:');
            print('  hasContent: $hasContent');
            print('  hasMasterKey: $hasMasterKey');
            print('  isEncrypted: $isEncrypted');
            print('  _currentContent: $_currentContent');
            print('  _currentImages count: ${_currentImages.length}');
            print('  isFoundNote: ${noteController.isFoundNote}');
            print('  _isEditing: $_isEditing');
            print('  noteController.isEditing: ${noteController.isEditing}');
            
            // Если заметка зашифрована И это НЕ найденная заметка, показываем только кнопку назад
            if (isEncrypted && !noteController.isFoundNote) return const SizedBox.shrink();
            
            // Если нет мастер-ключа, не показываем кнопки
            if (!hasMasterKey) return const SizedBox.shrink();
            
            // Показываем галочку для переключения режимов (только в режиме редактирования)
            if (_isEditing) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0), // Отступ справа для симметрии со стрелочкой
                child: IconButton(
                  onPressed: () => _toggleEditMode(),
                  icon: const Icon(Icons.check),
                  tooltip: l10n.tooltipPreview,
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<NoteController>(
      builder: (context, noteController, child) {
        if (noteController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Если есть QR-код И это НЕ найденная заметка, показываем QR-код
        // (для случаев когда пользователь создал заметку и хочет посмотреть QR)
        if (noteController.qrCodeData != null && 
            !noteController.isFoundNote) {
          return _buildReadOnlyContent(noteController);
        }

        // Проверяем, нужно ли создать новый Future для редактора
        if (_editorFuture == null || _cachedNoteController != noteController) {
          _cachedNoteController = noteController;
          _editorFuture = _buildEditor(noteController);
        }

        // Показываем редактор (для новых заметок или найденных заметок)
        return FutureBuilder<Widget>(
          future: _editorFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Text('Ошибка загрузки редактора: ${snapshot.error}'),
              );
            }
            
            return snapshot.data ?? const Center(
              child: Text('Не удалось загрузить редактор'),
            );
          },
        );
      },
    );
  }

  /// Построить содержимое только для чтения (зашифрованная заметка)
  Widget _buildReadOnlyContent(NoteController noteController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR-код
          SimpleQRDisplayWidget(
            data: noteController.qrCodeData!,
          ),
          
          // Ошибки
          if (noteController.error != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      noteController.error!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Построить редактор заметки
  Future<Widget> _buildEditor(NoteController noteController) async {
    final isExistingNote = noteController.currentNote != null;
    
    // Определяем содержимое для передачи в редактор
    final contentToShow = isExistingNote 
        ? noteController.currentNote!.content  // Для найденной заметки используем реальное содержимое
        : _currentContent;  // Для новой заметки используем локальное состояние
    
    final imagesToShow = isExistingNote 
        ? noteController.currentNote!.images  // Для найденной заметки используем реальные изображения
        : _currentImages;  // Для новой заметки используем локальное состояние
    
    // Получаем ключ заметки для расшифровки изображений
    final noteKey = isExistingNote ? await noteController.decryptedNoteKey : null;
    
    return QuillNoteEditor(
      key: _editorKey,
      initialContent: contentToShow,
      initialImages: imagesToShow,
      isEditingMode: _isEditing,
      isExistingNote: isExistingNote, // Передаем информацию о типе заметки
      noteKey: noteKey, // Передаем ключ заметки для расшифровки изображений
      onChanged: (content, images) {
        // Проверяем, действительно ли изменились данные
        bool contentChanged = !_mapsEqual(_currentContent, content);
        bool imagesChanged = _currentImages.length != images.length || 
                           !_imagesEqual(_currentImages, images);
        
        if (contentChanged || imagesChanged) {
          setState(() {
            _currentContent = content;
            _currentImages = images;
          });
          
          // Обновляем временные данные в контроллере
          noteController.updateTempData(content, images);
          
          print('NotePage: setState выполнен (реальные изменения)');
        }
      },
      isReadOnly: false,
      onEncryptPressed: isExistingNote ? null : () => _showEncryptDialog(noteController, Provider.of<MasterKeyController>(context, listen: false)),
      onSavePressed: isExistingNote ? () => _showSaveDialog(noteController, Provider.of<MasterKeyController>(context, listen: false)) : null,
      onEditModeChanged: (isEditing) {
        print('NotePage: onEditModeChanged вызван с isEditing = $isEditing');
        print('NotePage: старый _isEditing = $_isEditing');
        
        setState(() {
          _isEditing = isEditing;
        });
        
        print('NotePage: новый _isEditing = $_isEditing');
        print('NotePage: setState выполнен для onEditModeChanged');
      },
      onNoteSaved: () {
        print('NotePage: Заметка сохранена, флаг изменений сброшен');
      },
    );
  }

  /// Сравнить два Map на равенство
  bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  /// Сравнить два списка изображений на равенство
  bool _imagesEqual(List<NoteImage> a, List<NoteImage> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  /// Переключить режим редактирования
  void _toggleEditMode() {
    print('NotePage: _toggleEditMode вызван');
    print('NotePage: текущий _isEditing = $_isEditing');
    print('NotePage: _editorKey.currentState = ${_editorKey.currentState}');
    
    if (_editorKey.currentState != null) {
      print('NotePage: вызываю toggleEditMode на редакторе');
      _editorKey.currentState!.toggleEditMode();
    } else {
      print('NotePage: ОШИБКА - _editorKey.currentState == null');
    }
  }

  Future<void> _showEncryptDialog(NoteController noteController, MasterKeyController masterKeyController) async {
    final l10n = AppLocalizations.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmEncryptNoteTitle),
        content: Text(l10n.confirmEncryptNoteContent),
        actions: [
          TextButton(
            onPressed: () async {
              await VibrationService().navigationBackVibration();
              if (context.mounted) {
                Navigator.of(context).pop(false);
              }
            },
            child: Text(l10n.cancelButtonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.encryptButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _encryptNote(noteController, masterKeyController);
    }
  }

  Future<void> _showSaveDialog(NoteController noteController, MasterKeyController masterKeyController) async {
    final l10n = AppLocalizations.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmSaveNoteTitle),
        content: Text(l10n.confirmSaveNoteContent),
        actions: [
          TextButton(
            onPressed: () async {
              await VibrationService().navigationBackVibration();
              if (context.mounted) {
                Navigator.of(context).pop(false);
              }
            },
            child: Text(l10n.cancelButtonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.saveButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _saveNote(noteController, masterKeyController);
    }
  }

  Future<void> _encryptNote(NoteController noteController, MasterKeyController masterKeyController) async {
    final l10n = AppLocalizations.of(context);
    
    // Получаем мастер-ключ с аутентификацией
    final masterKey = await masterKeyController.getMasterKeyWithAuth();
    if (masterKey == null) {
      if (mounted) {
        await NotificationService().showError(
          context: context,
          message: l10n.errorMasterKeyAccess,
        );
      }
      return;
    }

    // Проверяем, не пустое ли содержимое
    if (ValidationUtils.isQuillContentEmpty(_currentContent) && _currentImages.isEmpty) {
      if (mounted) {
        await NotificationService().showWarning(
          context: context,
          message: l10n.errorNoteEmpty,
        );
      }
      return;
    }

    final success = await noteController.saveNoteWithImages(masterKey);
    
    print('NotePage: Результат шифрования: $success');
    print('NotePage: QR код: ${noteController.qrCodeData}');
    print('NotePage: Текущая заметка: ${noteController.currentNote?.id}');
    
    if (success && mounted) {
      await NotificationService().showSuccess(
        context: context,
        message: l10n.noteEncrypted,
      );
      
      // Принудительно обновляем UI
      setState(() {});
    }
  }

  Future<void> _saveNote(NoteController noteController, MasterKeyController masterKeyController) async {
    final l10n = AppLocalizations.of(context);
    
    // Получаем мастер-ключ с аутентификацией
    final masterKey = await masterKeyController.getMasterKeyWithAuth();
    if (masterKey == null) {
      if (mounted) {
        await NotificationService().showError(
          context: context,
          message: l10n.errorMasterKeyAccess,
        );
      }
      return;
    }

    // Проверяем, не пустое ли содержимое
    if (ValidationUtils.isQuillContentEmpty(_currentContent) && _currentImages.isEmpty) {
      if (mounted) {
        await NotificationService().showWarning(
          context: context,
          message: l10n.errorNoteEmpty,
        );
      }
      return;
    }

    final success = await noteController.saveNoteWithImages(masterKey);
    
    print('NotePage: Результат сохранения: $success');
    print('NotePage: QR код: ${noteController.qrCodeData}');
    print('NotePage: Текущая заметка: ${noteController.currentNote?.id}');
    
    if (success && mounted) {
      await NotificationService().showSuccess(
        context: context,
        message: l10n.noteSaved,
      );
      
      // Принудительно обновляем UI
      setState(() {});
    }
  }
} 