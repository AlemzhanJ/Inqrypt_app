import 'package:flutter/material.dart';
import 'vibration_service.dart';

/// Сервис для навигации с автоматической тактильной обратной связью
/// Обеспечивает вибрацию при переходах между страницами
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final VibrationService _vibrationService = VibrationService();

  /// Переход на новую страницу с вибрацией
  Future<T?> push<T extends Object?>(BuildContext context, Widget page) async {
    await _vibrationService.navigationForwardVibration();
    if (context.mounted) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute<T>(
          builder: (context) => page,
        ),
      );
    }
    return null;
  }

  /// Переход на новую страницу с заменой текущей с вибрацией
  Future<T?> pushReplacement<T extends Object?>(BuildContext context, Widget page) async {
    await _vibrationService.navigationForwardVibration();
    if (context.mounted) {
      return Navigator.of(context).pushReplacement<T, void>(
        MaterialPageRoute<T>(
          builder: (context) => page,
        ),
      );
    }
    return null;
  }

  /// Возврат на предыдущую страницу с вибрацией
  void pop<T extends Object?>(BuildContext context, [T? result]) {
    _vibrationService.navigationBackVibration();
    Navigator.of(context).pop<T>(result);
  }

  /// Возврат на предыдущую страницу с вибрацией (асинхронная версия)
  Future<void> popAsync<T extends Object?>(BuildContext context, [T? result]) async {
    await _vibrationService.navigationBackVibration();
    if (context.mounted) {
      Navigator.of(context).pop<T>(result);
    }
  }

  /// Переход на главную страницу с вибрацией
  void popToHome(BuildContext context) {
    _vibrationService.navigationBackVibration();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Переход на главную страницу с вибрацией (асинхронная версия)
  Future<void> popToHomeAsync(BuildContext context) async {
    await _vibrationService.navigationBackVibration();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// Проверка, можно ли вернуться назад
  bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
} 