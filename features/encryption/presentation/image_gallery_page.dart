import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../domain/entities/note_image.dart';
import '../../../shared/services/vibration_service.dart';
import '../../../core/localization/app_localizations.dart';

/// Страница галереи изображений
class ImageGalleryPage extends StatefulWidget {
  final List<NoteImage> images;
  final int initialIndex;
  final Map<String, Uint8List> imageCache;
  final bool isReadOnly;
  final Function(String imageId) onImageRemoved;

  const ImageGalleryPage({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.imageCache,
    required this.isReadOnly,
    required this.onImageRemoved,
  });

  @override
  State<ImageGalleryPage> createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).imageGalleryCounter(_currentIndex + 1, widget.images.length)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await VibrationService().navigationBackVibration();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final image = widget.images[index];
          final imageData = widget.imageCache[image.id];

          return Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: imageData != null
                  ? Image.memory(
                      imageData,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  /// Показать диалог удаления изображения
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).confirmDeleteImage),
        content: Text(AppLocalizations.of(context).confirmDeleteImageContent),
        actions: [
          TextButton(
            onPressed: () async {
              await VibrationService().navigationBackVibration();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(AppLocalizations.of(context).cancelButtonText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final imageId = widget.images[_currentIndex].id;
              widget.onImageRemoved(imageId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context).tooltipDelete),
          ),
        ],
      ),
    );
  }
} 