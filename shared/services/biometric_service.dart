import 'package:local_auth/local_auth.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_helper.dart';
import 'vibration_service.dart';

/// Сервис для биометрической аутентификации
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final VibrationService _vibrationService = VibrationService();

  /// Проверить доступность биометрии
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Получить доступные типы биометрии
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Аутентификация с биометрией
  static Future<bool> authenticate({
    String? reason,
  }) async {
    try {
      // Получаем локаль для определения языка
      final locale = LocaleHelper.getSystemLocale();
      final l10n = AppLocalizations.ofLocale(locale);
      
      // Используем переданную причину или дефолтную
      final authReason = reason ?? l10n.biometricReason;
      
      // Проверяем доступность биометрии перед аутентификацией
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('Биометрия недоступна');
        return false;
      }

      // Получаем доступные типы биометрии
      final biometrics = await getAvailableBiometrics();
      print('Доступные типы биометрии: $biometrics');

      final result = await _localAuth.authenticate(
        localizedReason: authReason,
        options: const AuthenticationOptions(
          biometricOnly: true, // Только биометрия, без PIN
          stickyAuth: false, // Отключаем sticky auth для избежания проблем
        ),
      );
      
      print('Результат биометрической аутентификации: $result');
      
      // Добавляем вибрацию при успешной аутентификации
      if (result) {
        await _vibrationService.biometricVibration();
      }
      
      return result;
    } catch (e) {
      print('Ошибка биометрической аутентификации: $e');
      
      // Проверяем, не заблокирована ли биометрия
      if (e.toString().contains('NotAvailable') || e.toString().contains('Authentication failure')) {
        print('Биометрия заблокирована после неудачных попыток');
        // Можно показать пользователю сообщение о необходимости разблокировки
      }
      
      return false;
    }
  }

  /// Аутентификация с PIN-кодом
  static Future<bool> authenticateWithPin({
    String? reason,
  }) async {
    try {
      // Получаем локаль для определения языка
      final locale = LocaleHelper.getSystemLocale();
      final l10n = AppLocalizations.ofLocale(locale);
      
      // Используем переданную причину или дефолтную
      final authReason = reason ?? l10n.biometricReason;
      
      return await _localAuth.authenticate(
        localizedReason: authReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Проверить, поддерживается ли Face ID
  static Future<bool> isFaceIdSupported() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Проверить, поддерживается ли Touch ID
  static Future<bool> isTouchIdSupported() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Проверить, заблокирована ли биометрия
  static Future<bool> isBiometricLocked() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isEmpty;
    } catch (e) {
      return true;
    }
  }

  /// Получить сообщение о статусе биометрии
  static Future<String> getBiometricStatusMessage() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        final isLocked = await isBiometricLocked();
        if (isLocked) {
          return 'Биометрия заблокирована. Разблокируйте устройство и попробуйте снова.';
        }
        return 'Биометрия недоступна';
      }
      
      final biometrics = await getAvailableBiometrics();
      if (biometrics.contains(BiometricType.face)) {
        return 'Face ID доступен';
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Touch ID доступен';
      }
      
      return 'Биометрия доступна';
    } catch (e) {
      return 'Ошибка проверки биометрии';
    }
  }
} 