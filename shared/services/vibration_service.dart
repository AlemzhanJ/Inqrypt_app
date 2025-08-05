import 'package:vibration/vibration.dart';

/// Сервис для управления вибрациями в приложении
/// Обеспечивает тактильную обратную связь для различных событий
class VibrationService {
  static final VibrationService _instance = VibrationService._internal();
  factory VibrationService() => _instance;
  VibrationService._internal();

  /// Проверяет, поддерживает ли устройство вибрацию
  Future<bool> get hasVibrator async {
    final hasVibrator = await Vibration.hasVibrator();
    return hasVibrator == true;
  }

  /// Вибрация для успешных действий (зеленые уведомления)
  /// Короткая одиночная вибрация
  Future<void> successVibration() async {
    if (await hasVibrator) {
      await Vibration.vibrate(duration: 100);
    }
  }

  /// Вибрация для предупреждений (оранжевые уведомления)
  /// Двойная короткая вибрация
  Future<void> warningVibration() async {
    if (await hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 100, 100, 100], // Пауза, вибрация, пауза, вибрация
        intensities: [0, 128, 0, 128], // Интенсивность для каждой вибрации
      );
    }
  }

  /// Вибрация для ошибок (красные уведомления)
  /// Тройная короткая вибрация
  Future<void> errorVibration() async {
    if (await hasVibrator) {
      await Vibration.vibrate(
        pattern: [0, 100, 100, 100, 100, 100], // Пауза, вибрация, пауза, вибрация, пауза, вибрация
        intensities: [0, 128, 0, 128, 0, 128], // Интенсивность для каждой вибрации
      );
    }
  }

  /// Вибрация для биометрической аутентификации
  /// Длинная вибрация
  Future<void> biometricVibration() async {
    if (await hasVibrator) {
      await Vibration.vibrate(duration: 200);
    }
  }

  /// Вибрация для создания заметки
  /// Средняя вибрация
  Future<void> noteCreatedVibration() async {
    if (await hasVibrator) {
      await Vibration.vibrate(duration: 150);
    }
  }

  /// Вибрация для навигации вперед (переход на новую страницу)
  /// Короткая вибрация с высокой интенсивностью
  Future<void> navigationForwardVibration() async {
    if (await hasVibrator) {
      await Vibration.vibrate(
        duration: 30,
        amplitude: 128, // 50% от максимума 255
      );
    }
  }

  /// Вибрация для навигации назад (возврат на предыдущую страницу)
  /// Короткая вибрация с низкой интенсивностью
  Future<void> navigationBackVibration() async {
    print('VibrationService: Проверяем поддержку вибрации...');
    final hasVibrator = await this.hasVibrator;
    print('VibrationService: Устройство поддерживает вибрацию: $hasVibrator');
    
    if (hasVibrator) {
      print('VibrationService: Запускаем вибрацию назад (50ms, 128 amplitude)');
      await Vibration.vibrate(
        duration: 30, // Увеличено с 30ms до 50ms
        amplitude: 110, // Увеличено с 96 до 128 (50% от максимума)
      );
      print('VibrationService: Вибрация назад завершена');
    } else {
      print('VibrationService: Устройство не поддерживает вибрацию');
    }
  }

  /// Остановка вибрации
  Future<void> cancelVibration() async {
    if (await hasVibrator) {
      await Vibration.cancel();
    }
  }
} 