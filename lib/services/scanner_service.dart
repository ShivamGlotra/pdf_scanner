import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

import '../models/scan.dart';

class ScanOutput {
  const ScanOutput({
    required this.format,
    required this.files,
    required this.pageCount,
  });

  final ScanFormat format;
  final List<File> files;
  final int pageCount;

  // Function to delete the temporary files created during the scan process
  Future<void> discard() async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } on FileSystemException {
        // Ignore errors when deleting files
      } catch (_) {
        debugPrint('Error deleting file ${file.path}');
      }
    }
  }
}

// Exception when scanning process fails for some reason and user needs to be informed about it
class ScanFailure implements Exception {
  const ScanFailure(this.message);

  final String message;

  @override
  String toString() => 'ScanFailure: $message';
}

class ScannerService {
  final FlutterDocScanner _scanner = FlutterDocScanner();

  // Open google's document scanner and return the scanned output
  Future<ScanOutput?> scanDocument({
    required ScanFormat format,
    required int maxPageCount,
  }) async {
    try {
      if (format == ScanFormat.pdf) {
        final pdfFile = await _scanner.getScannedDocumentAsPdf(
          page: maxPageCount,
        );
        if (pdfFile == null) return null;
        return ScanOutput(
          format: format,
          files: [_fileFromUri(pdfFile.pdfUri)],
          pageCount: pdfFile.pageCount > 0 ? pdfFile.pageCount : 1,
        );
      }

      final scannedImages = await _scanner.getScannedDocumentAsImages(
        page: maxPageCount,
      );
      if (scannedImages == null || scannedImages.images.isEmpty) return null;
      final files = scannedImages.images.map(_fileFromUri).toList();
      return ScanOutput(format: format, files: files, pageCount: files.length);
    } on DocScanException catch (e) {
      if (e.code == DocScanException.codeCancelled) {
        return null;
      }
      throw ScanFailure('Failed to scan document: ${e.message}');
    } on PlatformException catch (e) {
      throw ScanFailure(e.message ?? 'The scanner failed (${e.code}).');
    } catch (e) {
      throw ScanFailure('An unexpected error occurred: $e');
    }
  }

  File _fileFromUri(String uri) {
    if (uri.startsWith('file:')) return File(Uri.parse(uri).toFilePath());
    if (uri.startsWith('/')) return File(uri);
    throw ScanFailure('The provided URI is not a valid file path: $uri');
  }
}
