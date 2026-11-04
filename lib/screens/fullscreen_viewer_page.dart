import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/scan.dart';
import '../utils/scan_actions.dart';
import '../state/library_controller.dart';
import '../widgets/pdf_preview.dart';

class FullScreenViewerPage extends StatefulWidget {
  const FullScreenViewerPage({
    super.key,
    required this.scanItem,
    this.initialPage = 0,
  });

  final Scan scanItem;
  final int initialPage;

  @override
  State<FullScreenViewerPage> createState() => _FullScreenViewerPageState();
}

class _FullScreenViewerPageState extends State<FullScreenViewerPage> {
  static const _backgroundColor = Color(0xFF1B1B21);

  late int _page = widget.initialPage;
  late final PageController _pageController = PageController(
    initialPage: widget.initialPage,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanItem = widget.scanItem;
    final paths = context.read<LibraryController>().pathsOf(scanItem);
    final theme = Theme.of(context);

    final Widget content = scanItem.format == ScanFormat.image
        ? PageView.builder(
            controller: _pageController,
            itemCount: paths.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Center(
                  child: Image.file(File(paths[index]), fit: BoxFit.contain),
                ),
              );
            },
          )
        : PdfPreview(
            path: paths.first,
            initialPage: widget.initialPage,
            backgroundColor: _backgroundColor,
            onPageChanged: (index) => setState(() => _page = index),
          );
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(child: content),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Exit full screen',
                      color: Colors.white,
                      icon: const Icon(
                        Icons.fullscreen_exit,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        scanItem.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Text(
                    //   '${_page + 1} / ${paths.length}',
                    //   style: theme.textTheme.bodyMedium?.copyWith(
                    //     color: Colors.white,
                    //   ),
                    // ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => showScanActions(context, scanItem),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4646dF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Page ${_page + 1} of ${paths.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
