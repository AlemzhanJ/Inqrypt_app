import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/master_key_controller.dart';
import '../../../../shared/services/biometric_service.dart';
import '../../../../shared/services/notification_service.dart';
import '../../../../shared/services/vibration_service.dart';
import '../../data/repositories/master_key_repository_impl.dart';
import '../../data/datasources/secure_master_key_storage.dart';

/// Страница управления мастер-ключом
class MasterKeyPage extends StatefulWidget {
  const MasterKeyPage({super.key});

  @override
  State<MasterKeyPage> createState() => _MasterKeyPageState();
}

class _MasterKeyPageState extends State<MasterKeyPage> {
  late final MasterKeyController _controller;
  bool _isBiometricAvailable = false;
  String _biometricStatusMessage = 'Проверка...';

  @override
  void initState() {
    super.initState();
    _controller = MasterKeyController(_getRepository());
    _checkBiometricAvailability();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    final statusMessage = await BiometricService.getBiometricStatusMessage();
    setState(() {
      _isBiometricAvailable = isAvailable;
      _biometricStatusMessage = statusMessage;
    });
  }

  // TODO: Заменить на dependency injection
  dynamic _getRepository() {
    final storage = SecureMasterKeyStorage();
    return MasterKeyRepositoryImpl(storage);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(l10n.masterKeyPageTitle),
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
        ),
        body: Consumer<MasterKeyController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Статус биометрии
                  _buildBiometricStatus(),
                  const SizedBox(height: 24),
                  
                  // Статус мастер-ключа
                  _buildMasterKeyStatus(controller),
                  const SizedBox(height: 24),
                  
                  // Действия
                  _buildActions(controller),
                  
                  // Ошибки
                  if (controller.error != null) ...[
                    const SizedBox(height: 24),
                    _buildErrorCard(controller.error!),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBiometricStatus() {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isBiometricAvailable 
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isBiometricAvailable ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isBiometricAvailable ? Icons.fingerprint : Icons.error,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.biometricProtectionTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isBiometricAvailable 
                    ? l10n.biometricAvailable
                    : _biometricStatusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterKeyStatus(MasterKeyController controller) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.hasMasterKey 
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controller.hasMasterKey ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              controller.hasMasterKey ? Icons.security : Icons.warning,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.masterKeyTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.hasMasterKey 
                    ? l10n.masterKeyCreatedAndProtected
                    : l10n.masterKeyNotCreated,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                if (controller.hasMasterKey && controller.masterKey != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.masterKeyCreatedDate.replaceAll('{date}', _formatDate(controller.masterKey!.createdAt)),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(MasterKeyController controller) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.masterKeyActionsTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        if (!controller.hasMasterKey) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isBiometricAvailable ? () => _createMasterKey(controller) : null,
              icon: const Icon(Icons.add),
              label: Text(l10n.createMasterKeyButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _deleteMasterKey(controller),
              icon: const Icon(Icons.delete),
              label: Text(l10n.deleteMasterKeyButtonText),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
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
              error,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _createMasterKey(MasterKeyController controller) async {
    final l10n = AppLocalizations.of(context);
    final success = await controller.createMasterKey();
    if (success) {
      if (mounted) {
        await NotificationService().showSuccess(
          context: context,
          message: l10n.masterKeyCreated,
        );
      }
    }
  }

  Future<void> _deleteMasterKey(MasterKeyController controller) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMasterKeyTitle),
        content: Text(l10n.deleteMasterKeyMessage),
        actions: [
          TextButton(
            onPressed: () async {
              await VibrationService().navigationBackVibration();
              if (context.mounted) {
                Navigator.of(context).pop(false);
              }
            },
            child: Text(l10n.cancelButtonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deleteMasterKeyButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller.deleteMasterKey();
      if (success && mounted) {
        await NotificationService().showWarning(
          context: context,
          message: l10n.masterKeyDeleted,
        );
      }
    }
  }
} 