import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/services/vibration_service.dart';
import 'demo_note_view_page.dart';
import '../../core/demo_constants.dart';

/// Демо-страница сканера для App Review
class DemoScannerPage extends StatefulWidget {
  final Map<String, dynamic> content;
  final List<dynamic> images;
  
  const DemoScannerPage({
    super.key,
    required this.content,
    required this.images,
  });

  @override
  State<DemoScannerPage> createState() => _DemoScannerPageState();
}

class _DemoScannerPageState extends State<DemoScannerPage> with TickerProviderStateMixin {
  MobileScannerController? _cameraController;
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;
  bool _showingSuccessAnimation = false;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController();
    
    // Инициализируем анимацию успеха
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Запускаем демо-последовательность
    _startDemoSequence();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  void _startDemoSequence() async {
    // Имитация сканирования
    await Future.delayed(Duration(milliseconds: DemoConstants.scanningDelay));
    if (mounted) {
      _showSuccessAnimation();
    }
  }

  /// Показать анимацию успеха
  void _showSuccessAnimation() async {
    setState(() {
      _showingSuccessAnimation = true;
      _isScanning = false;
    });
    
    // Вибрация успеха
    await VibrationService().successVibration();
    
    // Запускаем анимацию
    await _successAnimationController.forward();
    
    // Ждем немного и переходим на страницу заметки
    await Future.delayed(const Duration(milliseconds: 250));
    
    if (mounted) {
      _navigateToNotePage();
    }
  }

  /// Переход на страницу заметки
  void _navigateToNotePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DemoNoteViewPage(
          content: widget.content,
          images: widget.images,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
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
          IconButton(
            icon: Icon(
              _isScanning ? Icons.stop : Icons.play_arrow,
            ),
            tooltip: _isScanning ? l10n.tooltipStop : l10n.tooltipScan,
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          
          // Анимация успеха
          if (_showingSuccessAnimation)
            _buildSuccessAnimation(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Камера
        Expanded(
          child: _buildCameraView(),
        ),
        
        // Инструкции
        _buildInstructions(),
      ],
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Демо-камера (замоканная)
        Container(
          color: Colors.black,
          child: Stack(
            children: [
              // QR-код в фиксированной позиции
              Positioned(
                top: MediaQuery.of(context).size.height * 0.18, // Поднимаем QR-код выше
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: QrImageView(
                      data: DemoConstants.demoQRCode,
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
              // Индикатор сканирования внизу
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.25,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      if (_isScanning) ...[
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).scanningMessage,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            l10n.demoModeScanningMessage,
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
                  color: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.qrCodeProcessedSuccessfully,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
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