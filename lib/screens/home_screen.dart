import 'package:doc_scanner/services/scan_repository.dart';
import 'package:doc_scanner/utils/format.dart';
import 'package:doc_scanner/utils/scan_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doc_scanner/models/scan_grid.dart';
import 'package:doc_scanner/widgets/search_bar.dart';
import 'package:doc_scanner/models/scan.dart';
import 'package:doc_scanner/widgets/scan_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:doc_scanner/data/sample_scan_files.dart';
import 'package:doc_scanner/state/library_controller.dart';
import 'package:doc_scanner/widgets/empty_state.dart';
import 'details_page.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});
  static bool isGridView = false;

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

enum ScanKind { all, pdf, images }

enum LibrarySort { newest, oldest, largest, nameAZ }

class _HomePageWidgetState extends State<HomePageWidget> {
  ScanKind _selectedScanKind = ScanKind.all;
  LibrarySort _selectedLibrarySort = LibrarySort.newest;
  String _searchQuery = '';

  static const _sortLabels = {
    LibrarySort.newest: 'newest first',
    LibrarySort.oldest: 'oldest first',
    LibrarySort.largest: 'largest first',
    LibrarySort.nameAZ: 'name A-Z',
  };

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final scanItems = library.filteredScans;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        // titleTextStyle: const TextStyle(
        //   color: Colors.black,
        //   fontSize: 20,
        //   fontWeight: FontWeight.bold,
        // ),
        // backgroundColor: Colors.blue[200],
        // surfaceTintColor: Colors.transparent, // stops the tint shift on scroll
        // scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            tooltip: 'Switch to Grid View',
            onPressed: () {
              setState(() {
                HomePageWidget.isGridView = !HomePageWidget.isGridView;
              });
            },
          ),
          PopupMenuButton<LibrarySort>(
            tooltip: 'More options',
            position: PopupMenuPosition.under, // opens below the app bar
            offset: const Offset(0, 4),
            elevation: 3,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: const BoxConstraints(minWidth: 220),
            menuPadding: const EdgeInsets.symmetric(vertical: 8),
            onSelected: (value) => setState(() => _selectedLibrarySort = value),
            itemBuilder: (context) {
              final theme = Theme.of(context);
              return [
                // Heading
                PopupMenuItem<LibrarySort>(
                  enabled: false,
                  height: 36,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'Sort by', // your {menu name}
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme
                          .colorScheme
                          .primary, // explicit color so it isn't greyed out
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 8),
                _item(
                  context,
                  LibrarySort.newest,
                  Icons.new_releases,
                  'Newest',
                ),
                _item(context, LibrarySort.oldest, Icons.history, 'Oldest'),
                _item(context, LibrarySort.largest, Icons.storage, 'Largest'),
                _item(
                  context,
                  LibrarySort.nameAZ,
                  Icons.sort_by_alpha,
                  'Name (A-Z)',
                ),
              ];
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: const _SearchField(),
          ),
        ),
      ),
      body: !library.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const _KindFilterRow(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '${library.allScanItems.length} scans, ${_sortLabels[_selectedLibrarySort]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  // child: scans.isEmpty
                  //     ? const Center(child: Text('No files found'))
                  //     : HomePageWidget.isGridView
                  //     ? _gridView(scans)
                  //     : ListView.builder(
                  //         itemCount: scans.length,
                  //         itemBuilder: (context, i) => ScanTile(scan: scans[i]),
                  //       ),
                  child: HomePageWidget.isGridView
                      ? _gridView(library.allScanItems)
                      : _buildList(context, library, scanItems),
                ),
              ],
            ),
    );
  }
}

Widget _buildList(
  BuildContext context,
  LibraryController library,
  List<Scan> scanItems,
) {
  if (library.allScanItems.isEmpty) {
    return const EmptyState(
      icon: Icons.folder_open_outlined,
      title: 'No scans found',
      message:
          'You have not scanned any documents yet. Start scanning to see them here.',
    );
  }
  if (scanItems.isEmpty) {
    return const EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No results found',
      message:
          'No scans match your search query. Try adjusting your search or filters.',
    );
  }
  final scheme = Theme.of(context).colorScheme;
  return ListView.builder(
    itemCount: scanItems.length,
    itemBuilder: (context, i) {
      final scanItem = scanItems[i];
      return Dismissible(
        key: ValueKey(scanItem.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: scheme.errorContainer,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
        ),
        confirmDismiss: (_) => confirmDeleteScan(context, scanItem),
        onDismissed: (_) => library.delete(scanItem.id),
        child: Material(
          color: scheme.surface,
          child: ScanTile(
            scanItem: scanItem,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => DetailsPage(initial: scanItem),
              ),
            ),
            onLongPress: () => showScanActions(context, scanItem),
            trailing: IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share',
              onPressed: () => shareScan(context, scanItem),
            ),
          ),
        ),
      );
    },
  );
}

PopupMenuItem<LibrarySort> _item(
  BuildContext context,
  LibrarySort value,
  IconData icon,
  String label,
) {
  final scheme = Theme.of(context).colorScheme;
  return PopupMenuItem<LibrarySort>(
    value: value,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Icon(icon, size: 22, color: scheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Text(label),
      ],
    ),
  );
}

class _KindFilterRow extends StatelessWidget {
  const _KindFilterRow();

  // final ScanKind selected;
  // final ValueChanged<ScanKind> onChanged;

  static const _labels = {
    ScanKind.all: 'All',
    ScanKind.pdf: 'PDF',
    ScanKind.images: 'Images',
  };

  @override
  Widget build(BuildContext context) {
    final filter = context.select<LibraryController, ScanFormat?>(
      (c) => c.filter,
    );
    final library = context.read<LibraryController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text("All"),
            selected: filter == null,
            onSelected: (_) => library.setFilter(null),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("PDF"),
            selected: filter == ScanFormat.pdf,
            onSelected: (_) => library.setFilter(ScanFormat.pdf),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Images"),
            selected: filter == ScanFormat.image,
            onSelected: (_) => library.setFilter(ScanFormat.image),
          ),
        ],
      ),
    );
  }
}

Widget _gridView(List<Scan> scans) {
  return GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 220, // 2 columns on phones, more on tablets
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.78,
    ),
    itemCount: scans.length,
    itemBuilder: (context, i) {
      final scan = scans[i];
      return ScanGridCard(
        scan: scan,
        onTap: () {},
        onShare: () {
          final repo = context.read<ScanRepository>();
          SharePlus.instance.share(
            ShareParams(
              files: scan.files
                  .map((name) => XFile(repo.pathFor(name)))
                  .toList(),
            ),
          );
        },
      );
    },
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search scans',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
        ),
        onChanged: (query) {
          context.read<LibraryController>().setQuery(query);
        },
      ),
    );
  }
}
