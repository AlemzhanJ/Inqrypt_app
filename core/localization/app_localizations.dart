import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

/// Основной класс локализации приложения
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  /// Получить экземпляр локализации для текущего контекста
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  /// Получить экземпляр локализации для указанной локали
  static AppLocalizations ofLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return AppLocalizationsRu(locale);
      case 'en':
      default:
        return AppLocalizationsEn(locale);
    }
  }
  
  /// Проверить, является ли текущий язык русским
  bool get isRussian => locale.languageCode == 'ru';
  
  /// Проверить, является ли текущий язык английским
  bool get isEnglish => locale.languageCode == 'en';
  
  /// Получить направление текста для текущего языка
  TextDirection get textDirection => isRussian ? TextDirection.ltr : TextDirection.ltr;
  
  // Методы для получения переведенных строк
  String get appName => throw UnimplementedError();
  String get appDescription => throw UnimplementedError();
  String get appVersion => throw UnimplementedError();
  
  // Кнопки
  String get encryptButtonText => throw UnimplementedError();
  String get decryptButtonText => throw UnimplementedError();
  String get scanButtonText => throw UnimplementedError();
  String get saveButtonText => throw UnimplementedError();
  String get deleteButtonText => throw UnimplementedError();
  String get generateButtonText => throw UnimplementedError();
  String get cancelButtonText => throw UnimplementedError();
  String get confirmButtonText => throw UnimplementedError();
  String get backButtonText => throw UnimplementedError();
  String get editButtonText => throw UnimplementedError();
  String get previewButtonText => throw UnimplementedError();
  String get addImageButtonText => throw UnimplementedError();
  
  // Заголовки страниц
  String get homePageTitle => throw UnimplementedError();
  String get notePageTitle => throw UnimplementedError();
  String get scannerPageTitle => throw UnimplementedError();
  String get masterKeyPageTitle => throw UnimplementedError();
  String get encryptionPageTitle => throw UnimplementedError();
  String get keyManagementPageTitle => throw UnimplementedError();
  
  // Главная страница
  String get welcomeTitle => throw UnimplementedError();
  String get noteActionTitle => throw UnimplementedError();
  String get noteActionSubtitle => throw UnimplementedError();
  String get scanActionTitle => throw UnimplementedError();
  String get scanActionSubtitle => throw UnimplementedError();
  String get masterKeyActionTitle => throw UnimplementedError();
  String get masterKeyActionSubtitle => throw UnimplementedError();
  String get deleteAllNotesTitle => throw UnimplementedError();
  String get deleteAllNotesSubtitle => throw UnimplementedError();
  
  // Главная страница - дополнительные элементы
  String get securityStatusTitle => throw UnimplementedError();
  String get securityStatusDescription => throw UnimplementedError();
  String get actionsTitle => throw UnimplementedError();
  String get createNoteActionTitle => throw UnimplementedError();
  String get createNoteActionDescription => throw UnimplementedError();
  String get scanQrActionTitle => throw UnimplementedError();
  String get scanQrActionDescription => throw UnimplementedError();
  String get masterKeyActionDescription => throw UnimplementedError();
  String get deleteAllNotesActionTitle => throw UnimplementedError();
  
  // Диалоги удаления заметок
  String get deleteAllNotesDialogTitle => throw UnimplementedError();
  String get deleteAllNotesDialogContent => throw UnimplementedError();
  String get deleteAllNotesDialogCancelButton => throw UnimplementedError();
  String get deleteAllNotesDialogConfirmButton => throw UnimplementedError();
  String get deleteAllNotesAuthenticationReason => throw UnimplementedError();
  String get deleteAllNotesAuthenticationError => throw UnimplementedError();
  
  // Поля ввода
  String get titleInputHint => throw UnimplementedError();
  String get titleInputLabel => throw UnimplementedError();
  String get contentInputHint => throw UnimplementedError();
  String get contentInputLabel => throw UnimplementedError();
  String get noteEditorPlaceholder => throw UnimplementedError();
  String get addImageTooltip => throw UnimplementedError();
  
  // Сообщения
  String get qrCodeGenerated => throw UnimplementedError();
  String get qrCodeSaved => throw UnimplementedError();
  String get textDecrypted => throw UnimplementedError();
  String get keyGenerated => throw UnimplementedError();
  String get keyDeleted => throw UnimplementedError();
  String get noteEncrypted => throw UnimplementedError();
  String get noteSaved => throw UnimplementedError();
  String get noteDeleted => throw UnimplementedError();
  String get notesDeleted => throw UnimplementedError();
  String get imageAdded => throw UnimplementedError();
  String get imageDeleted => throw UnimplementedError();
  String get noteFound => throw UnimplementedError();
  String get noteNotFound => throw UnimplementedError();
  
  // Ошибки
  String get errorEmptyText => throw UnimplementedError();
  String get errorTextTooLong => throw UnimplementedError();
  String get errorNoKey => throw UnimplementedError();
  String get errorDecryptionFailed => throw UnimplementedError();
  String get errorInvalidQR => throw UnimplementedError();
  String get errorPermissionDenied => throw UnimplementedError();
  String get errorSaveFailed => throw UnimplementedError();
  String get errorAuthenticationFailed => throw UnimplementedError();
  String get errorMasterKeyAccess => throw UnimplementedError();
  String get errorNoteEmpty => throw UnimplementedError();
  String get errorImageLoad => throw UnimplementedError();
  String get errorImageEncrypt => throw UnimplementedError();
  String get errorImageDecrypt => throw UnimplementedError();
  String get errorDeleteFailed => throw UnimplementedError();
  
  // Подтверждения
  String get confirmDeleteKey => throw UnimplementedError();
  String get confirmGenerateKey => throw UnimplementedError();
  String get confirmEncryptNote => throw UnimplementedError();
  String get confirmEncryptNoteTitle => throw UnimplementedError();
  String get confirmEncryptNoteContent => throw UnimplementedError();
  String get confirmSaveNoteTitle => throw UnimplementedError();
  String get confirmSaveNoteContent => throw UnimplementedError();
  String get confirmDeleteAllNotes => throw UnimplementedError();
  String get confirmDeleteNote => throw UnimplementedError();
  String get confirmDeleteImage => throw UnimplementedError();
  
  // Диалоги
  String get selectImageTitle => throw UnimplementedError();
  String get galleryOption => throw UnimplementedError();
  String get cameraOption => throw UnimplementedError();
  String get cameraSubtitle => throw UnimplementedError();
  
  // Биометрия
  String get biometricReason => throw UnimplementedError();
  String get biometricDeleteReason => throw UnimplementedError();
  String get biometricLocked => throw UnimplementedError();
  String get biometricNotAvailable => throw UnimplementedError();
  String get biometricNotEnrolled => throw UnimplementedError();
  
  // Статус
  String get statusBiometricAvailable => throw UnimplementedError();
  String get statusBiometricNotAvailable => throw UnimplementedError();
  String get statusMasterKeyExists => throw UnimplementedError();
  String get statusMasterKeyNotExists => throw UnimplementedError();
  String get statusScanning => throw UnimplementedError();
  String get statusNotScanning => throw UnimplementedError();
  String get statusLoading => throw UnimplementedError();
  String get statusReady => throw UnimplementedError();
  
  // Информация
  String get infoKeySize => throw UnimplementedError();
  String get infoEncryptionType => throw UnimplementedError();
  String get infoNoteCount => throw UnimplementedError();
  String get infoImageCount => throw UnimplementedError();
  String get infoLastModified => throw UnimplementedError();
  String get infoCreated => throw UnimplementedError();
  
  // Подсказки
  String get tooltipEdit => throw UnimplementedError();
  String get tooltipPreview => throw UnimplementedError();
  String get tooltipAddImage => throw UnimplementedError();
  String get tooltipEncrypt => throw UnimplementedError();
  String get tooltipScan => throw UnimplementedError();
  String get tooltipStop => throw UnimplementedError();
  String get tooltipCopy => throw UnimplementedError();
  String get tooltipShare => throw UnimplementedError();
  String get tooltipSave => throw UnimplementedError();
  String get tooltipDelete => throw UnimplementedError();
  
  // Файлы
  String get keyFileName => throw UnimplementedError();
  String get qrFileName => throw UnimplementedError();
  String get imageFileName => throw UnimplementedError();
  
  // Настройки
  String get settingsTitle => throw UnimplementedError();
  String get settingsLanguage => throw UnimplementedError();
  String get settingsTheme => throw UnimplementedError();
  String get settingsBiometric => throw UnimplementedError();
  String get settingsSecurity => throw UnimplementedError();
  String get settingsAbout => throw UnimplementedError();
  
  // О приложении
  String get aboutTitle => throw UnimplementedError();
  String get aboutVersion => throw UnimplementedError();
  String get aboutBuild => throw UnimplementedError();
  String get aboutCopyright => throw UnimplementedError();
  String get aboutPrivacy => throw UnimplementedError();
  String get aboutTerms => throw UnimplementedError();
  
  // Методы с параметрами
  String deleteAllNotesSuccessMessage(int count) => throw UnimplementedError();
  String deleteAllNotesError(String error) => throw UnimplementedError();
  
  // Шифрование
  String get encryptTextTitle => throw UnimplementedError();
  String get decryptTextTitle => throw UnimplementedError();
  String get textInputHint => throw UnimplementedError();
  String get textInputLabel => throw UnimplementedError();
  String get decryptInputHint => throw UnimplementedError();
  String get decryptInputLabel => throw UnimplementedError();
  String get encryptedDataLabel => throw UnimplementedError();
  String get decryptedTextLabel => throw UnimplementedError();
  String get dataCopiedMessage => throw UnimplementedError();
  String get textCopiedMessage => throw UnimplementedError();
  String get copyTooltip => throw UnimplementedError();
  
  // Ключ шифрования
  String get masterKeyCreated => throw UnimplementedError();
  String get masterKeyDeleted => throw UnimplementedError();
  String get deleteMasterKeyTitle => throw UnimplementedError();
  String get deleteMasterKeyMessage => throw UnimplementedError();
  String get deleteMasterKeyButton => throw UnimplementedError();
  
  // Ключ шифрования - дополнительные строки
  String get biometricProtectionTitle => throw UnimplementedError();
  String get biometricAvailable => throw UnimplementedError();
  String get biometricChecking => throw UnimplementedError();
  String get masterKeyTitle => throw UnimplementedError();
  String get masterKeyCreatedAndProtected => throw UnimplementedError();
  String get masterKeyNotCreated => throw UnimplementedError();
  String get masterKeyCreatedDate => throw UnimplementedError();
  String get masterKeyActionsTitle => throw UnimplementedError();
  String get createMasterKeyButton => throw UnimplementedError();
  String get deleteMasterKeyButtonText => throw UnimplementedError();
  
  // QR Сканер
  String get scannerInstruction => throw UnimplementedError();
  String get scannerInstructionNote => throw UnimplementedError();
  String get scannerInstructionApp => throw UnimplementedError();
  
  // QR Сканер - дополнительные строки
  String get noteFoundTitle => throw UnimplementedError();
  String get qrCodeProcessedSuccessfully => throw UnimplementedError();
  String get titleLabel => throw UnimplementedError();
  String get contentLabel => throw UnimplementedError();
  String get contentCopiedMessage => throw UnimplementedError();
  String get copyContentButtonText => throw UnimplementedError();
  String get informationTitle => throw UnimplementedError();
  String get createdLabel => throw UnimplementedError();
  String get modifiedLabel => throw UnimplementedError();
  String get imagesCountLabel => throw UnimplementedError();
  String get scanMoreButton => throw UnimplementedError();
  String get backButton => throw UnimplementedError();
  
  // Биометрические сообщения
  String get biometricCreateReason => throw UnimplementedError();
  String get biometricAccessReason => throw UnimplementedError();
  
  // QR-код после шифрования
  String get qrCodeCreatedSuccessfully => throw UnimplementedError();
  String get qrCodeTitle => throw UnimplementedError();
  String get copyButtonText => throw UnimplementedError();
  String get shareButtonText => throw UnimplementedError();
  String get dataCopiedToClipboard => throw UnimplementedError();
  String get qrCodeShared => throw UnimplementedError();
  
  // Демо-режим
  String get scanningMessage => throw UnimplementedError();
  String get noteFoundMessage => throw UnimplementedError();
  String get demoModeScanningMessage => throw UnimplementedError();
  String get demoModeNoteSavedMessage => throw UnimplementedError();
  
  // Демо-режим - дополнительные строки
  String get demoNoteText => throw UnimplementedError();
  String get qrCreatedMessage => throw UnimplementedError();
  String get qrDescription => throw UnimplementedError();
  String get demoInfoTitle => throw UnimplementedError();
  String get demoInfoDescription => throw UnimplementedError();
} 