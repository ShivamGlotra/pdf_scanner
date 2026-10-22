import 'package:doc_scanner/models/scan.dart';
import 'package:doc_scanner/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ScanItem survives a JSON round trip', () {
    final item = Scan(
      id: '1',
      title: 'Receipt',
      format: ScanFormat.images,
      files: const ['1_1.jpg', '1_2.jpg'],
      pageCount: 2,
      createdAt: DateTime.utc(2026, 10, 8, 14, 30),
      sizeBytes: 2048,
    );

    final copy = Scan.fromJson(item.toJson());

    expect(copy.id, '1');
    expect(copy.title, 'Receipt');
    expect(copy.format, ScanFormat.images);
    expect(copy.files, ['1_1.jpg', '1_2.jpg']);
    expect(copy.createdAt, item.createdAt);
    expect(copy.sizeBytes, 2048);
  });

  test('copyWith changes only the title', () {
    final item = Scan(
      id: '1',
      title: 'Old',
      format: ScanFormat.pdf,
      files: const ['1_1.pdf'],
      pageCount: 3,
      createdAt: DateTime.utc(2026, 10, 8),
      sizeBytes: 10,
    );

    final renamed = item.copyWith(title: 'New');

    expect(renamed.title, 'New');
    expect(renamed.id, item.id);
    expect(renamed.pageCount, 3);
    expect(item.title, 'Old');
  });

  test('formatters', () {
    expect(formatBytes(512), '512 B');
    expect(formatBytes(2 * 1024 * 1024), '2.0 MB');
    expect(pagesLabel(1), '1 page');
    expect(pagesLabel(4), '4 pages');
  });
}
