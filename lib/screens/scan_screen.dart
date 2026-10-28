import 'package:doc_scanner/models/scan.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/settings_controller.dart';
import '../utils/format.dart';
import 'package:flutter/material.dart';
import '../services/scanner_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  // Call this method to navigate to the HomePage when user clicks 'See all' button
  //final VoidCallback onSeeAllPressed;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Future<void> _startScan(ScanFormat format) async {
    final scanner = context.read<ScannerService>();
    final library = context.read<LibraryController>();
    //  final settings = context.read<ScannerSettings>();

    try {
      final outputFile = await scanner.scanDocument(
        format: format,
        maxPageCount: 10,
      );
      if (outputFile == null) {
        debugPrint('Scan cancelled');
        return;
      }
      final scannedItem = await library.addScans(
        title: defaultScanName(DateTime.now()),
        output: outputFile,
      );
      debugPrint('Saved ${scannedItem.title} as ${scannedItem.files}');
    } on ScanFailure catch (e) {
      debugPrint('ScanFailure: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            'Pick how you want to scan your document.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _OptionCard(
            icon: Icons.description_outlined,
            title: 'Scan to PDF',
            subtitle: 'One file with every page',
            background: scheme.primaryContainer,
            foreground: scheme.onPrimaryContainer,
            iconBackground: scheme.primary,
            iconColor: scheme.onPrimary,
            onTap: () => _startScan(ScanFormat.pdf),
          ),
          const SizedBox(height: 12),
          _OptionCard(
            icon: Icons.image_outlined,
            title: 'Scan to images',
            subtitle: 'One picture for each page',
            background: scheme.surfaceContainerHighest,
            foreground: scheme.onSurface,
            iconBackground: scheme.inverseSurface,
            iconColor: scheme.onInverseSurface,
            onTap: () => _startScan(ScanFormat.image),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Text(
                'Recent scans',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('See all')),
              const SizedBox(width: 4),
              for (final scan
                  in context.read<LibraryController>().allScanItems.take(3))
                _RecentScanItem(
                  title: scan.title,
                  subtitle: formatLongDate(scan.createdAt),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foreground.withAlpha(190),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentScanItem extends StatelessWidget {
  const _RecentScanItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: () => debugPrint('Tapped on $title'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 42,
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  for (final w in [1.0, .7, .9, .5])
                    FractionallySizedBox(
                      widthFactor: w,
                      child: Container(
                        height: 2.5,
                        margin: const EdgeInsets.only(bottom: 4),
                        color: scheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
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
