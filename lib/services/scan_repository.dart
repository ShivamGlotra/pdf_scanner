import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/scan.dart';

// This class is responsible for managing the storage and retrieval of Scan objects.
class ScanRepository {
  late Directory _appDocDir;

  // Initializes the ScanRepository by getting the application documents directory.
  Future<void> init() async {
    final docs = await getApplicationDocumentsDirectory();
    _appDocDir = Directory(p.join(docs.path, 'scans'));
    await _appDocDir.create(recursive: true);
  }

  // Returns the file that stores the index of scans.
  File get _indexFile => File(p.join(_appDocDir.path, 'index.json'));

  String pathFor(String fileName) => p.join(_appDocDir.path, fileName);

  Future<List<Scan>> loadAll() async {
    if (!await _indexFile.exists()) {
      return <Scan>[];
    }
    try {
      final content = await _indexFile.readAsString();
      final jsonList = jsonDecode(content) as List<dynamic>;
      return jsonList
          .map((json) => Scan.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError catch (e, st) {
      // Valid JSON but the wrong shape, e.g. a field missing or renamed.
      await _backupIndex('unexpected shape', e, st);
    } on FileSystemException catch (e, st) {
      // Couldn't read the file (permissions, disk issue).
      await _backupIndex('read failed', e, st);
    } catch (e, st) {
      // Anything else we didn't expect.
      await _backupIndex('unknown error', e, st);
    }
    // A damaged index should not stop the app from starting.
    return <Scan>[];
  }

  Future<void> _backupIndex(String reason, Object error, StackTrace st) async {
    debugPrint('Scan index unreadable ($reason): $error\n$st');
    try {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      await _indexFile.copy(p.join(_appDocDir.path, 'index.json.bak-$stamp'));
    } catch (_) {
      // Backup failed too; nothing more we can safely do.
    }
  }

  Future<void> _pendingSave = Future.value();

  Future<void> saveAll(List<Scan> scans) async {
    final next = _pendingSave.then((_) => _writeIndex(scans));
    _pendingSave = next.catchError((e, st) {
      debugPrint('Failed to save scan index: $e\n$st');
    });
    return next;
  }

  Future<void> _writeIndex(List<Scan> scans) async {
    final file = _indexFile;
    final tempFile = File('${file.path}.tmp');
    try {
      final jsonList = scans.map((scan) => scan.toJson()).toList();
      final content = jsonEncode(jsonList);
      await tempFile.writeAsString(content, flush: true);
      await tempFile.rename(file.path);
    } catch (e, st) {
      debugPrint('Failed to write scan index: $e\n$st');
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {
        rethrow;
        // Add a UI to show "Couldn't save"
      }
    }
  }

  Future<List<String>> importFiles({
    required String id,
    required List<File> sourceFiles,
    required String extension,
  }) async {
    final names = <String>[];
    try {
      for (var i = 0; i < sourceFiles.length; i++) {
        final name = '$id-${i + 1}.$extension';
        await sourceFiles[i].copy(pathFor(name));
        names.add(name);
      }
      return names;
    } catch (_) {
      await deleteFiles(names);
      rethrow;
    }
  }

  Future<int> sizeOf(List<String> fileNames) async {
    var totalSize = 0;
    for (final name in fileNames) {
      try {
        final file = File(pathFor(name));
        if (await file.exists()) {
          totalSize += await file.length();
        }
      } catch (e, st) {
        debugPrint('Failed to get size of $name: $e\n$st');
      }
    }
    return totalSize;
  }

  Future<void> deleteFiles(List<String> fileNames) async {
    for (final name in fileNames) {
      try {
        final file = File(pathFor(name));
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e, st) {
        debugPrint('Failed to delete $name: $e\n$st');
      }
    }
  }
}
