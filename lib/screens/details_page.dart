import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../models/scan.dart';
import '../state/library_controller.dart';
import '../utils/format.dart';
import '../utils/scan_actions.dart';
import 'fullscreen_viewer_page.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.initial});

  // The initial scan data passed to this page. Used even if the scan is deleted, so we can still display the details.
  final Scan initial;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _pageCount = 0;

  Future<void> _deleteScan(Scan scanItem) async {
    final navigator = Navigator.of(context);
    final library = context.read<LibraryController>();
    if (!await confirmDeleteScan(context, scanItem)) return;
    await library.delete(scanItem.id);
    if (!mounted) return;
    navigator.pop();
  }

  void _openFullScreenViewer(Scan scanItem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullScreenViewerPage(scanItem: scanItem, initialPage: _pageCount),
      ),
    );
  }

  void _showDetails(Scan scanItem) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(context, 'Title', scanItem.title),
            _detailRow(context, 'Format', scanItem.format.label),
            _detailRow(context, 'Pages', pagesLabel(scanItem.pageCount)),
            _detailRow(context, 'Size', formatBytes(scanItem.sizeBytes)),
            _detailRow(context, 'Scanned', formatLongDate(scanItem.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final live = context.select<LibraryController, Scan?>(
      (library) => library.byID(widget.initial.id),
    );
    final scanItem = live ?? widget.initial;
    final library = context.read<LibraryController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final details = [
      scanItem.format.label,
      pagesLabel(scanItem.pageCount),
      formatBytes(scanItem.sizeBytes),
      'Scanned ${formatLongDate(scanItem.createdAt)}',
    ].join(' · ');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          scanItem.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => _showDetails(scanItem),
            icon: const Icon(Icons.info_outline),
          ),
          if (scanItem.format == ScanFormat.image)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit pages is coming soon.')),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildPdfView(scanItem, library, scheme),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Text(
              details,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  FilledButton.icon(
                    onPressed: () => shareScan(context, scanItem),
                    icon: const Icon(Icons.share_outlined),

                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    label: Text(
                      scanItem.format == ScanFormat.image
                          ? 'Share Images'
                          : 'Share PDF',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => renameScan(context, scanItem),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Rename'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteScan(scanItem),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: scheme.error,
                          ),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages(List<String> paths) {
    return PageView.builder(
      itemCount: paths.length,
      onPageChanged: (index) => setState(() => _pageCount = index),
      itemBuilder: (context, index) => InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.file(
            File(paths[index]),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Center(child: Text('Could not load this page')),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfView(
    Scan scanItem,
    LibraryController library,
    ColorScheme scheme,
  ) {
    final paths = library.pathsOf(scanItem);
    final Widget content = scanItem.format == ScanFormat.image
        ? _buildImages(paths)
        : PdfViewer.file(library.pathFor(scanItem.files.first));

    return Stack(
      children: [
        Positioned.fill(child: content),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filled(
            tooltip: 'Open Fullscreen Viewer',
            style: IconButton.styleFrom(
              backgroundColor: scheme.inverseSurface,
              foregroundColor: scheme.onInverseSurface,
            ),
            onPressed: () => _openFullScreenViewer(scanItem),
            icon: const Icon(Icons.fullscreen),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.inverseSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Page ${_pageCount + 1} of ${scanItem.pageCount}',
                style: TextStyle(color: scheme.onInverseSurface, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
