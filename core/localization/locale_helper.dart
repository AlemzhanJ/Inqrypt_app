import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_localizations_delegate.dart';

/// Утилита для работы с локализацией
class LocaleHelper {
  /// Получить локаль системы
  static Locale getSystemLocale() {
    final String systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    
    // Если система на русском, возвращаем русский
    if (systemLocale == 'ru') {
      return const Locale('ru', 'RU');
    }
    
    // Для всех остальных языков возвращаем английский
    return const Locale('en', 'US');
  }
  
  /// Получить локаль из настроек или системы
  static Future<Locale> getLocale() async {
    try {
      // В будущем здесь можно добавить сохранение выбранного языка
      // final prefs = await SharedPreferences.getInstance();
      // final savedLocale = prefs.getString(_localeKey);
      // if (savedLocale != null) {
      //   return Locale(savedLocale);
      // }
      
      return getSystemLocale();
    } catch (e) {
      // В случае ошибки возвращаем английский
      return const Locale('en', 'US');
    }
  }
  
  /// Сохранить выбранную локаль
  static Future<void> setLocale(Locale locale) async {
    try {
      // В будущем здесь можно добавить сохранение выбранного языка
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
  }
  
  /// Получить список поддерживаемых локалей
  static List<Locale> getSupportedLocales() {
    return AppLocalizationsDelegate.supportedLocales;
  }
  
  /// Проверить, поддерживается ли локаль
  static bool isLocaleSupported(Locale locale) {
    return AppLocalizationsDelegate.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }
  
  /// Получить локализацию для указанной локали
  static AppLocalizations getLocalizations(Locale locale) {
    return AppLocalizations.ofLocale(locale);
  }
  
  /// Получить название языка
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return 'English';
    }
  }
  
  /// Получить флаг языка (эмодзи)
  static String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return '🇷🇺';
      case 'en':
        return '🇺🇸';
      default:
        return '🇺🇸';
    }
  }
  
  /// Получить направление текста для локали
  static TextDirection getTextDirection(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
      case 'en':
      default:
        return TextDirection.ltr;
    }
  }
  
  /// Получить формат даты для локали
  static String getDateFormat(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return 'dd.MM.yyyy';
      case 'en':
      default:
        return 'MM/dd/yyyy';
    }
  }
  
  /// Получить формат времени для локали
  static String getTimeFormat(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return 'HH:mm';
      case 'en':
      default:
        return 'h:mm a';
    }
  }
  
  /// Получить формат даты и времени для локали
  static String getDateTimeFormat(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return 'dd.MM.yyyy HH:mm';
      case 'en':
      default:
        return 'MM/dd/yyyy h:mm a';
    }
  }
} 