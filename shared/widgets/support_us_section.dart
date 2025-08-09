import 'package:flutter/material.dart';
import '../services/in_app_purchase_service.dart';
import '../../core/localization/app_localizations.dart';
import '../services/vibration_service.dart';
import '../services/notification_service.dart';
import 'dart:async';

/// Виджет секции Support Us
class SupportUsSection extends StatefulWidget {
  const SupportUsSection({super.key});

  @override
  State<SupportUsSection> createState() => _SupportUsSectionState();
}

class _SupportUsSectionState extends State<SupportUsSection> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  final NotificationService _notificationService = NotificationService();
  bool _isSupporter = false;
  bool _loading = true;
  bool _purchasing = false;
  StreamSubscription<bool>? _supporterSub;
  StreamSubscription<String>? _errorSub;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _purchaseService.initialize();
    final isSupporter = await _purchaseService.isSupporter();
    
    // Подписываемся на изменения статуса Supporter из сервиса
    _supporterSub = _purchaseService.supporterStream.listen((value) async {
      if (!mounted) return;
      setState(() {
        _isSupporter = value;
        _purchasing = false;
      });
      if (_isSupporter) {
        // Если статус пришёл после restore, тост уже покажется в _restorePurchases
      }
    });

    // Подписываемся на ошибки покупок
    _errorSub = _purchaseService.errorStream.listen((_) async {
      if (!mounted) return;
      setState(() => _purchasing = false);
      await _notificationService.showError(
        context: context,
        message: AppLocalizations.of(context).purchaseErrorMessage,
      );
    });

    if (mounted) {
      setState(() {
        _isSupporter = isSupporter;
        _loading = false;
      });
    }
  }

  Future<void> _buySupporter() async {
    if (!_purchaseService.isAvailable || _purchaseService.product == null) {
      if (mounted) {
        await _notificationService.showError(
          context: context,
          message: AppLocalizations.of(context).purchaseNotAvailableMessage,
        );
      }
      return;
    }

    setState(() => _purchasing = true);
    
    try {
      await VibrationService().navigationForwardVibration();
      await _purchaseService.buySupporter();
      
      // Обновляем статус после покупки
      final isSupporter = await _purchaseService.isSupporter();
      if (mounted) {
        setState(() {
          _isSupporter = isSupporter;
          _purchasing = false;
        });
        
        if (_isSupporter) {
          await _notificationService.showSuccess(
            context: context,
            message: AppLocalizations.of(context).purchaseSuccessMessage,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _purchasing = false);
        await _notificationService.showError(
          context: context,
          message: AppLocalizations.of(context).purchaseErrorMessage,
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (!_purchaseService.isAvailable) return;
    setState(() => _purchasing = true);
    try {
      await _purchaseService.restorePurchases();
      // Дальше ждём событие из supporterStream; как fallback проверим флаг через короткое время
      Future.delayed(const Duration(seconds: 1), () async {
        if (!mounted || _isSupporter) return;
        final isSupporter = await _purchaseService.isSupporter();
        if (!mounted) return;
        setState(() {
          _isSupporter = isSupporter;
          _purchasing = false;
        });
        if (_isSupporter && mounted) {
          await _notificationService.showSuccess(
            context: context,
            message: AppLocalizations.of(context).purchasesRestoredMessage,
          );
        }
      });
      // Если событие пришло быстро — покажем тост здесь
      if (_isSupporter && mounted) {
        await _notificationService.showSuccess(
          context: context,
          message: AppLocalizations.of(context).purchasesRestoredMessage,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _purchasing = false);
        await _notificationService.showError(
          context: context,
          message: AppLocalizations.of(context).purchaseErrorMessage,
        );
      }
    }
  }

  @override
  void dispose() {
    _supporterSub?.cancel();
    _errorSub?.cancel();
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_purchaseService.isAvailable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isSupporter) ...[
            // Описание
            Text(
              AppLocalizations.of(context).supportUsDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Кнопка покупки
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _purchasing ? null : _buySupporter,
              icon: _purchasing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.favorite),
              label: Text(
                _purchasing
                    ? AppLocalizations.of(context).processingText
                    : _purchaseService.product != null
                        ? '${AppLocalizations.of(context).supportUsButtonText} — ${_purchaseService.product!.price}'
                        : AppLocalizations.of(context).supportUsButtonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Кнопка восстановления покупок (обязательна для iOS)
            TextButton(
              onPressed: _purchasing ? null : _restorePurchases,
              child: Text(AppLocalizations.of(context).restorePurchasesButtonText),
            ),
          ] else ...[
            // Бейдж Supporter
            Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).supporterBadgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Сообщение благодарности
            Text(
              AppLocalizations.of(context).supporterThankYouMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 