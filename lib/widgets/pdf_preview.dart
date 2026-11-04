import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';

class PdfPreview extends StatelessWidget {
  const PdfPreview({
    super.key,
    required this.path,
    this.initialPage = 0,
    this.onPageChanged,
    this.backgroundColor,
  });

  final String path;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PdfViewer.file(
      path,
      initialPageNumber: initialPage + 1,
      params: PdfViewerParams(
        backgroundColor: backgroundColor ?? scheme.surfaceContainerHighest,
        margin: 12,
        onPageChanged: (page) {
          if (page != null) {
            onPageChanged?.call(page - 1);
          }
        },
      ),
    );
  }
}
