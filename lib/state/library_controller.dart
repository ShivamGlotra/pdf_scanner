import 'package:flutter/foundation.dart';

import '../models/scan.dart';
import '../services/scanner_service.dart';
import '../services/scan_repository.dart';

class LibraryController extends ChangeNotifier {
  LibraryController(this._repository);

  final ScanRepository _repository;

  List<Scan> _scanItems = <Scan>[];
  bool _isLoaded = false;
  String _query = '';
  ScanFormat? _filter;

  bool get isLoaded => _isLoaded;

  // Newest First
  List<Scan> get allScanItems => _scanItems;

  String get query => _query;
  ScanFormat? get format => _filter;

  int get totalBytes => _scanItems.fold(0, (sum, item) => sum + item.sizeBytes);

  // The newest 3 scans for the scan tab or screen
  List<Scan> get recentScans => _scanItems.take(3).toList();

  // The scans that match the current query and filter
  List<Scan> get filteredScans {
    final needle = _query.trim().toLowerCase();
    return _scanItems.where((scan) {
      final matchesQuery =
          needle.isEmpty || scan.title.toLowerCase().contains(needle);
      final matchesFormat = _filter == null || scan.format == _filter;
      return matchesQuery && matchesFormat;
    }).toList();
  }

  Scan? byID(String id) {
    for (final scan in _scanItems) {
      if (scan.id == id) {
        return scan;
      }
    }
    return null;
  }

  String pathFor(String fileName) {
    return _repository.pathFor(fileName);
  }

  List<String> pathsOf(Scan scan) {
    return scan.files.map(_repository.pathFor).toList();
  }

  Future<void> load() async {
    try {
      await _repository.init();
      final loaded = await _repository.loadAll();
      loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _scanItems = loaded;
    } catch (e) {
      debugPrint(
        'Error loading scans: $e',
      ); // Change to UI error handling later for UI/UX purposes
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  void setFilter(ScanFormat? value) {
    _filter = value;
    notifyListeners();
  }

  // Copy the scans to the repository and records the scan
  Future<Scan> addScans({
    required String title,
    required ScanOutput output,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final stored = await _repository.importFiles(
      id: id,
      sourceFiles: output.files,
      extension: output.format.fileExtension,
    );
    final scanItem = Scan(
      id: id,
      title: title,
      format: output.format,
      sizeBytes: await _repository.sizeOf(stored),
      files: stored,
      pageCount: output.pageCount,
      createdAt: DateTime.now(),
    );
    try {
      await _commit([scanItem, ..._scanItems]);
    } catch (e) {
      // Do not leave copied files behind for a scan that was never recorded.
      await _repository.deleteFiles(stored);
      rethrow;
    }
    await output.discard();
    return scanItem;
  }

  Future<void> _commit(List<Scan> next) async {
    final previous = _scanItems;
    _scanItems = next;
    notifyListeners();
    try {
      await _repository.saveAll(_scanItems);
    } catch (e) {
      _scanItems = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rename(String id, String newTitle) async {
    final trimmed = newTitle.trim();
    final index = _scanItems.indexWhere((item) => item.id == id);
    if (index == -1 || trimmed.isEmpty) {
      return;
    }
    final updated = List<Scan>.of(_scanItems);
    updated[index] = updated[index].copyWith(title: trimmed);
    try {
      await _commit(updated);
    } catch (e) {
      debugPrint('Error renaming scan: $e');
    }
    // await _commit(updated);
  }

  Future<void> delete(String id) async {
    final index = _scanItems.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    final removed = _scanItems[index];
    await _commit(_scanItems.where((item) => item.id != id).toList());
    await _repository.deleteFiles(removed.files);
  }

  Future<void> deleteAll() async {
    final removed = _scanItems;
    await _commit(<Scan>[]);
    for (final scan in removed) {
      await _repository.deleteFiles(scan.files);
    }
  }
}
