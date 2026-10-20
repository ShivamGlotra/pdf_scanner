import 'package:flutter/material.dart';
import 'package:pdf_scanner/model/scan_grid.dart';
import 'package:pdf_scanner/widgets/search_bar.dart';
import 'package:pdf_scanner/model/scans.dart';
import 'package:pdf_scanner/widgets/scan_tile.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});
  static bool isGridView = true;

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

  List<Scan> get _filteredScans {
    final query = _searchQuery.toLowerCase();
    final list = sampleScans.where((scan) {
      final matchesKind = switch (_selectedScanKind) {
        ScanKind.all => true,
        ScanKind.pdf => scan.isPdf,
        ScanKind.images => !scan.isPdf,
      };
      final matchesQuery =
          query.isEmpty || scan.title.toLowerCase().contains(query);
      return matchesKind && matchesQuery;
    }).toList();

    int Function(Scan, Scan) compare = switch (_selectedLibrarySort) {
      LibrarySort.newest => (a, b) => b.date.compareTo(a.date),
      LibrarySort.oldest => (a, b) => a.date.compareTo(b.date),
      LibrarySort.largest => (a, b) => b.bytes.compareTo(a.bytes),
      LibrarySort.nameAZ => (a, b) => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
    };

    return list..sort(compare);
  }

  @override
  Widget build(BuildContext context) {
    final scans = _filteredScans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue[200],
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
            child: AppSearchBar(
              onChanged: (query) => setState(() => _searchQuery = query),
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _KindFilterRow(
            selected: _selectedScanKind,
            onChanged: (kind) {
              setState(() {
                _selectedScanKind = kind;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '${scans.length} scans, ${_sortLabels[_selectedLibrarySort]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: scans.isEmpty
                ? const Center(child: Text('No files found'))
                : HomePageWidget.isGridView
                ? _gridView(scans)
                : ListView.builder(
                    itemCount: scans.length,
                    itemBuilder: (context, i) => ScanTile(scan: scans[i]),
                  ),
          ),
        ],
      ),
    );
  }
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
  const _KindFilterRow({required this.selected, required this.onChanged});

  final ScanKind selected;
  final ValueChanged<ScanKind> onChanged;

  static const _labels = {
    ScanKind.all: 'All',
    ScanKind.pdf: 'PDF',
    ScanKind.images: 'Images',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final kind in ScanKind.values) ...[
            FilterChip(
              label: Text(_labels[kind]!),
              selected: selected == kind,
              showCheckmark: true, // the check seen on "All"
              onSelected: (_) => onChanged(kind),
            ),
            const SizedBox(width: 8),
          ],
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
      return ScanGridCard(scan: scan, onTap: () {}, onShare: () {});
    },
  );
}
