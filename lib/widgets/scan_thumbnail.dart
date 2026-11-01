import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/scan.dart';
import '../state/library_controller.dart';

class ScanThumbnail extends StatelessWidget {
  const ScanThumbnail({
    super.key,
    required this.scanItem,
    this.width = 48,
    this.height = 60,
  });

  final Scan scanItem;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scehma = Theme.of(context).colorScheme;

    Widget placeholder(IconData icon) {
      return ColoredBox(
        color: scehma.secondaryContainer,
        child: Center(child: Icon(icon, color: scehma.onSecondaryContainer)),
      );
    }

    final Widget content;

    if (scanItem.format == ScanFormat.image) {
      final path = context.read<LibraryController>().pathFor(
        scanItem.files.first,
      );
      content = Image.file(
        File(path),
        fit: BoxFit.cover,
        cacheWidth: (width * 3).round(),
        errorBuilder: (context, error, stackTrace) =>
            placeholder(Icons.broken_image),
      );
    } else {
      content = placeholder(Icons.picture_as_pdf_outlined);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(width: width, height: height, child: content),
    );
  }
}
