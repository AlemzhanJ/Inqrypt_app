import 'package:flutter/material.dart';
import 'vibration_service.dart';

/// Типы уведомлений для определения вибрации
enum NotificationType {
  success,   // Зеленые уведомления
  warning,   // Оранжевые уведомления
  error,     // Красные уведомления
  info,      // Информационные уведомления
}

/// Сервис для показа уведомлений с вибрацией
/// Автоматически добавляет тактильную обратную связь к уведомлениям
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final VibrationService _vibrationService = VibrationService();

  /// Показывает уведомление с автоматической вибрацией
  /// 
  /// [context] - контекст для показа SnackBar
  /// [message] - текст уведомления
  /// [type] - тип уведомления (определяет цвет и вибрацию)
  /// [duration] - продолжительность показа (по умолчанию 3 секунды)
  Future<void> showNotification({
    required BuildContext context,
    required String message,
    required NotificationType type,
    Duration? duration,
  }) async {
    // Определяем цвет фона в зависимости от типа
    Color backgroundColor;
    switch (type) {
      case NotificationType.success:
        backgroundColor = Colors.green;
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange;
        break;
      case NotificationType.error:
        backgroundColor = Colors.red;
        break;
      case NotificationType.info:
        backgroundColor = Colors.blue;
        break;
    }

    // Показываем уведомление
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: backgroundColor,
          duration: duration ?? const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          elevation: 0, // Убираем тени
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    // Добавляем вибрацию в зависимости от типа
    switch (type) {
      case NotificationType.success:
        await _vibrationService.successVibration();
        break;
      case NotificationType.warning:
        await _vibrationService.warningVibration();
        break;
      case NotificationType.error:
        await _vibrationService.errorVibration();
        break;
      case NotificationType.info:
        await _vibrationService.successVibration(); // Используем success для info
        break;
    }
  }

  /// Показывает уведомление об успехе (зеленая вибрация)
  Future<void> showSuccess({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) async {
    await showNotification(
      context: context,
      message: message,
      type: NotificationType.success,
      duration: duration,
    );
  }

  /// Показывает предупреждение (оранжевая вибрация)
  Future<void> showWarning({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) async {
    await showNotification(
      context: context,
      message: message,
      type: NotificationType.warning,
      duration: duration,
    );
  }

  /// Показывает ошибку (красная вибрация)
  Future<void> showError({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) async {
    await showNotification(
      context: context,
      message: message,
      type: NotificationType.error,
      duration: duration,
    );
  }

  /// Показывает информационное уведомление
  Future<void> showInfo({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) async {
    await showNotification(
      context: context,
      message: message,
      type: NotificationType.info,
      duration: duration,
    );
  }
} 