import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_localizations_delegate.dart';
import 'features/encryption/presentation/pages/note_page.dart';
import 'features/encryption/presentation/pages/master_key_page.dart';
import 'features/qr_scanner/presentation/pages/scanner_page.dart';
import 'features/demo/presentation/pages/demo_note_page.dart';
import 'features/demo/presentation/widgets/demo_action_button.dart';
import 'features/encryption/data/repositories/note_repository_impl.dart';
import 'features/encryption/data/repositories/master_key_repository_impl.dart';
import 'features/encryption/data/datasources/note_storage.dart';
import 'features/encryption/data/datasources/secure_master_key_storage.dart';
import 'features/encryption/presentation/controllers/note_controller.dart';
import 'features/encryption/presentation/controllers/master_key_controller.dart';
import 'shared/services/vibration_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/biometric_service.dart';

void main() {
  runApp(const InqryptApp());
}

class InqryptApp extends StatelessWidget {
  const InqryptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoteController(NoteRepositoryImpl(NoteStorage()))),
        ChangeNotifierProvider(create: (context) => MasterKeyController(MasterKeyRepositoryImpl(SecureMasterKeyStorage()))),
      ],
      child: MaterialApp(
        title: 'Inqrypt',
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('ru', ''), // Russian
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Проверяем, поддерживается ли запрошенная локаль
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          // Возвращаем английский как язык по умолчанию
          return const Locale('en', '');
        },
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF000000),
            onPrimary: Color(0xFFFFFFFF),
            secondary: Color(0xFF666666),
            onSecondary: Color(0xFFFFFFFF),
            surface: Color(0xFFF2F2F7),
            onSurface: Color(0xFF000000),
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        darkTheme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFFFFF),
            onPrimary: Color(0xFF000000),
            secondary: Color(0xFF8E8E93),
            onSecondary: Color(0xFF000000),
            surface: Color(0xFF1C1C1E),
            onSurface: Color(0xFFFFFFFF),
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Инициализируем мастер-ключ при запуске приложения
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final masterKeyController = Provider.of<MasterKeyController>(context, listen: false);
      masterKeyController.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false, // Убираем отступ снизу для системных элементов
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Логотип сверху
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Название приложения по центру
              Center(
                child: Text(
                          l10n.appName,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -1.0,
                          ),
                        ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                          l10n.appDescription,
                          style: TextStyle(
                    fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              
              // Основные действия
              _BigActionButton(
                icon: Icons.edit_note,
                title: l10n.noteActionTitle,
                subtitle: l10n.noteActionSubtitle,
                onTap: () async {
                  await VibrationService().navigationForwardVibration();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotePage(),
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              _BigActionButton(
                icon: Icons.qr_code_scanner,
                title: l10n.scanQrActionTitle,
                subtitle: l10n.scanQrActionDescription,
                onTap: () async {
                  await VibrationService().navigationForwardVibration();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ScannerPage(),
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              _BigActionButton(
                icon: Icons.key,
                title: l10n.masterKeyActionTitle,
                subtitle: l10n.masterKeyActionDescription,
                onTap: () async {
                  await VibrationService().navigationForwardVibration();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MasterKeyPage(),
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              // Кнопка удаления всех заметок
              _DangerActionButton(
                icon: Icons.delete_forever,
                title: l10n.deleteAllNotesActionTitle,
                subtitle: '',
                onTap: () => _showDeleteAllNotesDialog(context),
                ),
              
              const SizedBox(height: 32),
              
              // Демо-режим для App Review (перемещен в самый низ)
              DemoActionButton(
                icon: Icons.play_arrow,
                title: l10n.demoInfoTitle,
                subtitle: l10n.demoModeScanningMessage,
                onTap: () async {
                  await VibrationService().navigationForwardVibration();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DemoNotePage(),
                      ),
                    );
                  }
                },
              ),
              
              // Убираем лишний отступ внизу, добавляем минимальный отступ для системных элементов
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BigActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 

/// Показать диалог удаления всех заметок
Future<void> _showDeleteAllNotesDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context).deleteAllNotesDialogTitle),
      content: Text(
        AppLocalizations.of(context).deleteAllNotesDialogContent,
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await VibrationService().navigationBackVibration();
            if (context.mounted) {
              Navigator.of(context).pop(false);
            }
          },
          child: Text(AppLocalizations.of(context).deleteAllNotesDialogCancelButton),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context).deleteAllNotesDialogConfirmButton),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    if (context.mounted) {
      await _deleteAllNotes(context);
    }
  }
}

/// Удалить все заметки
Future<void> _deleteAllNotes(BuildContext context) async {
  try {
    // Показываем индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Запрашиваем биометрию
    final isAuthenticated = await BiometricService.authenticate(
      reason: AppLocalizations.of(context).deleteAllNotesAuthenticationReason,
    );

    // Закрываем индикатор загрузки
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (!isAuthenticated) {
      if (context.mounted) {
        await NotificationService().showError(
          context: context,
          message: AppLocalizations.of(context).deleteAllNotesAuthenticationError,
        );
      }
      return;
    }

    // Удаляем все заметки
    final noteRepository = NoteRepositoryImpl(NoteStorage());
    final notes = await noteRepository.getAllNotes();
    
    for (final note in notes) {
      await noteRepository.deleteNote(note.id);
    }

    if (context.mounted) {
      await NotificationService().showWarning(
        context: context,
        message: AppLocalizations.of(context).deleteAllNotesSuccessMessage(notes.length),
      );
    }
  } catch (e) {
    // Закрываем индикатор загрузки если он открыт
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (context.mounted) {
      await NotificationService().showError(
        context: context,
        message: AppLocalizations.of(context).deleteAllNotesError(e.toString()),
      );
    }
  }
} 

class _DangerActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DangerActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.red.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red.withValues(alpha: 0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 