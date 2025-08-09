import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:typed_data';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_image.dart';
import '../../../../shared/services/image_service.dart';
import '../../../../shared/services/vibration_service.dart';
import '../image_gallery_page.dart';
import '../controllers/note_controller.dart';
import 'package:provider/provider.dart';

/// Виджет для отображения содержимого заметки с изображениями
class NoteContentWidget extends StatefulWidget {
  final Note note;
  final String noteKey; // Ключ для расшифровки изображений
  final bool isReadOnly; // Только для чтения или редактирования

  const NoteContentWidget({
    super.key,
    required this.note,
    required this.noteKey,
    this.isReadOnly = true,
  });

  @override
  State<NoteContentWidget> createState() => _NoteContentWidgetState();
}

class _NoteContentWidgetState extends State<NoteContentWidget> {
  final Map<String, Uint8List?> _decryptedImages = {};
  final Map<String, bool> _loadingImages = {};
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _loadImages();
  }

  /// Инициализировать QuillController
  void _initializeController() {
    if (widget.note.content.isNotEmpty) {
      // Document.fromJson ожидает List<dynamic>, а не Map<String, dynamic>
      // Преобразуем Map в List для правильной работы с Quill Delta
      final deltaList = _convertMapToDeltaList(widget.note.content);
      _controller = QuillController(
        document: Document.fromJson(deltaList),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
  }

  /// Конвертировать Map в List для Document.fromJson
  List<dynamic> _convertMapToDeltaList(Map<String, dynamic> content) {
    // Если content уже является List, возвращаем как есть
    if (content.containsKey('ops') && content['ops'] is List) {
      return content['ops'] as List<dynamic>;
    }
    // Иначе создаем пустой Delta
    return [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Загрузить все изображения заметки
  Future<void> _loadImages() async {
    if (!widget.note.hasImages) return;

    for (final image in widget.note.images) {
      if (!_decryptedImages.containsKey(image.id)) {
        _setImageLoading(image.id, true);
        await _loadImage(image);
        _setImageLoading(image.id, false);
      }
    }
  }

  /// Загрузить конкретное изображение
  Future<void> _loadImage(NoteImage image) async {
    try {
      
      final imageService = ImageService();
      final decryptedBytes = await imageService.decryptImage(
        image.imagePath,
        widget.noteKey,
      );


      // Проверяем валидность данных изображения
      if (decryptedBytes != null && decryptedBytes.isNotEmpty) {
        // Проверяем, что это действительно изображение (начинается с JPEG/PNG сигнатур)
        bool isValidImage = false;
        if (decryptedBytes.length >= 2) {
          // JPEG: FF D8
          if (decryptedBytes[0] == 0xFF && decryptedBytes[1] == 0xD8) {
            isValidImage = true;
          }
          // PNG: 89 50 4E 47
          else if (decryptedBytes.length >= 4 && 
                   decryptedBytes[0] == 0x89 && 
                   decryptedBytes[1] == 0x50 && 
                   decryptedBytes[2] == 0x4E && 
                   decryptedBytes[3] == 0x47) {
            isValidImage = true;
          }
        }
        
        if (!isValidImage) {
        }
        
        if (mounted) {
          setState(() {
            _decryptedImages[image.id] = isValidImage ? decryptedBytes : null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _decryptedImages[image.id] = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _decryptedImages[image.id] = null;
        });
      }
    }
  }

  /// Установить состояние загрузки изображения
  void _setImageLoading(String imageId, bool loading) {
    if (mounted) {
      setState(() {
        _loadingImages[imageId] = loading;
      });
    }
  }

  /// Построить виджет изображения
  Widget _buildImageWidget(NoteImage image) {
    final isLoading = _loadingImages[image.id] ?? false;
    final imageData = _decryptedImages[image.id];
    

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _showImageGallery(image),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxHeight: 400, // Увеличиваем максимальную высоту
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isLoading
                ? Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : imageData != null
                    ? Image.memory(
                        imageData,
                        fit: BoxFit.contain, // Сохраняем пропорции
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  /// Показать галерею изображений
  void _showImageGallery(NoteImage selectedImage) async {
    if (!widget.note.hasImages) return;

    final navigatorContext = context;
    await VibrationService().navigationForwardVibration();
    if (navigatorContext.mounted) {
      Navigator.of(navigatorContext).push(
        MaterialPageRoute(
          builder: (context) => ImageGalleryPage(
            images: widget.note.images,
            initialIndex: widget.note.images.indexOf(selectedImage),
            imageCache: Map<String, Uint8List>.from(_decryptedImages),
            isReadOnly: widget.isReadOnly,
            onImageRemoved: (imageId) {
              // Удаляем изображение через контроллер
              final noteController = Provider.of<NoteController>(navigatorContext, listen: false);
              noteController.removeImage(imageId);
              
              // Закрываем галерею
              Navigator.of(navigatorContext).pop();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QuillEditor для отображения содержимого
          QuillEditor.basic(
            controller: _controller,
          ),
          
          // Изображения (если есть)
          if (widget.note.hasImages) ...[
            const SizedBox(height: 20),
            ...widget.note.sortedImages.map((image) => _buildImageWidget(image)),
          ],
        ],
      ),
    );
  }
} 