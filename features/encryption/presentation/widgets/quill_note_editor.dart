import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../shared/services/vibration_service.dart';
import '../../../../shared/services/image_service.dart';
import '../../domain/entities/note_image.dart';
import '../../../../core/localization/app_localizations.dart';
import '../image_gallery_page.dart';

/// Виджет для редактирования заметок в стиле Apple Notes
class QuillNoteEditor extends StatefulWidget {
  final Map<String, dynamic> initialContent;
  final List<NoteImage> initialImages;
  final Function(Map<String, dynamic> content, List<NoteImage> images) onChanged;
  final bool isReadOnly;
  final bool isEditingMode;
  final bool isExistingNote; // Новая заметка или найденная существующая
  final VoidCallback? onEncryptPressed; // Callback для кнопки шифрования (новая заметка)
  final VoidCallback? onSavePressed; // Callback для кнопки сохранения (существующая заметка)
  final VoidCallback? onDeletePressed; // Callback для кнопки удаления (найденная заметка)
  final Function(bool isEditing)? onEditModeChanged; // Callback для изменения режима редактирования
  final VoidCallback? onNoteSaved; // Callback для уведомления о сохранении заметки
  final String? noteKey; // Ключ заметки для расшифровки изображений

  const QuillNoteEditor({
    super.key,
    required this.initialContent,
    this.initialImages = const [],
    required this.onChanged,
    this.isReadOnly = false,
    this.isEditingMode = true,
    this.isExistingNote = false, // По умолчанию новая заметка
    this.onEncryptPressed,
    this.onSavePressed,
    this.onDeletePressed,
    this.onEditModeChanged,
    this.onNoteSaved,
    this.noteKey, // Ключ заметки для расшифровки изображений
  });

  @override
  State<QuillNoteEditor> createState() => _QuillNoteEditorState();
}

/// Публичный интерфейс для состояния редактора
abstract class QuillNoteEditorState extends State<QuillNoteEditor> {
  Future<void> insertImage();
  void toggleEditMode();
}

class _QuillNoteEditorState extends QuillNoteEditorState {
  late QuillController _controller;
  List<NoteImage> _images = [];
  final Map<String, Uint8List> _imageCache = {};
  final ImageService _imageService = ImageService();
  bool _isEditing = true;
  final FocusNode _focusNode = FocusNode();
  
  // Переменные для отслеживания изменений
  List<dynamic> _originalContent = [];
  List<NoteImage> _originalImages = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
    _isEditing = widget.isEditingMode;
    
    // Инициализируем QuillController
    if (widget.initialContent.isNotEmpty) {
      final deltaList = _convertMapToDeltaList(widget.initialContent);
      _controller = QuillController(
        document: Document.fromJson(deltaList),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      // Создаем документ с одной пустой строкой, чтобы курсор был правильного размера
      final document = Document()..insert(0, '\n');
      _controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    
    // Сохраняем исходный контент для отслеживания изменений ПОСЛЕ инициализации контроллера
    _originalContent = List<dynamic>.from(_controller.document.toDelta().toJson());
    _originalImages = List<NoteImage>.from(widget.initialImages);
    _hasChanges = false; // При инициализации изменений нет
    
    
    _controller.addListener(_onContentChanged);
    _loadInitialImages();
    
    // Автоматически устанавливаем курсор в начало документа при заходе в заметку
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isEditing && !widget.isReadOnly) {
        _controller.updateSelection(
          const TextSelection.collapsed(offset: 0),
          ChangeSource.remote,
        );
        _focusNode.requestFocus();
      }
    });
  }

  /// Конвертировать Map в List для Document.fromJson
  List<dynamic> _convertMapToDeltaList(Map<String, dynamic> content) {
    if (content.containsKey('ops') && content['ops'] is List) {
      return content['ops'] as List<dynamic>;
    }
    return [];
  }

  /// Проверить, изменился ли контент
  bool _checkForChanges() {
    // Проверяем изменения в текстовом контенте
    final currentContent = _controller.document.toDelta().toJson();
    final contentChanged = !_listsAreEqual(_originalContent, currentContent);
    
    // Проверяем изменения в изображениях
    final imagesChanged = !_imagesAreEqual(_originalImages, _images);
    
    // Отладочная информация
    if (contentChanged) {
      
      // Подробное сравнение каждого элемента
      for (int i = 0; i < _originalContent.length && i < currentContent.length; i++) {
        final orig = _originalContent[i];
        final curr = currentContent[i];
        if (orig != curr) {
        }
      }
    }
    if (imagesChanged) {
    }
    
    return contentChanged || imagesChanged;
  }

  /// Сравнить два списка на равенство
  bool _listsAreEqual(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      final item1 = list1[i];
      final item2 = list2[i];
      
      // Если это Map, сравниваем по ключам и значениям
      if (item1 is Map && item2 is Map) {
        if (item1.length != item2.length) return false;
        for (final key in item1.keys) {
          if (!item2.containsKey(key)) return false;
          
          final value1 = item1[key];
          final value2 = item2[key];
          
          // Если значение тоже Map, сравниваем рекурсивно
          if (value1 is Map && value2 is Map) {
            if (!_mapsAreEqual(value1, value2)) return false;
          } else if (value1 != value2) {
            return false;
          }
        }
      } else if (item1 != item2) {
        return false;
      }
    }
    
    return true;
  }

  /// Сравнить два Map на равенство
  bool _mapsAreEqual(Map<dynamic, dynamic> map1, Map<dynamic, dynamic> map2) {
    if (map1.length != map2.length) return false;
    
    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      
      final value1 = map1[key];
      final value2 = map2[key];
      
      if (value1 != value2) return false;
    }
    
    return true;
  }

  /// Сравнить два списка изображений на равенство
  bool _imagesAreEqual(List<NoteImage> list1, List<NoteImage> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    
    return true;
  }

  /// Сбросить флаг изменений (вызывается после сохранения)
  void _resetChangesFlag() {
    setState(() {
      _hasChanges = false;
      // Обновляем исходный контент на текущий
      _originalContent = List<dynamic>.from(_controller.document.toDelta().toJson());
      _originalImages = List<NoteImage>.from(_images);
    });
  }

  /// Загрузить начальные изображения
  Future<void> _loadInitialImages() async {
    for (final image in _images) {
      try {
        if (image.isEncrypted && widget.noteKey != null) {
          // Зашифрованное изображение - расшифровываем
          final imageBytes = await _imageService.decryptImage(image.imagePath, widget.noteKey!);
          if (imageBytes != null) {
            _imageCache[image.id] = imageBytes;
          } else {
          }
        } else {
          // Незашифрованное изображение - читаем напрямую
          final imageFile = File(image.imagePath);
          if (await imageFile.exists()) {
            final imageBytes = await imageFile.readAsBytes();
            _imageCache[image.id] = imageBytes;
          } else {
          }
        }
      } catch (e) {
        // Игнорируем ошибки при загрузке изображений из кэша
        // Это не критично для работы редактора
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    final delta = _controller.document.toDelta();
    final content = {'ops': delta.toJson()};
    
    // Проверяем, какие изображения были удалены из документа
    _checkForDeletedImages();
    
    // Применяем стиль заголовка к первой строке если она не пустая
    _applyHeaderStyleToFirstLine();
    
    // Проверяем изменения и обновляем состояние
    final hasChanges = _checkForChanges();
    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
    
    widget.onChanged(content, _images);
  }

  /// Проверить и удалить изображения, которые были удалены из документа
  void _checkForDeletedImages() {
    final document = _controller.document;
    final Set<String> currentImageIds = {};
    
    // Собираем ID всех изображений, которые сейчас есть в документе
    for (final node in document.root.children) {
      if (node is Line) {
        for (final child in node.children) {
          if (child is Embed && child.value.data is Map<String, dynamic>) {
            final data = child.value.data as Map<String, dynamic>;
            if (data.containsKey('imageId')) {
              currentImageIds.add(data['imageId'] as String);
            }
          }
        }
      }
    }
    
    // Удаляем изображения из списка, которых больше нет в документе
    final List<NoteImage> imagesToRemove = [];
    for (final image in _images) {
      if (!currentImageIds.contains(image.id)) {
        imagesToRemove.add(image);
        // Удаляем из кэша
        _imageCache.remove(image.id);
      }
    }
    
    if (imagesToRemove.isNotEmpty) {
      setState(() {
        _images.removeWhere((image) => imagesToRemove.contains(image));
      });
    }
  }

  /// Применить стиль заголовка к первой строке
  void _applyHeaderStyleToFirstLine() {
    final document = _controller.document;
    if (document.length <= 1) return; // Пустой документ
    
    // Получаем первую строку документа через root.children
    final firstLine = document.root.children.firstOrNull;
    if (firstLine != null && firstLine is Line) {
      // Получаем текст первой строки
      final firstLineText = firstLine.toPlainText();
      
      // Если первая строка не пустая и не имеет стиля заголовка
      if (firstLineText.isNotEmpty && !firstLine.style.containsKey(Attribute.header.key)) {
        // Применяем атрибут заголовка H1 к текущему выделению
        _controller.formatSelection(Attribute.h1);
      }
    }
  }

  /// Найти ближайшую валидную позицию для курсора
  int _findNearestValidPosition(int tapOffset, int documentLength) {
    // Если документ пустой, возвращаем 0
    if (documentLength <= 1) return 0;
    
    // Ограничиваем позицию в пределах документа
    int targetOffset = tapOffset.clamp(0, documentLength - 1);
    
    // Получаем текст документа для анализа
    final plainText = _controller.document.toPlainText();
    
    // Если позиция выходит за пределы текста, возвращаем конец
    if (targetOffset >= plainText.length) {
      return plainText.length;
    }
    
    // Если позиция в пределах текста, проверяем её валидность
    if (targetOffset >= 0 && targetOffset <= plainText.length) {
      // Если позиция попадает на границу слова или пробел, оставляем как есть
      if (targetOffset == 0 || 
          targetOffset == plainText.length ||
          plainText[targetOffset] == ' ' ||
          plainText[targetOffset] == '\n' ||
          (targetOffset > 0 && plainText[targetOffset - 1] == ' ') ||
          (targetOffset > 0 && plainText[targetOffset - 1] == '\n')) {
        return targetOffset;
      }
      
      // Если позиция попадает в середину слова, ищем ближайшую границу
      // Сначала ищем влево до начала слова
      int leftBoundary = targetOffset;
      while (leftBoundary > 0 && 
             plainText[leftBoundary - 1] != ' ' && 
             plainText[leftBoundary - 1] != '\n') {
        leftBoundary--;
      }
      
      // Затем ищем вправо до конца слова
      int rightBoundary = targetOffset;
      while (rightBoundary < plainText.length && 
             plainText[rightBoundary] != ' ' && 
             plainText[rightBoundary] != '\n') {
        rightBoundary++;
      }
      
      // Выбираем ближайшую границу
      int leftDistance = targetOffset - leftBoundary;
      int rightDistance = rightBoundary - targetOffset;
      
      return leftDistance <= rightDistance ? leftBoundary : rightBoundary;
    }
    
    return targetOffset;
  }

  /// Показать галерею изображений
  void _showImageGallery(String selectedImageId) async {
    if (_images.isEmpty) return;

    // Находим индекс выбранного изображения
    final selectedIndex = _images.indexWhere((img) => img.id == selectedImageId);
    if (selectedIndex == -1) return;

    final navigatorContext = context;
    await VibrationService().navigationForwardVibration();
    if (navigatorContext.mounted) {
      Navigator.of(navigatorContext).push(
        MaterialPageRoute(
          builder: (context) => ImageGalleryPage(
            images: _images,
            initialIndex: selectedIndex,
            imageCache: Map<String, Uint8List>.from(_imageCache),
            isReadOnly: widget.isReadOnly,
            onImageRemoved: (imageId) {
              // Удаляем изображение из списка
              setState(() {
                _images.removeWhere((img) => img.id == imageId);
                _imageCache.remove(imageId);
              });
              
              // Удаляем изображение из документа Quill
              _removeImageFromDocument(imageId);
              
              // Закрываем галерею
              Navigator.of(navigatorContext).pop();
            },
          ),
        ),
      );
    }
  }

  /// Удалить изображение из документа Quill
  void _removeImageFromDocument(String imageId) {
    final document = _controller.document;
    final List<int> positionsToRemove = [];
    
    // Итерируемся по всем узлам документа через root.children
    for (final node in document.root.children) {
      if (node is Line) {
        // Проходим по всем дочерним узлам строки
        for (final leaf in node.children) {
          if (leaf is Embed) {
            final data = leaf.value.data as Map<String, dynamic>;
            if (data.containsKey('imageId') && data['imageId'] == imageId) {
              positionsToRemove.add(leaf.documentOffset);
            }
          }
        }
      } else if (node is Block) {
        // Проходим по блокам (цитаты, код-блоки и т.д.)
        for (final line in node.children) {
          if (line is Line) {
            for (final leaf in line.children) {
              if (leaf is Embed) {
                final data = leaf.value.data as Map<String, dynamic>;
                if (data.containsKey('imageId') && data['imageId'] == imageId) {
                  positionsToRemove.add(leaf.documentOffset);
                }
              }
            }
          }
        }
      }
    }
    
    // Удаляем изображения в обратном порядке (чтобы не сбить индексы)
    for (int i = positionsToRemove.length - 1; i >= 0; i--) {
      final pos = positionsToRemove[i];
      
      // Удаляем символы новой строки до и после изображения
      if (pos > 0) {
        final prevNode = _controller.queryNode(pos - 1);
        if (prevNode != null && prevNode.toPlainText() == '\n') {
          document.delete(pos - 1, 1);
        }
      }
      if (pos < document.length - 1) {
        final nextNode = _controller.queryNode(pos);
        if (nextNode != null && nextNode.toPlainText() == '\n') {
          document.delete(pos, 1);
        }
      }
      
      // Удаляем само изображение (Embed всегда имеет length = 1)
      document.delete(pos, 1);
    }
    
    _onContentChanged();
  }

  /// Вставить изображение в текущую позицию курсора
  @override
  Future<void> insertImage() async {
    if (widget.isReadOnly || !_isEditing) return;

    final result = await _imageService.showImageSourceDialog(context);
    if (result == null) return;

    final file = result.file;
    final shouldDeleteOriginal = result.shouldDeleteOriginal;

    // Получаем позицию курсора
    final selection = _controller.selection;
    final position = selection.baseOffset;

    // Сначала читаем все данные из файла
    final imageBytes = await file.readAsBytes();
    final originalSize = await file.length();
    final originalName = file.path.split('/').last;

    // Копируем файл в папку приложения
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/note_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final imagePath = '${imagesDir.path}/$fileName';
    
    await file.copy(imagePath);

    // Удаляем оригинальный файл, если это была съемка через камеру
    if (shouldDeleteOriginal) {
      try {
        final fileExistsBefore = await file.exists();
        if (fileExistsBefore) {
          await file.delete();
        }
      } catch (e) {
        // Игнорируем ошибки при удалении оригинального файла
        // Это не критично для работы приложения
      }
    }

    // Создаем объект изображения
    final image = NoteImage(
      id: 'img_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: imagePath,
      position: position,
      createdAt: DateTime.now(),
      originalSize: originalSize,
      originalName: originalName,
      isEncrypted: false, // Новые изображения незашифрованы
    );

    // Кэшируем изображение
    _imageCache[image.id] = imageBytes;

    // Добавляем изображение в список
    setState(() {
      _images.add(image);
    });

    // Интегрируем изображение в Quill Delta
    final imageEmbed = Embeddable.fromJson({
      'image': {
        'imageId': image.id,
        'imagePath': imagePath,
        'originalName': originalName,
      },
    });
    
    // Вставляем изображение в документ
    _controller.document.insert(position, '\n');
    _controller.document.insert(position + 1, imageEmbed);
    _controller.document.insert(position + 2, '\n');
    
    // Обновляем позицию курсора после изображения
    _controller.updateSelection(
      TextSelection.collapsed(offset: position + 3),
      ChangeSource.remote,
    );

    _onContentChanged();
  }

  /// Переключить режим редактирования
  @override
  void toggleEditMode() {
    
    setState(() {
      _isEditing = !_isEditing;
    });
    
    
    // Вибрация при переключении режима
    VibrationService().navigationForwardVibration();
    widget.onEditModeChanged?.call(_isEditing);
    
  }

  /// Обработать вставку текста с применением стилей окружающего текста
  Future<void> _handlePasteWithSurroundingStyles() async {
    try {
      // Получаем данные из буфера обмена
      final ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == null || clipboardData!.text!.isEmpty) {
        return;
      }

      final String textToPaste = clipboardData.text!;

      // Получаем текущую позицию курсора
      final TextSelection selection = _controller.selection;
      final int insertPosition = selection.baseOffset;
      

      // Получаем стили окружающего текста в позиции вставки
      final Style surroundingStyle = _getSurroundingStyle(insertPosition);

      // Очищаем текст от лишних символов новой строки в начале и конце
      final String cleanedText = _cleanTextForPaste(textToPaste);

      // Вставляем текст с применением стилей окружающего текста
      _insertTextWithStyle(cleanedText, insertPosition, surroundingStyle);

      // Вибрация при успешной вставке
      VibrationService().successVibration();

    } catch (e) {
      // Вибрация при ошибке
      VibrationService().errorVibration();
    }
  }

  /// Получить стили окружающего текста в указанной позиции
  Style _getSurroundingStyle(int position) {
    try {
      // Получаем текущий документ
      final Document document = _controller.document;
      
      // Если документ пустой, возвращаем пустой стиль
      if (document.length <= 1) {
        return Style();
      }

      // Ограничиваем позицию в пределах документа
      final int safePosition = position.clamp(0, document.length - 1);
      
      // Получаем стили в позиции курсора используя collectStyle
      final Style styleAtPosition = document.collectStyle(safePosition, 1);
      
      // Если стили в позиции не найдены, ищем в ближайшей позиции
      if (styleAtPosition.isEmpty) {
        // Ищем стили в предыдущей позиции
        if (safePosition > 0) {
          final Style prevStyle = document.collectStyle(safePosition - 1, 1);
          if (prevStyle.isNotEmpty) {
            return prevStyle;
          }
        }
        
        // Ищем стили в следующей позиции
        if (safePosition < document.length - 1) {
          final Style nextStyle = document.collectStyle(safePosition + 1, 1);
          if (nextStyle.isNotEmpty) {
            return nextStyle;
          }
        }
        
        // Если стили не найдены, возвращаем пустой стиль
        return Style();
      }

      return styleAtPosition;
      
    } catch (e) {
      return Style();
    }
  }

  /// Очистить текст от лишних символов для вставки
  String _cleanTextForPaste(String text) {
    // Удаляем лишние пробелы и символы новой строки в начале и конце
    String cleaned = text.trim();
    
    // Заменяем множественные пробелы на одинарные
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Заменяем множественные символы новой строки на одинарные
    cleaned = cleaned.replaceAll(RegExp(r'\n+'), '\n');
    
    return cleaned;
  }

  /// Вставить текст с применением стилей
  void _insertTextWithStyle(String text, int position, Style style) {
    try {
      // Если текст пустой, ничего не вставляем
      if (text.isEmpty) {
        return;
      }

      // Устанавливаем позицию курсора
      _controller.updateSelection(
        TextSelection.collapsed(offset: position),
        ChangeSource.remote,
      );

      // Вставляем текст
      _controller.document.insert(position, text);
      
      // Применяем стили к вставленному тексту
      if (style.isNotEmpty) {
        // Применяем каждый атрибут стиля отдельно
        style.attributes.forEach((key, attribute) {
          _controller.formatText(position, text.length, attribute);
        });
      }

      // Устанавливаем курсор после вставленного текста
      final int newPosition = position + text.length;
      _controller.updateSelection(
        TextSelection.collapsed(offset: newPosition),
        ChangeSource.remote,
      );

      
    } catch (e) {
      // Игнорируем ошибки при вставке текста со стилями
      // Это не критично для работы редактора
    }
  }

  /// Показать кастомное меню вставки для мобильных устройств
  void _showCustomPasteMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.content_paste),
                title: Text(AppLocalizations.of(context).pasteWithStyles),
                subtitle: Text(AppLocalizations.of(context).pasteWithStylesDescription),
                onTap: () {
                  Navigator.pop(context);
                  _handlePasteWithSurroundingStyles();
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_paste_go),
                title: Text(AppLocalizations.of(context).pasteAsPlainText),
                subtitle: Text(AppLocalizations.of(context).pasteAsPlainTextDescription),
                onTap: () {
                  Navigator.pop(context);
                  _handlePasteAsPlainText();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Обработать вставку как обычный текст (без применения стилей)
  Future<void> _handlePasteAsPlainText() async {
    try {
      // Получаем данные из буфера обмена
      final ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text == null || clipboardData!.text!.isEmpty) {
        return;
      }

      final String textToPaste = clipboardData.text!;

      // Получаем текущую позицию курсора
      final TextSelection selection = _controller.selection;
      final int insertPosition = selection.baseOffset;
      

      // Очищаем текст от лишних символов
      final String cleanedText = _cleanTextForPaste(textToPaste);

      // Вставляем текст без применения стилей
      _insertTextWithStyle(cleanedText, insertPosition, Style());

      // Вибрация при успешной вставке
      VibrationService().successVibration();

    } catch (e) {
      // Вибрация при ошибке
      VibrationService().errorVibration();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // Управляем режимом только для чтения через контроллер
    _controller.readOnly = !_isEditing || widget.isReadOnly;
    
    return Stack(
      children: [
        // Основной контент
        Column(
          children: [
            // Редактор
            Expanded(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (KeyEvent event) {
                  // Проверяем, что это событие нажатия клавиши и мы в режиме редактирования
                  if (event is KeyDownEvent && _isEditing && !widget.isReadOnly) {
                    // Проверяем комбинацию Cmd+V (macOS) или Ctrl+V (другие платформы)
                    final bool isPasteCommand = (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed) && 
                                               event.logicalKey == LogicalKeyboardKey.keyV;
                    
                    if (isPasteCommand) {
                      // Перехватываем стандартную вставку и используем нашу кастомную
                      _handlePasteWithSurroundingStyles();
                    }
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    
                    // При клике по тексту в режиме просмотра переключаем в режим редактирования
                    if (!_isEditing && !widget.isReadOnly) {
                      toggleEditMode();
                    } else {
                    }
                  },
                  onLongPress: () {
                    // Обработчик длительного нажатия для мобильных устройств
                    if (_isEditing && !widget.isReadOnly) {
                      _showCustomPasteMenu();
                    }
                  },
                  child: QuillEditor.basic(
                    controller: _controller,
                    focusNode: _focusNode,
                    config: QuillEditorConfig(
                      autoFocus: _isEditing && !widget.isReadOnly,
                      padding: const EdgeInsets.all(20),
                      showCursor: _isEditing && !widget.isReadOnly,
                      embedBuilders: [
                        ImageEmbedBuilder(
                          imageCache: _imageCache,
                          noteKey: widget.noteKey,
                          onImageTap: (imageId) {
                            // Переход в галерею изображений
                            _showImageGallery(imageId);
                          },
                        ),
                      ],
                      customStyles: DefaultStyles(
                        h1: DefaultTextBlockStyle(
                          Theme.of(context).textTheme.headlineLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(8, 8),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                      onTapDown: (details, p1) {
                        
                        // Если мы в режиме редактирования, разрешаем все клики
                        if (_isEditing && !widget.isReadOnly) {
                          return false; // Разрешаем дальнейшую обработку для навигации по тексту и кликов по изображениям
                        }
                        
                        // Если мы в режиме просмотра, переключаем в режим редактирования
                        if (!_isEditing && !widget.isReadOnly) {
                          
                          // Сохраняем позицию клика для установки курсора
                          final tapOffset = p1(details.globalPosition).offset;
                          
                          // Находим ближайшую валидную позицию для курсора
                          final documentLength = _controller.document.length;
                          final targetOffset = _findNearestValidPosition(tapOffset, documentLength);
                          
                          _controller.updateSelection(
                            TextSelection.collapsed(offset: targetOffset),
                            ChangeSource.remote,
                          );
                          
                          // Затем переключаем режим
                          toggleEditMode();
                          
                          // И фокусируемся
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _isEditing) {
                              _focusNode.requestFocus();
                            }
                          });
                          
                          return true; // Обрабатываем событие
                        }
                        
                        // В остальных случаях (только для чтения) игнорируем
                        return false;
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            // Тулбар над клавиатурой (только в режиме редактирования)
            if (_isEditing && !widget.isReadOnly)
              _buildToolbar(),
          ],
        ),
        
        // Кнопка шифрования/сохранения внизу справа (только в режиме просмотра)
        if (!_isEditing && (widget.onEncryptPressed != null || widget.onSavePressed != null))
          Positioned(
            bottom: 40, // Выше (было 20)
            right: 40, // Левее (было 20)
            child: widget.isExistingNote 
                ? (_hasChanges ? _buildSaveButton() : const SizedBox.shrink())
                : _buildEncryptButton(),
          ),
          
        // Кнопка удаления слева снизу (только для найденных заметок в режиме просмотра)
        if (!_isEditing && widget.isExistingNote && widget.onDeletePressed != null)
          Positioned(
            bottom: 40,
            left: 40,
            child: _buildDeleteButton(),
          ),
      ],
    );
  }

  /// Построить кнопку шифрования
  Widget _buildEncryptButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            VibrationService().successVibration();
            widget.onEncryptPressed?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Увеличил padding (было 16, 12)
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code,
                  color: isDark ? Colors.black : Colors.white,
                  size: 24, // Увеличил размер иконки (было 20)
                ),
                const SizedBox(width: 10), // Увеличил отступ (было 8)
                Text(
                  AppLocalizations.of(context).encryptButtonText,
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16, // Увеличил размер текста (было 14)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Построить кнопку сохранения (только для существующих заметок)
  Widget _buildSaveButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            VibrationService().successVibration();
            widget.onSavePressed?.call();
            // Сбрасываем флаг изменений после сохранения
            _resetChangesFlag();
            // Уведомляем о сохранении
            widget.onNoteSaved?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Увеличил padding (было 16, 12)
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.save,
                  color: isDark ? Colors.black : Colors.white,
                  size: 24, // Увеличил размер иконки (было 20)
                ),
                const SizedBox(width: 10), // Увеличил отступ (было 8)
                Text(
                  AppLocalizations.of(context).saveButtonText,
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16, // Увеличил размер текста (было 14)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Построить кнопку удаления (только для найденных заметок)
  Widget _buildDeleteButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.red : Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            VibrationService().errorVibration();
            widget.onDeletePressed?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Увеличил padding (было 16, 12)
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_forever,
                  color: isDark ? Colors.white : Colors.white,
                  size: 24, // Увеличил размер иконки (было 20)
                ),
                const SizedBox(width: 10), // Увеличил отступ (было 8)
                Text(
                  AppLocalizations.of(context).deleteNoteButtonText,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16, // Увеличил размер текста (было 14)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Построить тулбар над клавиатурой
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Кнопка вставки изображений
            IconButton(
              onPressed: insertImage,
              icon: const Icon(Icons.attach_file),
              tooltip: AppLocalizations.of(context).addImageTooltip,
            ),
            
            // Разделитель
            Container(
              width: 1,
              height: 24,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            
            // Основные кнопки форматирования
            QuillToolbarToggleStyleButton(
              controller: _controller,
              attribute: Attribute.bold,
            ),
            QuillToolbarToggleStyleButton(
              controller: _controller,
              attribute: Attribute.italic,
            ),
            QuillToolbarToggleStyleButton(
              controller: _controller,
              attribute: Attribute.underline,
            ),
            
            // Разделитель
            Container(
              width: 1,
              height: 24,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
            
            // Выравнивание
            QuillToolbarSelectAlignmentButton(
              controller: _controller,
            ),
            
            // Очистить форматирование
            QuillToolbarClearFormatButton(
              controller: _controller,
            ),
          ],
        ),
      ),
    );
  }
}

/// Кастомный embed builder для отображения изображений в Quill
class ImageEmbedBuilder extends EmbedBuilder {
  final Map<String, Uint8List> imageCache;
  final String? noteKey;
  final Function(String imageId)? onImageTap;

  ImageEmbedBuilder({
    required this.imageCache,
    this.noteKey,
    this.onImageTap,
  });

  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final data = embedContext.node.value.data as Map<String, dynamic>;
    final imageId = data['imageId'] as String;
    final imagePath = data['imagePath'] as String;
    
    // Получаем изображение из кэша или загружаем из файла
    Uint8List? imageBytes = imageCache[imageId];
    
    if (imageBytes == null) {
      // Если нет в кэше, загружаем из файла
      return FutureBuilder<Uint8List>(
        future: _loadImageBytes(imagePath),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            imageCache[imageId] = snapshot.data!;
            return _buildImageWidget(snapshot.data!, imageId);
          } else if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Ошибка загрузки изображения',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }
    
    return _buildImageWidget(imageBytes, imageId);
  }

  /// Загрузить байты изображения (зашифрованного или незашифрованного)
  Future<Uint8List> _loadImageBytes(String imagePath) async {
    // Проверяем, зашифрован ли файл (по расширению .enc)
    final isEncrypted = imagePath.endsWith('.enc');
    
    if (isEncrypted && noteKey != null) {
      // Зашифрованное изображение - расшифровываем
      final imageService = ImageService();
      final decryptedBytes = await imageService.decryptImage(imagePath, noteKey!);
      if (decryptedBytes != null) {
        return decryptedBytes;
      } else {
        throw Exception('Не удалось расшифровать изображение');
      }
    } else {
      // Незашифрованное изображение - читаем напрямую
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        final bytes = await imageFile.readAsBytes();
        return bytes;
      } else {
        throw Exception('Файл изображения не найден');
      }
    }
  }
  
  Widget _buildImageWidget(Uint8List imageBytes, String imageId) {
    return GestureDetector(
      onTap: () {
        onImageTap?.call(imageId);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: null, // Убираем фиксированную высоту
          ),
        ),
      ),
    );
  }
} 