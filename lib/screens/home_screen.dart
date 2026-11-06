import 'package:doc_scanner/utils/format.dart';
import 'package:doc_scanner/utils/scan_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doc_scanner/models/scan.dart';
import 'package:doc_scanner/widgets/scan_tile.dart';
import 'package:doc_scanner/state/library_controller.dart';
import 'package:doc_scanner/widgets/empty_state.dart';
import 'details_page.dart';
import 'package:doc_scanner/widgets/scan_grid.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final scanItems = library.filteredScans;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: Icon(
              library.isGridView
                  ? Icons.list_outlined
                  : Icons.grid_view_outlined,
            ),
            tooltip: library.isGridView
                ? 'Switch to List View'
                : 'Switch to Grid View',
            onPressed: () => library.toggleGridView(),
          ),
          PopupMenuButton<LibrarySort>(
            tooltip: 'Sort options',
            position: PopupMenuPosition.under, // opens below the app bar
            offset: const Offset(0, 4),
            elevation: 3,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: const BoxConstraints(minWidth: 220),
            menuPadding: const EdgeInsets.symmetric(vertical: 8),
            onSelected: library.setSort,
            itemBuilder: (context) => <PopupMenuEntry<LibrarySort>>[
              const PopupMenuItem<LibrarySort>(
                enabled: false,
                child: Text(
                  'Sort by',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              for (final option in LibrarySort.values)
                CheckedPopupMenuItem<LibrarySort>(
                  value: option,
                  checked: option == library.sort,
                  child: Text(option.label),
                ),
            ],
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
                    '${scansLabel(scanItems.length)} scans, ${library.sort.phrase}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(child: _buildList(context, library, scanItems)),
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
  if (library.isGridView) {
    return _buildGrid(context, scanItems);
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

Widget _buildGrid(BuildContext context, List<Scan> scanItems) {
  return GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.75,
    ),
    itemCount: scanItems.length,
    itemBuilder: (context, i) {
      final scanItem = scanItems[i];
      return ScanGridCard(
        scanItem: scanItem,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => DetailsPage(initial: scanItem),
            ),
          );
        },
        onLongPress: () => showScanActions(context, scanItem),
      );
    },
  );
}

// PopupMenuItem<LibrarySort> _item(
//   BuildContext context,
//   LibrarySort value,
//   IconData icon,
//   String label,
// ) {
//   final scheme = Theme.of(context).colorScheme;
//   return PopupMenuItem<LibrarySort>(
//     value: value,
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     child: Row(
//       children: [
//         Icon(icon, size: 22, color: scheme.onSurfaceVariant),
//         const SizedBox(width: 16),
//         Text(label),
//       ],
//     ),
//   );
// }

class _KindFilterRow extends StatelessWidget {
  const _KindFilterRow();

  // final ScanKind selected;
  // final ValueChanged<ScanKind> onChanged;

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
