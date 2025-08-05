import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/design_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/encryption_controller.dart';
import '../widgets/text_input_widget.dart';
import '../widgets/qr_display_widget.dart';
import '../widgets/key_info_widget.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../../shared/services/vibration_service.dart';
import '../../data/repositories/encryption_repository.dart';
import '../../data/datasources/local_key_storage.dart';

/// Страница шифрования с полным функционалом
class EncryptionPage extends StatefulWidget {
  const EncryptionPage({super.key});

  @override
  State<EncryptionPage> createState() => _EncryptionPageState();
}

class _EncryptionPageState extends State<EncryptionPage> {
  late final EncryptionController _controller;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _decryptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = EncryptionController(
      EncryptionRepository(LocalKeyStorage()),
      AppLocalizations.of(context),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _decryptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.encryptionPageTitle),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
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
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.refresh(),
            ),
          ],
        ),
        body: Consumer<EncryptionController>(
          builder: (context, controller, child) {
            return _buildBody(controller, l10n);
          },
        ),
      ),
    );
  }

  Widget _buildBody(EncryptionController controller, AppLocalizations l10n) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статус ключа
          _buildKeyStatus(controller),
          const SizedBox(height: DesignConstants.largePadding),

          // Информация о ключе
          if (controller.hasKey) ...[
            KeyInfoWidget(keyInfo: controller.keyInfo),
            const SizedBox(height: DesignConstants.largePadding),
          ],

          // Шифрование
          _buildEncryptionSection(controller, l10n),
          const SizedBox(height: DesignConstants.largePadding),

          // Расшифровка
          _buildDecryptionSection(controller, l10n),
          const SizedBox(height: DesignConstants.largePadding),

          // QR код (если есть зашифрованные данные)
          if (controller.encryptedData.isNotEmpty) ...[
            QRDisplayWidget(data: controller.encryptedData),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyStatus(EncryptionController controller) {
    return Container(
      width: double.infinity,
        padding: const EdgeInsets.all(DesignConstants.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
        child: Row(
          children: [
            Icon(
              controller.hasKey ? Icons.security : Icons.warning,
              color: controller.hasKey ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: DesignConstants.smallPadding),
            Expanded(
              child: Text(
                controller.hasKey 
                  ? 'Ключ шифрования активен'
                  : 'Ключ шифрования не найден',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildEncryptionSection(EncryptionController controller, AppLocalizations l10n) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.encryptTextTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DesignConstants.padding),
            
            TextInputWidget(
              controller: _textController,
              hint: l10n.textInputHint,
              label: l10n.textInputLabel,
              onChanged: controller.setInputText,
              maxLines: 5,
            ),
            
            const SizedBox(height: DesignConstants.padding),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
            onPressed: controller.hasKey ? () {
              FocusScope.of(context).unfocus(); // Скрываем клавиатуру
              controller.encryptText();
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: DesignConstants.buttonVerticalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.encryptButtonText),
              ),
            ),
            
            if (controller.encryptedData.isNotEmpty) ...[
              const SizedBox(height: DesignConstants.padding),
              Container(
                padding: const EdgeInsets.all(DesignConstants.smallPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(DesignConstants.smallPadding),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.encryptedDataLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: controller.encryptedData));
                        if (mounted) {
                          await NotificationService().showSuccess(
                            context: context,
                            message: l10n.dataCopiedMessage,
                          );
                        }
                      },
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: l10n.copyTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: DesignConstants.smallPadding),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DesignConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                      controller.encryptedData,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    textAlign: TextAlign.start,
                  ),
                    ),
                  ],
                ),
              ),
            ],
          ],
    );
  }

  Widget _buildDecryptionSection(EncryptionController controller, AppLocalizations l10n) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.decryptTextTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DesignConstants.padding),
            
            TextInputWidget(
              controller: _decryptController,
              hint: l10n.decryptInputHint,
              label: l10n.decryptInputLabel,
              onChanged: (value) {}, // Обработка в кнопке
              maxLines: 3,
            ),
            
            const SizedBox(height: DesignConstants.padding),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
            onPressed: controller.hasKey ? () {
              FocusScope.of(context).unfocus(); // Скрываем клавиатуру
              controller.decryptText(_decryptController.text);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: DesignConstants.buttonVerticalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.decryptButtonText),
              ),
            ),
            
            if (controller.decryptedText.isNotEmpty) ...[
              const SizedBox(height: DesignConstants.padding),
              Container(
                padding: const EdgeInsets.all(DesignConstants.smallPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(DesignConstants.smallPadding),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.decryptedTextLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: controller.decryptedText));
                        if (mounted) {
                          await NotificationService().showSuccess(
                            context: context,
                            message: l10n.textCopiedMessage,
                          );
                        }
                      },
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: l10n.copyTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: DesignConstants.smallPadding),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DesignConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    controller.decryptedText,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
        ),
        ],
        ],
    );
  }
} 