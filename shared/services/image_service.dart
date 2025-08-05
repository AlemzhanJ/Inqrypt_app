import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../../core/localization/app_localizations.dart';
import 'vibration_service.dart';

/// Результат выбора изображения с информацией об источнике
class ImageSourceResult {
  final File file;
  final ImageSource source;
  final bool shouldDeleteOriginal;

  const ImageSourceResult({
    required this.file,
    required this.source,
    required this.shouldDeleteOriginal,
  });
}

/// Сервис для работы с изображениями
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Выбрать изображение из галереи
  Future<ImageSourceResult?> pickImageFromGallery() async {
    try {
      print('ImageService: Выбираем изображение из галереи');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Максимальная ширина
        maxHeight: 1920, // Максимальная высота
        imageQuality: 85, // Качество сжатия
      );
      
      if (image != null) {
        print('ImageService: ✅ Изображение выбрано из галереи: ${image.path}');
        return ImageSourceResult(
          file: File(image.path),
          source: ImageSource.gallery,
          shouldDeleteOriginal: false, // Не удаляем оригинал из галереи
        );
      }
      print('ImageService: ❌ Изображение из галереи не выбрано');
      return null;
    } catch (e) {
      debugPrint('Ошибка выбора изображения из галереи: $e');
      return null;
    }
  }

  /// Сделать фотографию
  Future<ImageSourceResult?> takePhoto() async {
    try {
      print('ImageService: Делаем фотографию через камеру');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        // TODO: image_picker не поддерживает saveToGallery: false
        // Фото будет сохранено во временную папку, но может появиться в галерее
        // Для полной приватности нужно использовать camera_plugin или другой подход
      );
      
      if (image != null) {
        print('ImageService: ✅ Фотография сделана через камеру: ${image.path}');
        return ImageSourceResult(
          file: File(image.path),
          source: ImageSource.camera,
          shouldDeleteOriginal: true, // Удаляем оригинал после копирования
        );
      }
      print('ImageService: ❌ Фотография через камеру не сделана');
      return null;
    } catch (e) {
      debugPrint('Ошибка съемки фотографии: $e');
      return null;
    }
  }

  /// Показать диалог выбора источника изображения
  Future<ImageSourceResult?> showImageSourceDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final completer = Completer<ImageSourceResult?>();
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectImageTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.galleryOption),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await pickImageFromGallery();
                completer.complete(result);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.cameraOption),
              subtitle: Text(l10n.cameraSubtitle),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await takePhoto();
                completer.complete(result);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await VibrationService().navigationBackVibration();
              if (context.mounted) {
                Navigator.of(context).pop();
                completer.complete(null);
              }
            },
            child: Text(l10n.cancelButtonText),
          ),
        ],
      ),
    );
    
    return await completer.future;
  }

  /// Зашифровать изображение
  Future<String?> encryptImage(File imageFile, String noteKey) async {
    try {
      // Читаем изображение
      final Uint8List imageBytes = await imageFile.readAsBytes();
      print('ImageService: Размер исходного изображения: ${imageBytes.length} байт');
      print('ImageService: Первые байты: ${imageBytes.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      
      // Создаем ключ для шифрования изображения
      final keyBytes = sha256.convert(utf8.encode(noteKey)).bytes;
      final key = encrypt.Key(Uint8List.fromList(keyBytes));
      
      // Создаем IV
      final iv = encrypt.IV.fromSecureRandom(16);
      
      // Шифруем изображение как base64 строку
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
      final imageBase64 = base64.encode(imageBytes);
      print('ImageService: Размер base64: ${imageBase64.length} символов');
      final encrypted = encrypter.encrypt(imageBase64, iv: iv);
      
      // Сохраняем зашифрованное изображение
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/note_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final encryptedPath = '${imagesDir.path}/$fileName.enc';
      
      // Сохраняем в формате base64(iv):base64(data)
      final encryptedData = '${base64.encode(iv.bytes)}:${encrypted.base64}';
      await File(encryptedPath).writeAsString(encryptedData);
      
      print('ImageService: Изображение зашифровано: $encryptedPath');
      return encryptedPath;
    } catch (e) {
      print('Ошибка шифрования изображения: $e');
      return null;
    }
  }

  /// Расшифровать изображение
  Future<Uint8List?> decryptImage(String encryptedPath, String noteKey) async {
    try {
      print('ImageService: Расшифровываем изображение: $encryptedPath');
      
      // Читаем зашифрованные данные
      final encryptedData = await File(encryptedPath).readAsString();
      final parts = encryptedData.split(':');
      
      if (parts.length != 2) {
        throw Exception('Неверный формат зашифрованных данных');
      }
      
      final ivBytes = base64.decode(parts[0]);
      final encryptedString = parts[1];
      
      print('ImageService: IV: ${ivBytes.length} байт');
      print('ImageService: Зашифрованные данные: ${encryptedString.length} символов');
      
      // Создаем ключ для расшифровки
      final keyBytes = sha256.convert(utf8.encode(noteKey)).bytes;
      final key = encrypt.Key(Uint8List.fromList(keyBytes));
      final iv = encrypt.IV(ivBytes);
      
      // Расшифровываем изображение
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
      final decryptedBase64 = encrypter.decrypt64(encryptedString, iv: iv);
      
      print('ImageService: Расшифрованный base64: ${decryptedBase64.length} символов');
      
      // Конвертируем обратно в Uint8List
      final decryptedBytes = base64.decode(decryptedBase64);
      print('ImageService: Размер расшифрованного изображения: ${decryptedBytes.length} байт');
      print('ImageService: Первые байты расшифрованного: ${decryptedBytes.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      
      return Uint8List.fromList(decryptedBytes);
    } catch (e) {
      print('Ошибка расшифровки изображения: $e');
      return null;
    }
  }

  /// Удалить зашифрованное изображение
  Future<bool> deleteEncryptedImage(String encryptedPath) async {
    try {
      final file = File(encryptedPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Ошибка удаления изображения: $e');
      return false;
    }
  }

  /// Получить размер файла в читаемом формате
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} ГБ';
  }
} 