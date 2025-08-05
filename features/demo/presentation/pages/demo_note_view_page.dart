import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/services/vibration_service.dart';
import '../../../encryption/presentation/widgets/quill_note_editor.dart';
import '../../../encryption/domain/entities/note_image.dart';

/// Демо-страница просмотра найденной заметки
class DemoNoteViewPage extends StatefulWidget {
  final Map<String, dynamic> content;
  final List<dynamic> images;
  
  const DemoNoteViewPage({
    super.key,
    required this.content,
    required this.images,
  });

  @override
  State<DemoNoteViewPage> createState() => _DemoNoteViewPageState();
}

class _DemoNoteViewPageState extends State<DemoNoteViewPage> {
  final GlobalKey<QuillNoteEditorState> _editorKey = GlobalKey<QuillNoteEditorState>();
  
  Map<String, dynamic> _currentContent = {};
  List<NoteImage> _currentImages = [];
  bool _isEditing = true;

  @override
  void initState() {
    super.initState();
    _initializeDemoContent();
  }

  void _initializeDemoContent() {
    // Используем переданный контент
    setState(() {
      _currentContent = widget.content;
      _currentImages = widget.images.cast<NoteImage>();
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.notePageTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await VibrationService().navigationBackVibration();
            if (context.mounted) {
              // Возвращаемся на главную страницу, убирая весь стек навигации
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
        // Убираем actions - нет галочки
      ),
      body: _buildEditor(),
    );
  }

  Widget _buildEditor() {
    return QuillNoteEditor(
      key: _editorKey,
      initialContent: _currentContent,
      initialImages: _currentImages,
      isReadOnly: false, // Разрешаем редактирование
      isEditingMode: _isEditing, // В режиме редактирования
      isExistingNote: true, // Это найденная заметка
      onChanged: (content, images) {
        setState(() {
          _currentContent = content;
          _currentImages = images;
        });
      },
      // Убираем onSavePressed и onEditModeChanged
    );
  }
} 