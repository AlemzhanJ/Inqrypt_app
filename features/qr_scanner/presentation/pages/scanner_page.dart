import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/scanner_controller.dart';
import '../../../encryption/data/repositories/note_repository_impl.dart';
import '../../../encryption/data/repositories/master_key_repository_impl.dart';
import '../../../encryption/data/datasources/note_storage.dart';
import '../../../encryption/data/datasources/secure_master_key_storage.dart';
import '../../../encryption/presentation/pages/note_page.dart';
import '../../../encryption/presentation/controllers/note_controller.dart';
import '../../../../shared/services/vibration_service.dart';

/// Страница сканера QR-кодов
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with TickerProviderStateMixin {
  late final ScannerController _controller;
  MobileScannerController? _cameraController;
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;
  bool _showingSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = ScannerController(_getNoteRepository(), _getMasterKeyRepository());
    _cameraController = MobileScannerController();
    
    // Инициализируем анимацию успеха
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Ускорили еще больше (было 750)
      vsync: this,
    );
    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.easeOut, // Более быстрая кривая для отзывчивости
    ));
    
    // Слушаем изменения в контроллере
    _controller.addListener(_onControllerChanged);
    
    // Передаем контроллер заметок в контроллер сканера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteController = Provider.of<NoteController>(context, listen: false);
      _controller.setNoteController(noteController);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _cameraController?.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  // TODO: Заменить на dependency injection
  dynamic _getNoteRepository() {
    final storage = NoteStorage();
    return NoteRepositoryImpl(storage);
  }

  dynamic _getMasterKeyRepository() {
    final storage = SecureMasterKeyStorage();
    return MasterKeyRepositoryImpl(storage);
  }

  /// Обработчик изменений в контроллере
  void _onControllerChanged() {
    if (_controller.hasResults && !_showingSuccessAnimation) {
      _showSuccessAnimation();
    }
  }

  /// Показать анимацию успеха
  void _showSuccessAnimation() async {
    setState(() {
      _showingSuccessAnimation = true;
    });
    
    // Вибрация успеха
    await VibrationService().successVibration();
    
    // Запускаем анимацию
    await _successAnimationController.forward();
    
    // Ждем немного и переходим на страницу заметки
    await Future.delayed(const Duration(milliseconds: 250)); // Ускорили еще больше (было 250)
    
    if (mounted) {
      _navigateToNotePage();
    }
  }

  /// Переход на страницу заметки
  void _navigateToNotePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const NotePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(l10n.scannerPageTitle),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
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
            Consumer<ScannerController>(
              builder: (context, controller, child) {
                return IconButton(
                  icon: Icon(
                    controller.isScanning ? Icons.stop : Icons.play_arrow,
                  ),
                  tooltip: controller.isScanning ? l10n.tooltipStop : l10n.tooltipScan,
                  onPressed: () {
                    if (controller.isScanning) {
                      controller.stopScanning();
                      _cameraController?.stop();
                    } else {
                      controller.startScanning();
                      _cameraController?.start();
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Consumer<ScannerController>(
              builder: (context, controller, child) {
                return _buildBody(controller);
              },
            ),
            
            // Анимация успеха
            if (_showingSuccessAnimation)
              _buildSuccessAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ScannerController controller) {
    return Column(
      children: [
        // Камера
        Expanded(
          child: _buildCameraView(controller),
        ),
        
        // Ошибка (если есть)
        if (controller.error != null) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
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
                    controller.error!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.clearResults();
                    controller.startScanning();
                    _cameraController?.start();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Попробовать снова',
                ),
              ],
            ),
          ),
        ],
        
        // Инструкции
        _buildInstructions(),
      ],
    );
  }

  Widget _buildCameraView(ScannerController controller) {
    return Stack(
      children: [
        MobileScanner(
          controller: _cameraController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                final l10n = AppLocalizations.of(context);
                controller.processQRCode(barcode.rawValue!, l10n);
                break;
              }
            }
          },
        ),
        
        // Оверлей сканера
        _buildScannerOverlay(),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
      ),
      child: Center(
        child: SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            children: [
              // Угловые рамки
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 4),
                      left: BorderSide(color: Colors.white, width: 4),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 4),
                      right: BorderSide(color: Colors.white, width: 4),
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white, width: 4),
                      left: BorderSide(color: Colors.white, width: 4),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white, width: 4),
                      right: BorderSide(color: Colors.white, width: 4),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.scannerInstruction} ${l10n.scannerInstructionNote}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scannerInstructionApp,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Построить анимацию успеха
  Widget _buildSuccessAnimation() {
    final l10n = AppLocalizations.of(context);
    
    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.7 * _successAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _successAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noteFoundTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.qrCodeProcessedSuccessfully,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 