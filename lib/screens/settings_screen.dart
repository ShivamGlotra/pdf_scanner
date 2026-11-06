import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/settings_controller.dart';
import '../utils/format.dart';
import '../widgets/choice_dialog.dart';

String _themeLabel(ThemeMode theme) => switch (theme) {
  ThemeMode.system => 'System',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const List<int> _pageLimits = [10, 15, 20, 30, 50];

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final libraryController = context.watch<LibraryController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(settingsController.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final choice = await showChoiceDialog<ThemeMode>(
                context: context,
                title: 'Select Theme',
                options: ThemeMode.values,
                selected: settingsController.themeMode,
                labelOf: _themeLabel,
              );
              if (choice != null) settingsController.setThemeMode(choice);
            },
          ),
          const Divider(),
          const _SectionHeader('Scanning'),
          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: const Text('Page Limit'),
            subtitle: Text('${settingsController.pageLimit} pages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final choice = await showChoiceDialog<int>(
                context: context,
                title: 'Select Page Limit',
                options: _pageLimits,
                selected: settingsController.pageLimit,
                labelOf: (limit) => '$limit pages',
              );
              if (choice != null) settingsController.setPageLimit(choice);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.edit_outlined),
            title: const Text('Name scan after saving'),
            value: settingsController.askForName,
            onChanged: (value) => settingsController.setAskForName(value),
          ),
          const Divider(),
          const _SectionHeader('Storage'),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Storage Usage'),
            subtitle: Text(
              '${formatBytes(libraryController.totalBytes)} accross '
              '${scansLabel(libraryController.allScanItems.length)} files',
            ),
          ),
          ListTile(
            enabled: libraryController.allScanItems.isNotEmpty,
            iconColor: scheme.error,
            textColor: scheme.error,
            leading: const Icon(Icons.delete_outline),
            title: const Text('Permanently Remove All Scans'),

            onTap: () => _confirmDeleteAll(context),
          ),
          const Divider(),
          const _SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeleteAll(BuildContext context) async {
  final libraryController = context.read<LibraryController>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete All Scans?'),
      content: const Text(
        'Are you sure you want to delete all scans? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete All'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    libraryController.deleteAll();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: scheme.textTheme.labelLarge?.copyWith(
          color: scheme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
