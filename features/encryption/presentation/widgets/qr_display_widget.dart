import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../shared/services/notification_service.dart';
import '../../../../core/localization/app_localizations.dart';

/// Виджет для отображения QR кода
class QRDisplayWidget extends StatefulWidget {
  final String data;
  final bool showSaveButton;

  const QRDisplayWidget({
    super.key,
    required this.data,
    this.showSaveButton = true,
  });

  @override
  State<QRDisplayWidget> createState() => _QRDisplayWidgetState();
}

class _QRDisplayWidgetState extends State<QRDisplayWidget> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.qrCodeTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
            
            Center(
            child: RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: QrImageView(
                  data: widget.data,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
                ),
              ),
            ),
            
          const SizedBox(height: 20),
            
          // Кнопки действий
            Row(
              children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy,
                  label: l10n.copyButtonText,
                  onTap: () => _copyToClipboard(context),
                ),
              ),
              if (widget.showSaveButton) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.save_alt,
                    label: l10n.saveButtonText,
                    onTap: () => _saveToGallery(context),
                    isLoading: _isSaving,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.share,
                  label: l10n.shareButtonText,
                  onTap: () => _shareQR(context),
                ),
            ),
          ],
        ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final navigatorContext = context;
    await Clipboard.setData(ClipboardData(text: widget.data));
    if (navigatorContext.mounted) {
      await NotificationService().showSuccess(
        context: navigatorContext,
        message: l10n.dataCopiedToClipboard,
      );
    }
  }

  Future<void> _saveToGallery(BuildContext context) async {
    final navigatorContext = context;
    
    // Временно отключено
    await NotificationService().showInfo(
      context: navigatorContext,
      message: 'Функция сохранения в галерею временно недоступна',
    );
    
    // TODO: Восстановить после решения конфликта зависимостей
    /*
    setState(() {
      _isSaving = true;
    });

    try {
      // Создаем изображение из QR кода
      final Uint8List? imageBytes = await _captureQRImage();
      
      if (imageBytes != null) {
        // Создаем временный файл
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/inqrypt_qr_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(imageBytes);

        // Сохраняем в галерею
        final result = await GallerySaver.saveImage(tempFile.path);

        if (result == true && navigatorContext.mounted) {
          await NotificationService().showSuccess(
            context: navigatorContext,
            message: l10n.qrCodeSaved,
          );
        } else {
          throw Exception(l10n.errorSaveFailed);
        }
      }
    } catch (e) {
      if (navigatorContext.mounted) {
        await NotificationService().showError(
          context: navigatorContext,
          message: '${l10n.errorSaveFailed}: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
    */
  }

  Future<void> _shareQR(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final navigatorContext = context;
    try {
      // Создаем изображение из QR кода
      final Uint8List? imageBytes = await _captureQRImage();
      
      if (imageBytes != null) {
        // Создаем временный файл для шаринга
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/inqrypt_qr_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(imageBytes);

        // Шарим изображение
        await Share.shareXFiles(
          [XFile(tempFile.path)],
          text: l10n.qrCodeShared,
        );
      }
    } catch (e) {
      if (navigatorContext.mounted) {
        await NotificationService().showError(
          context: navigatorContext,
          message: '${l10n.errorSaveFailed}: ${e.toString()}',
        );
      }
    }
  }

  Future<Uint8List?> _captureQRImage() async {
    try {
      final RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}

/// Упрощенный виджет для отображения QR-кода после шифрования
class SimpleQRDisplayWidget extends StatefulWidget {
  final String data;

  const SimpleQRDisplayWidget({
    super.key,
    required this.data,
  });

  @override
  State<SimpleQRDisplayWidget> createState() => _SimpleQRDisplayWidgetState();
}

class _SimpleQRDisplayWidgetState extends State<SimpleQRDisplayWidget> {
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        // Сообщение об успешном создании
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.qrCodeCreatedSuccessfully,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // QR-код
        Center(
          child: RepaintBoundary(
            key: _qrKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: QrImageView(
                data: widget.data,
                version: QrVersions.auto,
                size: 250,
                backgroundColor: Colors.white,
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Кнопки действий
        Row(
          children: [
            Expanded(
              child: _SimpleActionButton(
                icon: Icons.copy,
                label: l10n.copyButtonText,
                onTap: () => _copyToClipboard(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SimpleActionButton(
                icon: Icons.share,
                label: l10n.shareButtonText,
                onTap: () => _shareQR(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final navigatorContext = context;
    await Clipboard.setData(ClipboardData(text: widget.data));
    if (navigatorContext.mounted) {
      await NotificationService().showSuccess(
        context: navigatorContext,
        message: l10n.dataCopiedToClipboard,
      );
    }
  }

  Future<void> _shareQR(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final navigatorContext = context;
    try {
      // Создаем изображение из QR кода
      final Uint8List? imageBytes = await _captureQRImage();
      
      if (imageBytes != null) {
        // Создаем временный файл для шаринга
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/inqrypt_qr_${DateTime.now().millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(imageBytes);

        // Шарим изображение
        await Share.shareXFiles(
          [XFile(tempFile.path)],
          text: l10n.qrCodeShared,
        );
      }
    } catch (e) {
      if (navigatorContext.mounted) {
        await NotificationService().showError(
          context: navigatorContext,
          message: '${l10n.errorSaveFailed}: ${e.toString()}',
        );
      }
    }
  }

  Future<Uint8List?> _captureQRImage() async {
    try {
      final RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Фиксированная высота для всех кнопок
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Упрощенная кнопка действия
class _SimpleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SimpleActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 