import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../constants/design_constants.dart';
import '../exceptions/app_exceptions.dart';

/// Утилиты для работы с файлами в Inqrypt
class FileUtils {
  // Приватный конструктор для предотвращения создания экземпляров
  FileUtils._();

  /// Получение директории для хранения ключей
  /// 
  /// Возвращает безопасную директорию для хранения криптографических ключей
  static Future<Directory> getSecureDirectory() async {
    try {
      // Используем директорию документов приложения
      final appDir = await getApplicationDocumentsDirectory();
      final secureDir = Directory('${appDir.path}/secure');
      
      // Создаем директорию если она не существует
      if (!await secureDir.exists()) {
        await secureDir.create(recursive: true);
      }
      
      return secureDir;
    } catch (e) {
      throw FileException(
        'Не удалось получить доступ к директории приложения',
        e.toString(),
      );
    }
  }

  /// Получение директории для временных файлов
  /// 
  /// Возвращает директорию для временных файлов
  static Future<Directory> getTemporaryDirectory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final inqryptTempDir = Directory('${tempDir.path}/inqrypt');
      
      // Создаем директорию если она не существует
      if (!await inqryptTempDir.exists()) {
        await inqryptTempDir.create(recursive: true);
      }
      
      return inqryptTempDir;
    } catch (e) {
      throw FileException(
        'Не удалось получить доступ к временной директории',
        e.toString(),
      );
    }
  }

  /// Получение директории для сохранения изображений
  /// 
  /// Возвращает директорию для сохранения QR-кодов в галерею
  static Future<Directory> getPicturesDirectory() async {
    try {
      final picturesDir = await getApplicationDocumentsDirectory();
      final qrDir = Directory('${picturesDir.path}/Inqrypt');
      
      // Создаем директорию если она не существует
      if (!await qrDir.exists()) {
        await qrDir.create(recursive: true);
      }
      
      return qrDir;
    } catch (e) {
      throw FileException(
        'Не удалось получить доступ к директории изображений',
        e.toString(),
      );
    }
  }

  /// Сохранение ключа в файл
  /// 
  /// [keyData] - данные ключа для сохранения
  /// Возвращает путь к сохраненному файлу
  static Future<String> saveKey(List<int> keyData) async {
    try {
      final secureDir = await getSecureDirectory();
      final keyFile = File('${secureDir.path}/${DesignConstants.keyFileName}');
      
      // Записываем ключ в файл
      await keyFile.writeAsBytes(keyData);
      
      return keyFile.path;
    } catch (e) {
      throw FileException(
        'Не удалось сохранить ключ',
        e.toString(),
      );
    }
  }

  /// Загрузка ключа из файла
  /// 
  /// Возвращает данные ключа или null если файл не существует
  static Future<List<int>?> loadKey() async {
    try {
      final secureDir = await getSecureDirectory();
      final keyFile = File('${secureDir.path}/${DesignConstants.keyFileName}');
      
      if (!await keyFile.exists()) {
        return null;
      }
      
      return await keyFile.readAsBytes();
    } catch (e) {
      throw FileException(
        'Не удалось загрузить ключ',
        e.toString(),
      );
    }
  }

  /// Удаление ключа
  /// 
  /// Удаляет файл с ключом
  static Future<bool> deleteKey() async {
    try {
      final secureDir = await getSecureDirectory();
      final keyFile = File('${secureDir.path}/${DesignConstants.keyFileName}');
      
      if (await keyFile.exists()) {
        await keyFile.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      throw FileException(
        'Не удалось удалить ключ',
        e.toString(),
      );
    }
  }

  /// Проверка существования ключа
  /// 
  /// Возвращает true если ключ существует
  static Future<bool> keyExists() async {
    try {
      final secureDir = await getSecureDirectory();
      final keyFile = File('${secureDir.path}/${DesignConstants.keyFileName}');
      
      return await keyFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Сохранение QR-кода как изображение
  /// 
  /// [imageData] - данные изображения
  /// [fileName] - имя файла (без расширения)
  /// Возвращает путь к сохраненному файлу
  static Future<String> saveQRImage(Uint8List imageData, String fileName) async {
    try {
      final picturesDir = await getPicturesDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageFile = File('${picturesDir.path}/${DesignConstants.qrFileName}${fileName}_$timestamp.png');
      
      await imageFile.writeAsBytes(imageData);
      
      return imageFile.path;
    } catch (e) {
      throw FileException(
        'Не удалось сохранить QR-код',
        e.toString(),
      );
    }
  }

  /// Очистка временных файлов
  /// 
  /// Удаляет все временные файлы приложения
  static Future<void> clearTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      // Игнорируем ошибки при очистке временных файлов
    }
  }

  /// Получение размера файла
  /// 
  /// [filePath] - путь к файлу
  /// Возвращает размер файла в байтах
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      
      if (await file.exists()) {
        return await file.length();
      }
      
      return 0;
    } catch (e) {
      throw FileException(
        'Не удалось получить размер файла',
        e.toString(),
      );
    }
  }

  /// Проверка доступного места на диске
  /// 
  /// Возвращает доступное место в байтах
  static Future<int> getAvailableSpace() async {
    try {
      // Это приблизительная оценка, так как Flutter не предоставляет прямой доступ к информации о диске
      return 1024 * 1024 * 100; // Предполагаем 100MB доступно
    } catch (e) {
      return 0;
    }
  }

  /// Создание резервной копии ключа
  /// 
  /// [keyData] - данные ключа
  /// [backupName] - имя резервной копии
  /// Возвращает путь к резервной копии
  static Future<String> createKeyBackup(List<int> keyData, String backupName) async {
    try {
      final secureDir = await getSecureDirectory();
      final backupFile = File('${secureDir.path}/backup_${backupName}_${DateTime.now().millisecondsSinceEpoch}.dat');
      
      await backupFile.writeAsBytes(keyData);
      
      return backupFile.path;
    } catch (e) {
      throw FileException(
        'Не удалось создать резервную копию ключа',
        e.toString(),
      );
    }
  }
} 