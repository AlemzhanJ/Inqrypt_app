import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../encryption/presentation/widgets/quill_note_editor.dart';
import '../../../encryption/presentation/widgets/qr_display_widget.dart';
import '../../../encryption/domain/entities/note_image.dart';
import '../../../../shared/services/vibration_service.dart';
import '../../../../shared/services/notification_service.dart';
import '../../core/demo_constants.dart';
import 'demo_scanner_page.dart';

/// Демо-страница заметки для App Review
class DemoNotePage extends StatefulWidget {
  const DemoNotePage({super.key});

  @override
  State<DemoNotePage> createState() => _DemoNotePageState();
}

class _DemoNotePageState extends State<DemoNotePage> {
  final GlobalKey<QuillNoteEditorState> _editorKey = GlobalKey<QuillNoteEditorState>();
  
  Map<String, dynamic> _currentContent = {};
  List<NoteImage> _currentImages = [];
  bool _isEditing = true;
  bool _showQR = false;

  @override
  void initState() {
    super.initState();
    _initializeDemoContent();
  }

  void _initializeDemoContent() {
    // Создаем демо-контент в формате, который ожидает QuillNoteEditor
    setState(() {
      _currentContent = {
        "ops": [
          {"insert": "${AppLocalizations.of(context).demoNoteText}\n"}
        ]
      };
      _currentImages = [];
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        title: Text(
          l10n.notePageTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          // Показываем галочку только в режиме редактирования
          if (_isEditing && !_showQR)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                onPressed: () => _toggleEditMode(),
                icon: const Icon(Icons.check),
                tooltip: l10n.tooltipPreview,
              ),
            ),
        ],
      ),
      body: _showQR 
        ? _buildQRDisplay()
        : _buildNoteEditor(),
    );
  }

  Widget _buildNoteEditor() {
    return QuillNoteEditor(
      key: _editorKey,
      initialContent: _currentContent,
      initialImages: _currentImages,
      isReadOnly: false,
      isEditingMode: _isEditing,
      isExistingNote: false,
      onChanged: (content, images) {
        setState(() {
          _currentContent = content;
          _currentImages = images;
        });
      },
      onEncryptPressed: _showEncryptDialog,
      onEditModeChanged: (isEditing) {
        setState(() {
          _isEditing = isEditing;
        });
      },
    );
  }

  Widget _buildQRDisplay() {
    final l10n = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Заголовок
          Text(
            l10n.qrCreatedMessage,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Описание
          Text(
            l10n.qrDescription,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // QR-код используя существующий виджет
          QRDisplayWidget(
            data: DemoConstants.demoQRCode,
            showSaveButton: false,
          ),
          
          const SizedBox(height: 32),
          
          // Кнопка сканирования
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _scanQR(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(DemoConstants.demoButtonColor),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    l10n.scanButtonText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEditMode() async {
    await VibrationService().successVibration();
    if (_editorKey.currentState != null) {
      _editorKey.currentState!.toggleEditMode();
    }
  }

  void _showEncryptDialog() async {
    final navigatorContext = context;
    final confirmed = await showDialog<bool>(
      context: navigatorContext,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(navigatorContext).confirmEncryptNoteTitle),
        content: Text(AppLocalizations.of(navigatorContext).confirmEncryptNoteContent),
        actions: [
          TextButton(
            onPressed: () async {
              await VibrationService().navigationBackVibration();
              if (navigatorContext.mounted) {
                Navigator.of(navigatorContext).pop(false);
              }
            },
            child: Text(AppLocalizations.of(navigatorContext).cancelButtonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(navigatorContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(navigatorContext).encryptButtonText),
          ),
        ],
      ),
    );

    if (confirmed == true && navigatorContext.mounted) {
      _encryptNote();
    }
  }

  void _encryptNote() async {
    final navigatorContext = context;
    await VibrationService().noteCreatedVibration();
    if (navigatorContext.mounted) {
      await NotificationService().showSuccess(
        context: navigatorContext,
        message: AppLocalizations.of(navigatorContext).qrCreatedMessage,
      );
    }
    
    setState(() {
      _showQR = true;
    });
  }

  void _scanQR(BuildContext context) async {
    final navigatorContext = context;
    await VibrationService().navigationForwardVibration();
    
    if (navigatorContext.mounted) {
      Navigator.of(navigatorContext).push(
        MaterialPageRoute(
          builder: (context) => DemoScannerPage(
            content: _currentContent,
            images: _currentImages,
          ),
        ),
      );
    }
  }
} 