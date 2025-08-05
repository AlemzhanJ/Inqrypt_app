import 'app_localizations.dart';

/// English localization for the application
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn(super.locale);

  @override
  String get appName => 'Inqrypt';
  
  @override
  String get appDescription => 'Ultra-private QR notes app';
  
  @override
  String get appVersion => '1.0.0';
  
  // Buttons
  @override
  String get encryptButtonText => 'Encrypt';
  
  @override
  String get decryptButtonText => 'Decrypt';
  
  @override
  String get scanButtonText => 'Scan QR';
  
  @override
  String get saveButtonText => 'Save';
  
  @override
  String get deleteButtonText => 'Delete Key';
  
  @override
  String get generateButtonText => 'Generate Key';
  
  @override
  String get cancelButtonText => 'Cancel';
  
  @override
  String get confirmButtonText => 'Confirm';
  
  @override
  String get backButtonText => 'Back';
  
  @override
  String get editButtonText => 'Edit';
  
  @override
  String get previewButtonText => 'Preview';
  
  @override
  String get addImageButtonText => 'Add Image';
  
  // Page titles
  @override
  String get homePageTitle => 'Inqrypt';
  
  @override
  String get notePageTitle => 'Note';
  
  @override
  String get scannerPageTitle => 'QR Scanner';
  
  @override
  String get masterKeyPageTitle => 'Encryption Key';
  
  @override
  String get encryptionPageTitle => 'Encryption';
  
  @override
  String get keyManagementPageTitle => 'Key Management';
  
  // Home page
  @override
  String get welcomeTitle => 'Welcome to Inqrypt';
  
  @override
  String get noteActionTitle => 'Note';
  
  @override
  String get noteActionSubtitle => 'Create encrypted note';
  
  @override
  String get scanActionTitle => 'Scan QR';
  
  @override
  String get scanActionSubtitle => 'Read note';
  
  @override
  String get masterKeyActionTitle => 'Encryption key';
  
  @override
  String get masterKeyActionSubtitle => 'Encryption key management';
  
  @override
  String get deleteAllNotesTitle => 'Delete All Notes';
  
  @override
  String get deleteAllNotesSubtitle => '';
  
  // Home page - additional elements
  @override
  String get securityStatusTitle => 'Security';
  
  @override
  String get securityStatusDescription => 'App works completely offline';
  
  @override
  String get actionsTitle => 'Actions';
  
  @override
  String get createNoteActionTitle => 'Note';
  
  @override
  String get createNoteActionDescription => 'Create encrypted note';
  
  @override
  String get scanQrActionTitle => 'Scan QR';
  
  @override
  String get scanQrActionDescription => 'Read note';
  
  @override
  String get masterKeyActionDescription => 'Biometric protection management';
  
  @override
  String get deleteAllNotesActionTitle => 'Delete All Notes';
  
  // Delete notes dialogs
  @override
  String get deleteAllNotesDialogTitle => 'Delete All Notes?';
  
  @override
  String get deleteAllNotesDialogContent => 'This action will permanently delete ALL encrypted notes. This action cannot be undone.\n\nContinue?';
  
  @override
  String get deleteAllNotesDialogCancelButton => 'Cancel';
  
  @override
  String get deleteAllNotesDialogConfirmButton => 'Delete All';
  
  @override
  String get deleteAllNotesAuthenticationReason => 'Confirm deletion of all notes';
  
  @override
  String get deleteAllNotesAuthenticationError => 'Authentication failed';
  
  // Input fields
  @override
  String get titleInputHint => 'Enter note title...';
  
  @override
  String get titleInputLabel => 'Title';
  
  @override
  String get contentInputHint => 'Enter note content...';
  
  @override
  String get contentInputLabel => 'Content';
  
  @override
  String get noteEditorPlaceholder => 'Start writing here...';
  
  @override
  String get addImageTooltip => 'Add image';
  
  // Messages
  @override
  String get qrCodeGenerated => 'QR code generated';
  
  @override
  String get qrCodeSaved => 'QR code saved to gallery';
  
  @override
  String get textDecrypted => 'Text decrypted';
  
  @override
  String get keyGenerated => 'New key generated';
  
  @override
  String get keyDeleted => 'Key deleted';
  
  @override
  String get noteEncrypted => 'Note encrypted';
  
  @override
  String get noteSaved => 'Note saved';
  
  @override
  String get noteDeleted => 'Note deleted';
  
  @override
  String get notesDeleted => 'Notes deleted';
  
  @override
  String get imageAdded => 'Image added';
  
  @override
  String get imageDeleted => 'Image deleted';
  
  @override
  String get noteFound => 'Note found';
  
  @override
  String get noteNotFound => 'Note not found';
  
  // Errors
  @override
  String get errorEmptyText => 'Enter text to encrypt';
  
  @override
  String get errorTextTooLong => 'Text is too long';
  
  @override
  String get errorNoKey => 'Key not found. Generate a new key';
  
  @override
  String get errorDecryptionFailed => 'Failed to decrypt. Check the key';
  
  @override
  String get errorInvalidQR => 'Invalid QR code';
  
  @override
  String get errorPermissionDenied => 'Camera permission not granted';
  
  @override
  String get errorSaveFailed => 'Failed to save QR code';
  
  @override
  String get errorAuthenticationFailed => 'Authentication failed';
  
  @override
  String get errorMasterKeyAccess => 'Failed to access encryption key';
  
  @override
  String get errorNoteEmpty => 'Note cannot be empty';
  
  @override
  String get errorImageLoad => 'Failed to load image';
  
  @override
  String get errorImageEncrypt => 'Failed to encrypt image';
  
  @override
  String get errorImageDecrypt => 'Failed to decrypt image';
  
  @override
  String get errorDeleteFailed => 'Failed to delete';
  
  // Confirmations
  @override
  String get confirmDeleteKey => 'Are you sure you want to delete the key? All encrypted QR codes will become unreadable.';
  
  @override
  String get confirmGenerateKey => 'Creating a new key will delete the old one. All previous QR codes will become unreadable.';
  
  @override
  String get confirmEncryptNote => 'This action will encrypt this note and you will never be able to read it again without the QR code. Continue?';
  
  @override
  String get confirmEncryptNoteTitle => 'Encrypt this note?';
  
  @override
  String get confirmEncryptNoteContent => 'This action will encrypt this note and you will never be able to read it again without the QR code. Continue?';
  
  @override
  String get confirmSaveNoteTitle => 'Save changes?';
  
  @override
  String get confirmSaveNoteContent => 'This action will save changes to the note. The old version will be replaced with the new one. Continue?';
  
  @override
  String get confirmDeleteAllNotes => 'This action will permanently delete ALL encrypted notes. This action cannot be undone.\n\nContinue?';
  
  @override
  String get confirmDeleteNote => 'Are you sure you want to delete this note?';
  
  @override
  String get confirmDeleteImage => 'Are you sure you want to delete this image?';
  
  // Dialogs
  @override
  String get selectImageTitle => 'Select Image';
  
  @override
  String get galleryOption => 'Gallery';
  
  @override
  String get cameraOption => 'Camera';
  
  @override
  String get cameraSubtitle => 'Photo will not be saved to gallery';
  
  // Biometrics
  @override
  String get biometricReason => 'Confirm access to notes';
  
  @override
  String get biometricDeleteReason => 'Confirm deletion of all notes';
  
  @override
  String get biometricLocked => 'Biometrics locked after failed attempts';
  
  @override
  String get biometricNotAvailable => 'Biometrics not available on this device';
  
  @override
  String get biometricNotEnrolled => 'Biometrics not enrolled on this device';
  
  // Status
  @override
  String get statusBiometricAvailable => 'Biometrics available';
  
  @override
  String get statusBiometricNotAvailable => 'Biometrics not available';
  
  @override
  String get statusMasterKeyExists => 'Encryption key exists';
  
  @override
  String get statusMasterKeyNotExists => 'Encryption key does not exist';
  
  @override
  String get statusScanning => 'Scanning...';
  
  @override
  String get statusNotScanning => 'Not scanning';
  
  @override
  String get statusLoading => 'Loading...';
  
  @override
  String get statusReady => 'Ready';
  
  // Information
  @override
  String get infoKeySize => 'Key size';
  
  @override
  String get infoEncryptionType => 'Encryption type';
  
  @override
  String get infoNoteCount => 'Note count';
  
  @override
  String get infoImageCount => 'Image count';
  
  @override
  String get infoLastModified => 'Last modified';
  
  @override
  String get infoCreated => 'Created';
  
  // Tooltips
  @override
  String get tooltipEdit => 'Edit';
  
  @override
  String get tooltipPreview => 'Preview';
  
  @override
  String get tooltipAddImage => 'Add image';
  
  @override
  String get tooltipEncrypt => 'Encrypt';
  
  @override
  String get tooltipScan => 'Scan';
  
  @override
  String get tooltipStop => 'Stop';
  
  @override
  String get tooltipCopy => 'Copy';
  
  @override
  String get tooltipShare => 'Share';
  
  @override
  String get tooltipSave => 'Save';
  
  @override
  String get tooltipDelete => 'Delete';
  
  // Files
  @override
  String get keyFileName => 'inqrypt_key.dat';
  
  @override
  String get qrFileName => 'inqrypt_qr_';
  
  @override
  String get imageFileName => 'inqrypt_image_';
  
  // Settings
  @override
  String get settingsTitle => 'Settings';
  
  @override
  String get settingsLanguage => 'Language';
  
  @override
  String get settingsTheme => 'Theme';
  
  @override
  String get settingsBiometric => 'Biometrics';
  
  @override
  String get settingsSecurity => 'Security';
  
  @override
  String get settingsAbout => 'About';
  
  // About
  @override
  String get aboutTitle => 'About';
  
  @override
  String get aboutVersion => 'Version';
  
  @override
  String get aboutBuild => 'Build';
  
  @override
  String get aboutCopyright => '© 2024 Inqrypt. All rights reserved.';
  
  @override
  String get aboutPrivacy => 'Privacy Policy';
  
  @override
  String get aboutTerms => 'Terms of Service';
  
  // Methods with parameters
  @override
  String deleteAllNotesSuccessMessage(int count) => 'Notes deleted: $count';
  
  @override
  String deleteAllNotesError(String error) => 'Delete error: $error';
  
  // Encryption
  @override
  String get encryptTextTitle => 'Encrypt Text';
  
  @override
  String get decryptTextTitle => 'Decrypt Text';
  
  @override
  String get textInputHint => 'Enter text to encrypt...';
  
  @override
  String get textInputLabel => 'Text';
  
  @override
  String get decryptInputHint => 'Enter encrypted data...';
  
  @override
  String get decryptInputLabel => 'Encrypted Data';
  
  @override
  String get encryptedDataLabel => 'Encrypted Data:';
  
  @override
  String get decryptedTextLabel => 'Decrypted Text:';
  
  @override
  String get dataCopiedMessage => 'Data copied';
  
  @override
  String get textCopiedMessage => 'Text copied';
  
  @override
  String get copyTooltip => 'Copy';
  
  // Encryption Key
  @override
  String get masterKeyCreated => 'Encryption key successfully created';
  
  @override
  String get masterKeyDeleted => 'Encryption key deleted';
  
  @override
  String get deleteMasterKeyTitle => 'Delete Encryption Key';
  
  @override
  String get deleteMasterKeyMessage => 'Are you sure you want to delete the encryption key? This action cannot be undone, and all notes will become unavailable.';
  
  @override
  String get deleteMasterKeyButton => 'Delete';
  
  // Encryption Key - additional strings
  @override
  String get biometricProtectionTitle => 'Biometric Protection';
  
  @override
  String get biometricAvailable => 'Face ID / Touch ID available';
  
  @override
  String get biometricChecking => 'Checking...';
  
  @override
  String get masterKeyTitle => 'Encryption Key';
  
  @override
  String get masterKeyCreatedAndProtected => 'Created and protected by biometrics';
  
  @override
  String get masterKeyNotCreated => 'Not created';
  
  @override
  String get masterKeyCreatedDate => 'Created: {date}';
  
  @override
  String get masterKeyActionsTitle => 'Actions';
  
  @override
  String get createMasterKeyButton => 'Create Encryption Key';
  
  @override
  String get deleteMasterKeyButtonText => 'Delete Encryption Key';
  
  // QR Scanner
  @override
  String get scannerInstruction => 'Point the camera at the QR code';
  
  @override
  String get scannerInstructionNote => 'of the note';
  
  @override
  String get scannerInstructionApp => 'The QR code must be created in this application';
  
  // QR Scanner - additional strings
  @override
  String get noteFoundTitle => 'Note Found';
  
  @override
  String get qrCodeProcessedSuccessfully => 'QR code successfully processed';
  
  @override
  String get titleLabel => 'Title:';
  
  @override
  String get contentLabel => 'Content:';
  
  @override
  String get contentCopiedMessage => 'Content copied to clipboard';
  
  @override
  String get copyContentButtonText => 'Copy content';
  
  @override
  String get informationTitle => 'Information';
  
  @override
  String get createdLabel => 'Created: {date}';
  
  @override
  String get modifiedLabel => 'Modified: {date}';
  
  @override
  String get imagesCountLabel => 'Images: {count}';
  
  @override
  String get scanMoreButton => 'Scan More';
  
  @override
  String get backButton => 'Back';
  
  // Biometric messages
  @override
  String get biometricAccessReason => 'Confirm access to notes';
  
  // QR code after encryption
  @override
  String get qrCodeCreatedSuccessfully => 'QR code for note access successfully created!';
  
  @override
  String get qrCodeTitle => 'QR Code';
  
  @override
  String get copyButtonText => 'Copy';
  
  @override
  String get shareButtonText => 'Share';
  
  @override
  String get dataCopiedToClipboard => 'Data copied to clipboard';
  
  @override
  String get qrCodeShared => 'QR code shared successfully';
  
  // Demo mode
  @override
  String get scanningMessage => 'Scanning...';
  
  @override
  String get noteFoundMessage => 'Note found!';
  
  @override
  String get demoModeScanningMessage => 'Demo mode: Simulated scanning';
  
  @override
  String get demoModeNoteSavedMessage => 'Demo mode: Note saved';
  
  // Demo mode - additional strings
  @override
  String get demoNoteText => 'This is your note, click the checkmark\n\nHere you can add your text or edit existing.';
  
  @override
  String get qrCreatedMessage => 'QR code created!';
  
  @override
  String get qrDescription => 'Scan this QR code to find the note';
  
  @override
  String get demoInfoTitle => 'Demo mode';
  
  @override
  String get demoInfoDescription => 'This is a demo version for App Review. In the real app, the QR code will contain encrypted data.';
} 