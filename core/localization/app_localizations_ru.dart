import 'app_localizations.dart';

/// Русская локализация приложения
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu(super.locale);

  @override
  String get appName => 'Inqrypt';
  
  @override
  String get appDescription => 'Ультра-приватное приложение для QR-заметок';
  
  @override
  String get appVersion => '1.0.0';
  
  // Кнопки
  @override
  String get encryptButtonText => 'Зашифровать';
  
  @override
  String get decryptButtonText => 'Расшифровать';
  
  @override
  String get scanButtonText => 'Сканировать QR';
  
  @override
  String get saveButtonText => 'Сохранить';
  
  @override
  String get deleteButtonText => 'Удалить ключ';
  
  @override
  String get generateButtonText => 'Сгенерировать ключ';
  
  @override
  String get cancelButtonText => 'Отмена';
  
  @override
  String get confirmButtonText => 'Подтвердить';
  
  @override
  String get backButtonText => 'Назад';
  
  @override
  String get editButtonText => 'Редактировать';
  
  @override
  String get previewButtonText => 'Предпросмотр';
  
  @override
  String get addImageButtonText => 'Добавить изображение';
  
  // Заголовки страниц
  @override
  String get homePageTitle => 'Inqrypt';
  
  @override
  String get notePageTitle => 'Заметка';
  
  @override
  String get scannerPageTitle => 'Сканер QR';
  
  @override
  String get masterKeyPageTitle => 'Ключ шифрования';
  
  @override
  String get encryptionPageTitle => 'Шифрование';
  
  @override
  String get keyManagementPageTitle => 'Управление ключом';
  
  // Главная страница
  @override
  String get welcomeTitle => 'Добро пожаловать в Inqrypt';
  
  @override
  String get noteActionTitle => 'Заметка';
  
  @override
  String get noteActionSubtitle => 'Создать зашифрованную заметку';
  
  @override
  String get scanActionTitle => 'Сканировать QR';
  
  @override
  String get scanActionSubtitle => 'Прочитать заметку';
  
  @override
  String get masterKeyActionTitle => 'Ключ шифрования';
  
  @override
  String get masterKeyActionSubtitle => 'Управление биометрической защитой';
  
  @override
  String get deleteAllNotesTitle => 'Удалить все заметки';
  
  @override
  String get deleteAllNotesSubtitle => '';
  
  // Удаление последней заметки
  @override
  String get deleteLastNoteTitle => 'Удалить последнюю заметку';
  
  @override
  String get deleteLastNoteSubtitle => '';
  
  @override
  String get deleteLastNoteActionTitle => 'Удалить последнюю заметку';
  
  @override
  String get deleteLastNoteDialogTitle => 'Удалить последнюю заметку?';
  
  @override
  String get deleteLastNoteDialogContent => 'Это действие безвозвратно удалит последнюю созданную заметку. Это действие нельзя отменить.\n\nПродолжить?';
  
  @override
  String get deleteLastNoteDialogCancelButton => 'Отмена';
  
  @override
  String get deleteLastNoteDialogConfirmButton => 'Удалить';
  
  @override
  String get deleteLastNoteAuthenticationReason => 'Подтвердите удаление последней заметки';
  
  @override
  String get deleteLastNoteAuthenticationError => 'Аутентификация не удалась';
  
  @override
  String get deleteLastNoteNoNotesMessage => 'Нет заметок для удаления';
  
  @override
  String get deleteLastNoteSuccessMessage => 'Последняя заметка удалена';
  
  @override
  String get deleteLastNoteError => 'Ошибка удаления последней заметки';
  
  // Главная страница - дополнительные элементы
  @override
  String get securityStatusTitle => 'Безопасность';
  
  @override
  String get securityStatusDescription => 'Приложение работает полностью офлайн';
  
  @override
  String get actionsTitle => 'Действия';
  
  @override
  String get createNoteActionTitle => 'Заметка';
  
  @override
  String get createNoteActionDescription => 'Создать зашифрованную заметку';
  
  @override
  String get scanQrActionTitle => 'Сканировать QR';
  
  @override
  String get scanQrActionDescription => 'Прочитать заметку';
  
  @override
  String get masterKeyActionDescription => 'Управление биометрической защитой';
  
  @override
  String get deleteAllNotesActionTitle => 'Удалить все заметки';
  
  // Диалоги удаления заметок
  @override
  String get deleteAllNotesDialogTitle => 'Удалить все заметки?';
  
  @override
  String get deleteAllNotesDialogContent => 'Это действие безвозвратно удалит ВСЕ зашифрованные заметки. Это действие нельзя отменить.\n\nПродолжить?';
  
  @override
  String get deleteAllNotesDialogCancelButton => 'Отмена';
  
  @override
  String get deleteAllNotesDialogConfirmButton => 'Удалить все';
  
  @override
  String get deleteAllNotesAuthenticationReason => 'Подтвердите удаление всех заметок';
  
  @override
  String get deleteAllNotesAuthenticationError => 'Аутентификация не удалась';
  
  // Поля ввода
  @override
  String get titleInputHint => 'Введите заголовок заметки...';
  
  @override
  String get titleInputLabel => 'Заголовок';
  
  @override
  String get contentInputHint => 'Введите содержимое заметки...';
  
  @override
  String get contentInputLabel => 'Содержимое';
  
  @override
  String get noteEditorPlaceholder => 'Начните писать здесь...';
  
  @override
  String get addImageTooltip => 'Добавить изображение';
  
  // Сообщения
  @override
  String get qrCodeGenerated => 'QR-код сгенерирован';
  
  @override
  String get qrCodeSaved => 'QR-код сохранен в галерею';
  
  @override
  String get textDecrypted => 'Текст расшифрован';
  
  @override
  String get keyGenerated => 'Новый ключ сгенерирован';
  
  @override
  String get keyDeleted => 'Ключ удален';
  
  @override
  String get noteEncrypted => 'Заметка зашифрована';
  
  @override
  String get noteSaved => 'Заметка сохранена';
  
  @override
  String get noteDeleted => 'Заметка удалена';
  
  @override
  String get notesDeleted => 'Заметки удалены';
  
  @override
  String get imageAdded => 'Изображение добавлено';
  
  @override
  String get imageDeleted => 'Изображение удалено';
  
  @override
  String get noteFound => 'Заметка найдена';
  
  @override
  String get noteNotFound => 'Заметка не найдена';
  
  // Ошибки
  @override
  String get errorEmptyText => 'Введите текст для шифрования';
  
  @override
  String get errorTextTooLong => 'Текст слишком длинный';
  
  @override
  String get errorNoKey => 'Ключ не найден. Сгенерируйте новый ключ';
  
  @override
  String get errorDecryptionFailed => 'Не удалось расшифровать. Проверьте ключ';
  
  @override
  String get errorInvalidQR => 'Неверный QR-код';
  
  @override
  String get errorPermissionDenied => 'Разрешение на камеру не предоставлено';
  
  @override
  String get errorSaveFailed => 'Не удалось сохранить QR-код';
  
  @override
  String get errorAuthenticationFailed => 'Аутентификация не удалась';
  
  @override
  String get errorMasterKeyAccess => 'Не удалось получить доступ к ключу шифрования';
  
  @override
  String get errorNoteEmpty => 'Заметка не может быть пустой';
  
  @override
  String get errorImageLoad => 'Не удалось загрузить изображение';
  
  @override
  String get errorImageEncrypt => 'Не удалось зашифровать изображение';
  
  @override
  String get errorImageDecrypt => 'Не удалось расшифровать изображение';
  
  @override
  String get errorDeleteFailed => 'Не удалось удалить';
  
  // Подтверждения
  @override
  String get confirmDeleteKey => 'Вы уверены, что хотите удалить ключ? Все зашифрованные QR-коды станут нечитаемыми.';
  
  @override
  String get confirmGenerateKey => 'Создание нового ключа удалит старый. Все предыдущие QR-коды станут нечитаемыми.';
  
  @override
  String get confirmEncryptNote => 'Это действие зашифрует эту заметку и вы больше никогда не сможете прочитать ее без QR-кода. Продолжить?';
  
  @override
  String get confirmEncryptNoteTitle => 'Зашифровать эту заметку?';
  
  @override
  String get confirmEncryptNoteContent => 'Это действие зашифрует эту заметку и вы больше никогда не сможете прочитать ее без QR-кода. Продолжить?';
  
  @override
  String get confirmSaveNoteTitle => 'Сохранить изменения?';
  
  @override
  String get confirmSaveNoteContent => 'Это действие сохранит изменения в заметке. Старая версия будет заменена новой. Продолжить?';
  
  @override
  String get confirmDeleteAllNotes => 'Это действие безвозвратно удалит ВСЕ зашифрованные заметки. Это действие нельзя отменить.\n\nПродолжить?';
  
  @override
  String get confirmDeleteNote => 'Вы уверены, что хотите удалить эту заметку?';
  
  @override
  String get deleteNoteDialogTitle => 'Удалить заметку?';
  
  @override
  String get deleteNoteDialogContent => 'Это действие безвозвратно удалит эту заметку. Это действие нельзя отменить.\n\nПродолжить?';
  
  @override
  String get deleteNoteDialogCancelButton => 'Отмена';
  
  @override
  String get deleteNoteDialogConfirmButton => 'Удалить';
  
  @override
  String get deleteNoteAuthenticationReason => 'Подтвердите удаление заметки';
  
  @override
  String get deleteNoteAuthenticationError => 'Аутентификация не удалась';
  
  @override
  String get deleteNoteSuccessMessage => 'Заметка удалена';
  
  @override
  String get deleteNoteError => 'Ошибка удаления заметки';
  
  @override
  String get deleteNoteButtonText => 'Удалить';
  
  @override
  String get confirmDeleteImage => 'Вы уверены, что хотите удалить это изображение?';
  
  @override
  String get confirmDeleteImageContent => 'Это действие нельзя отменить.';
  
  // Диалоги
  @override
  String get selectImageTitle => 'Выберите изображение';
  
  @override
  String get galleryOption => 'Галерея';
  
  @override
  String get cameraOption => 'Камера';
  
  @override
  String get cameraSubtitle => 'Фото не сохранится в галерею';
  
  // Биометрия
  @override
  String get biometricReason => 'Подтвердите доступ к заметкам';
  
  @override
  String get biometricDeleteReason => 'Подтвердите удаление всех заметок';
  
  @override
  String get biometricLocked => 'Биометрия заблокирована после неудачных попыток';
  
  @override
  String get biometricNotAvailable => 'Биометрия недоступна на этом устройстве';
  
  @override
  String get biometricNotEnrolled => 'Биометрия не настроена на этом устройстве';
  
  // Статус
  @override
  String get statusBiometricAvailable => 'Биометрия доступна';
  
  @override
  String get statusBiometricNotAvailable => 'Биометрия недоступна';
  
  @override
  String get statusMasterKeyExists => 'Ключ шифрования существует';
  
  @override
  String get statusMasterKeyNotExists => 'Ключ шифрования не существует';
  
  @override
  String get statusScanning => 'Сканирование...';
  
  @override
  String get statusNotScanning => 'Не сканирует';
  
  @override
  String get statusLoading => 'Загрузка...';
  
  @override
  String get statusReady => 'Готово';
  
  // Информация
  @override
  String get infoKeySize => 'Размер ключа';
  
  @override
  String get infoEncryptionType => 'Тип шифрования';
  
  @override
  String get infoNoteCount => 'Количество заметок';
  
  @override
  String get infoImageCount => 'Количество изображений';
  
  @override
  String get infoLastModified => 'Последнее изменение';
  
  @override
  String get infoCreated => 'Создано';
  
  // Подсказки
  @override
  String get tooltipEdit => 'Редактировать';
  
  @override
  String get tooltipPreview => 'Предпросмотр';
  
  @override
  String get tooltipAddImage => 'Добавить изображение';
  
  @override
  String get tooltipEncrypt => 'Зашифровать';
  
  @override
  String get tooltipScan => 'Сканировать';
  
  @override
  String get tooltipStop => 'Остановить';
  
  @override
  String get tooltipCopy => 'Копировать';
  
  @override
  String get tooltipShare => 'Поделиться';
  
  @override
  String get tooltipSave => 'Сохранить';
  
  @override
  String get tooltipDelete => 'Удалить';
  
  // Файлы
  @override
  String get keyFileName => 'inqrypt_key.dat';
  
  @override
  String get qrFileName => 'inqrypt_qr_';
  
  @override
  String get imageFileName => 'inqrypt_image_';
  
  // Настройки
  @override
  String get settingsTitle => 'Настройки';
  
  @override
  String get settingsLanguage => 'Язык';
  
  @override
  String get settingsTheme => 'Тема';
  
  @override
  String get settingsBiometric => 'Биометрия';
  
  @override
  String get settingsSecurity => 'Безопасность';
  
  @override
  String get settingsAbout => 'О приложении';
  
  // О приложении
  @override
  String get aboutTitle => 'О приложении';
  
  @override
  String get aboutVersion => 'Версия';
  
  @override
  String get aboutBuild => 'Сборка';
  
  @override
  String get aboutCopyright => '© 2024 Inqrypt. Все права защищены.';
  
  @override
  String get aboutPrivacy => 'Политика конфиденциальности';
  
  @override
  String get aboutTerms => 'Условия использования';
  
  // Методы с параметрами
  @override
  String deleteAllNotesSuccessMessage(int count) => 'Удалено заметок: $count';
  
  @override
  String deleteAllNotesError(String error) => 'Ошибка удаления: $error';
  
  // Шифрование
  @override
  String get encryptTextTitle => 'Шифрование текста';
  
  @override
  String get decryptTextTitle => 'Расшифровка текста';
  
  @override
  String get textInputHint => 'Введите текст для шифрования...';
  
  @override
  String get textInputLabel => 'Текст';
  
  @override
  String get decryptInputHint => 'Введите зашифрованные данные...';
  
  @override
  String get decryptInputLabel => 'Зашифрованные данные';
  
  @override
  String get encryptedDataLabel => 'Зашифрованные данные:';
  
  @override
  String get decryptedTextLabel => 'Расшифрованный текст:';
  
  @override
  String get dataCopiedMessage => 'Данные скопированы';
  
  @override
  String get textCopiedMessage => 'Текст скопирован';
  
  @override
  String get copyTooltip => 'Копировать';
  
  // Ключ шифрования
  @override
  String get masterKeyCreated => 'Ключ шифрования успешно создан';
  
  @override
  String get masterKeyDeleted => 'Ключ шифрования удален';
  
  @override
  String get deleteMasterKeyTitle => 'Удаление ключа шифрования';
  
  @override
  String get deleteMasterKeyMessage => 'Вы уверены, что хотите удалить ключ шифрования? Это действие нельзя отменить, и все заметки станут недоступны.';
  
  @override
  String get deleteMasterKeyButton => 'Удалить';
  
  // Ключ шифрования - дополнительные строки
  @override
  String get biometricProtectionTitle => 'Биометрическая защита';
  
  @override
  String get biometricAvailable => 'Face ID / Touch ID доступен';
  
  @override
  String get biometricChecking => 'Проверка...';
  
  @override
  String get masterKeyTitle => 'Ключ шифрования';
  
  @override
  String get masterKeyCreatedAndProtected => 'Создан и защищен биометрией';
  
  @override
  String get masterKeyNotCreated => 'Не создан';
  
  @override
  String get masterKeyCreatedDate => 'Создан: {date}';
  
  @override
  String get masterKeyActionsTitle => 'Действия';
  
  @override
  String get createMasterKeyButton => 'Создать ключ шифрования';
  
  @override
  String get deleteMasterKeyButtonText => 'Удалить ключ шифрования';
  
  // QR Сканер
  @override
  String get scannerInstruction => 'Наведите камеру на QR-код';
  
  @override
  String get scannerInstructionNote => 'заметки';
  
  @override
  String get scannerInstructionApp => 'QR-код должен быть создан в этом приложении';
  
  // QR Сканер - дополнительные строки
  @override
  String get noteFoundTitle => 'Заметка найдена';
  
  @override
  String get qrCodeProcessedSuccessfully => 'QR-код успешно обработан';
  
  @override
  String get titleLabel => 'Заголовок:';
  
  @override
  String get contentLabel => 'Содержимое:';
  
  @override
  String get contentCopiedMessage => 'Содержимое скопировано в буфер обмена';
  
  @override
  String get copyContentButtonText => 'Копировать содержимое';
  
  @override
  String get informationTitle => 'Информация';
  
  @override
  String get createdLabel => 'Создана: {date}';
  
  @override
  String get modifiedLabel => 'Изменена: {date}';
  
  @override
  String get imagesCountLabel => 'Изображений: {count}';
  
  @override
  String get scanMoreButton => 'Сканировать еще';
  
  @override
  String get backButton => 'Назад';
  
  // Биометрические сообщения
  @override
  String get biometricCreateReason => 'Подтвердите создание ключа шифрования';
  
  @override
  String get biometricAccessReason => 'Подтвердите доступ к заметкам';
  
  // QR-код после шифрования
  @override
  String get qrCodeCreatedSuccessfully => 'QR-код для доступа к заметке успешно создан!';
  
  @override
  String get qrCodeTitle => 'QR-код';
  
  @override
  String get copyButtonText => 'Копировать';
  
  @override
  String get shareButtonText => 'Поделиться';
  
  @override
  String get dataCopiedToClipboard => 'Данные скопированы в буфер обмена';
  
  @override
  String get qrCodeShared => 'QR-код поделен';
  
  // Демо-режим
  @override
  String get scanningMessage => 'Сканирование...';
  
  @override
  String get noteFoundMessage => 'Заметка найдена!';
  
  @override
  String get demoModeScanningMessage => 'Имитация сканирования';
  
  @override
  String get demoModeNoteSavedMessage => 'Демо-режим: Заметка сохранена';
  
  // Демо-режим - дополнительные строки
  @override
  String get demoNoteText => 'Это ваша заметка, нажмите на галочку\n\nЗдесь вы можете добавить свой текст или отредактировать существующий.';
  
  @override
  String get qrCreatedMessage => 'QR-код создан!';
  
  @override
  String get qrDescription => 'Отсканируйте этот QR-код, чтобы найти заметку';
  
  @override
  String get demoInfoTitle => 'Демо-режим';
  
  @override
  String get demoInfoDescription => 'Это демонстрационная версия для App Review. В реальном приложении QR-код будет содержать зашифрованные данные.';
  
  // Вставка текста
  @override
  String get pasteWithStyles => 'Вставить со стилями';
  
  @override
  String get pasteWithStylesDescription => 'Применить стили окружающего текста';
  
  @override
  String get pasteAsPlainText => 'Вставить как обычный текст';
  
  @override
  String get pasteAsPlainTextDescription => 'Без форматирования';
  
  // Галерея изображений
  @override
  String imageGalleryCounter(int current, int total) => '$current из $total';
  
  // Support Us
  @override
  String get supportUsTitle => 'Поддержать нас';
  
  @override
  String get supportUsDescription => 'Это добровольная поддержка. Покупка ничего не открывает — все функции бесплатны. Вы помогаете опенсорс-проекту жить.';
  
  @override
  String get supportUsButtonText => 'Поддержать нас';
  
  @override
  String get supporterBadgeText => 'Supporter';
  
  @override
  String get supporterThankYouMessage => 'Спасибо за поддержку Inqrypt!';
  
  @override
  String get purchaseSuccessMessage => 'Спасибо за вашу поддержку!';
  
  @override
  String get purchaseErrorMessage => 'Покупка не удалась. Попробуйте еще раз.';
  
  @override
  String get purchaseNotAvailableMessage => 'Встроенные покупки недоступны.';

  @override
  String get restorePurchasesButtonText => 'Восстановить покупки';

  @override
  String get processingText => 'Обработка...';

  @override
  String get purchasesRestoredMessage => 'Покупки восстановлены';
} 