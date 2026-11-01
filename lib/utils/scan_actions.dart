// This page/file has actions that would be shared between the home screen and the details screen

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:doc_scanner/models/scan.dart';
import 'package:doc_scanner/state/library_controller.dart';
import 'package:doc_scanner/widgets/name_dialog.dart';

// Funtion to ask and rename a scan
Future<void> renameScan(BuildContext context, Scan scanItem) async {
  final library = context.read<LibraryController>();
  final title = await showNameDialog(
    context,
    title: 'Rename Scan',
    initialTitle: scanItem.title,
    confirmLabel: 'Rename',
  );
  if (title != null && title.isNotEmpty && title != scanItem.title) {
    await library.rename(scanItem.id, title);
  }
}

// Function to share a scan
Future<void> shareScan(BuildContext context, Scan scanItem) async {
  final library = context.read<LibraryController>();
  final messenger = ScaffoldMessenger.of(context);
  final files = [
    for (final path in library.pathsOf(scanItem))
      XFile(path, mimeType: scanItem.format.mimeType),
  ];
  try {
    await SharePlus.instance.share(
      ShareParams(files: files, title: scanItem.title, subject: scanItem.title),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Error sharing scan: $e')));
  }
}

// Function to delete a scan but asks for confirmation first and only deletes if the user confirms
Future<bool> confirmDeleteScan(BuildContext context, Scan scanItem) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Scan'),
      content: Text(
        'The item ${scanItem.title} will be permanently removed from this device.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

// A bottom sheet/widget that shows the actions for a scan item
Future<void> showScanActions(BuildContext context, Scan scanItem) async {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Rename'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              renameScan(context, scanItem);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              shareScan(context, scanItem);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final library = context.read<LibraryController>();
              if (await confirmDeleteScan(context, scanItem)) {
                await library.delete(scanItem.id);
              }
            },
          ),
        ],
      ),
    ),
  );
}
