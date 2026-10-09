import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

/// StorageService manages local companion receipt image files.
/// Guarantees files are saved within ApplicationDocumentsDirectory,
/// avoiding DB bloat by storing only file paths in SQLite.
class StorageService {
  final Uuid _uuid = const Uuid();

  /// Returns the receipts storage directory, creating it if it does not exist
  Future<Directory> getReceiptsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(p.join(appDir.path, AppConstants.receiptsFolderName));
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    return receiptsDir;
  }

  /// Copies a temporary camera/gallery image into permanent app storage
  /// Returns the permanent file path
  Future<String> saveReceiptImage(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source file does not exist: $sourcePath');
    }

    final receiptsDir = await getReceiptsDirectory();
    final extension = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final targetFileName = 'receipt_${_uuid.v4()}$extension';
    final targetPath = p.join(receiptsDir.path, targetFileName);

    final savedFile = await sourceFile.copy(targetPath);
    return savedFile.path;
  }

  /// Safely deletes a stored receipt image file to prevent orphan files
  Future<void> deleteReceiptImage(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return;

    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore if deletion fails (e.g. permission or already deleted)
    }
  }
}
