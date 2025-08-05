import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

/// Делегат локализации для Flutter
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Поддерживаем русский и английский языки
    return ['ru', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Возвращаем соответствующую локализацию
    switch (locale.languageCode) {
      case 'ru':
        return AppLocalizationsRu(locale);
      case 'en':
      default:
        return AppLocalizationsEn(locale);
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;

  /// Получить список поддерживаемых локалей
  static const List<Locale> supportedLocales = [
    Locale('ru', 'RU'), // Русский
    Locale('en', 'US'), // Английский
  ];

  /// Получить локаль по умолчанию
  static const Locale defaultLocale = Locale('en', 'US');
} 