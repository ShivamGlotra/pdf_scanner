import 'package:flutter/material.dart';
import 'package:pdf_scanner/model/scans.dart';

class ScanTile extends StatelessWidget {
  const ScanTile({super.key, required this.scan});

  final Scan scan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Icon(
          scan.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
          color: scheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        scan.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(scan.subtitle),
      trailing: IconButton(
        icon: const Icon(Icons.share_outlined),
        tooltip: 'Share',
        onPressed: () {},
      ),
      onTap: () {},
    );
  }
}
