import 'package:flutter/material.dart';

import 'package:doc_scanner/models/scan.dart';
import 'package:doc_scanner/utils/format.dart';
import 'scan_thumbnail.dart';
import 'package:share_plus/share_plus.dart';

class ScanTile extends StatelessWidget {
  const ScanTile({
    super.key,
    required this.scanItem,
    required this.onTap,
    this.onLongPress,
    this.trailing,
  });

  final Scan scanItem;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final details = [
      scanItem.format.label,
      pagesLabel(scanItem.pageCount),
      formatShortDate(scanItem.createdAt),
    ].join(' • ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ScanThumbnail(scanItem: scanItem),
      title: Text(
        scanItem.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // style: theme.textTheme.titleMedium?.copyWith(
        //   fontWeight: FontWeight.w600,
        // ),
      ),
      subtitle: Text(details),
      trailing: trailing,
      //  IconButton(
      //   icon: const Icon(Icons.share_outlined),
      //   tooltip: 'Share',
      //   onPressed: () async {
      //     await SharePlus.instance.share(
      //       ShareParams(
      //         // files: [XFile(scan.imagePath)],
      //         text: 'Check out this scan: ${scanItem.title}',
      //       ),
      //     );
      //   },
      // ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
