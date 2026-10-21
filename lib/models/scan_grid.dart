import 'package:flutter/material.dart';
import 'package:doc_scanner/models/scans.dart';

class ScanGridCard extends StatelessWidget {
  const ScanGridCard({super.key, required this.scan, this.onTap, this.onShare});

  final Scan scan;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: scheme.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        // Replace with Image.file(...) once you have real thumbnails
                        child: const _PaperPlaceholder(),
                      ),
                    ),
                    // Type badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scan.format == ScanFormat.pdf
                              ? scheme.errorContainer
                              : scheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scan.format == ScanFormat.pdf ? 'PDF' : 'IMG',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scan.format == ScanFormat.pdf
                                ? scheme.onErrorContainer
                                : scheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 4, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scan.pageCount == 1
                              ? '1 page'
                              : '${scan.pageCount} pages',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 20),
                    tooltip: 'Share',
                    visualDensity: VisualDensity.compact,
                    onPressed: onShare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fake text lines so the thumbnail looks like a scanned page.
class _PaperPlaceholder extends StatelessWidget {
  const _PaperPlaceholder();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    Widget line(double widthFactor) => FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 5,
        margin: const EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 36, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [line(0.9), line(0.7), line(0.85), line(0.5), line(0.75)],
      ),
    );
  }
}
