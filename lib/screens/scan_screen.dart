import 'package:doc_scanner/models/scan.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../state/library_controller.dart';
import '../state/settings_controller.dart';
import '../utils/format.dart';
import 'package:flutter/material.dart';
import '../services/scanner_service.dart';
import '../models/scan.dart';
import '../widgets/name_dialog.dart';
import '../widgets/scan_tile.dart';
import 'details_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.onSeeAllPressed});

  // Call this method to navigate to the HomePage when user clicks 'See all' button
  final VoidCallback onSeeAllPressed;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _busy = false;

  Future<void> _startScan(ScanFormat format) async {
    final settings = context.read<SettingsController>();
    final scanner = context.read<ScannerService>();
    final library = context.read<LibraryController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    //  final settings = context.read<ScannerSettings>();
    setState(() => _busy = true);
    try {
      final outputFile = await scanner.scanDocument(
        format: format,
        maxPageCount: settings.pageLimit,
      );
      if (outputFile == null) {
        // debugPrint('Scan cancelled'); only for debugging, no need to show user
        return;
      }
      if (!mounted) return;
      var name = defaultScanName(DateTime.now());
      if (settings.askForName) {
        final chosen = await showNameDialog(
          context,
          title: 'Name your scan',
          initialTitle: name,
          confirmLabel: 'Save',
        );
        if (chosen == null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Scan discarded')),
          );
          await outputFile.discard();
          return;
        }
        name = chosen;
      }
      final scannedItem = await library.addScans(
        title: name,
        output: outputFile,
      );
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          persist: false,
          content: Text(
            'Scan saved as ${scannedItem.title} - ${scannedItem.pageCount} ${scannedItem.pageCount == 1 ? "page" : "pages"}',
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => navigator.push(
              MaterialPageRoute<void>(
                builder: (_) => DetailsPage(initial: scannedItem),
              ),
            ),
          ),
        ),
      );
    } on ScanFailure catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Scan failed: ${e.message}')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save scan: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void view(Scan scanItem) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailsPage(initial: scanItem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = context.watch<SettingsController>();
    final library = context.watch<LibraryController>();
    final recentScans = library.recentScans;

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan'),
        titleTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
            child: Text(
              'Pick how you want to scan your document.'
              'Up to ${settings.pageLimit} pages per scan.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _OptionCard(
            icon: Icons.description_outlined,
            title: 'Scan to PDF',
            description: 'All pages in one PDF file',
            emphasized: true,
            onTap: () => _startScan(ScanFormat.pdf),
          ),
          const SizedBox(height: 12),
          _OptionCard(
            icon: Icons.image_outlined,
            title: 'Scan to images',
            description: 'Each page as a separate image',
            emphasized: false,
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
              TextButton(
                onPressed: () => widget.onSeeAllPressed(),
                child: const Text('See all'),
              ),
            ],
          ),
          if (recentScans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Your latest scans will show up here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final scanItem in recentScans)
              ScanTile(scanItem: scanItem, onTap: () => view(scanItem)),
          // for (final scan
          //     in context.read<LibraryController>().allScanItems.take(3))
          //   _RecentScanItem(
          //     title: scan.title,
          //     subtitle: formatLongDate(scan.createdAt),
          //   ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.emphasized,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool emphasized;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = emphasized
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final foreground = emphasized
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    final tile = emphasized ? scheme.primary : scheme.inverseSurface;
    final onTile = emphasized ? scheme.onPrimary : scheme.onInverseSurface;

    return Card(
      color: background,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: tile,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 32, color: onTile),
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
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

// class _RecentScanItem extends StatelessWidget {
//   const _RecentScanItem({required this.title, required this.subtitle});

//   final String title;
//   final String subtitle;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;

//     return InkWell(
//       onTap: () => debugPrint('Tapped on $title'),
//       borderRadius: BorderRadius.circular(12),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//         child: Row(
//           children: [
//             Container(
//               width: 34,
//               height: 42,
//               padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4),
//                 border: Border.all(color: scheme.outlineVariant),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,

//                 children: [
//                   for (final w in [1.0, .7, .9, .5])
//                     FractionallySizedBox(
//                       widthFactor: w,
//                       child: Container(
//                         height: 2.5,
//                         margin: const EdgeInsets.only(bottom: 4),
//                         color: scheme.outlineVariant,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: scheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
