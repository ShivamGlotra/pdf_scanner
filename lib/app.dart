import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/app_shell.dart';
import 'services/scan_repository.dart';
import 'services/scanner_service.dart';
import 'state/library_controller.dart';
import 'state/settings_controller.dart';
import 'theme.dart';

class DocScannerApp extends StatelessWidget {
  const DocScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ScanRepository>(create: (_) => ScanRepository()),
        Provider<ScannerService>(create: (_) => ScannerService()),
        ChangeNotifierProvider<SettingsController>(
          create: (_) => SettingsController()..loadSettings(),
        ),
        ChangeNotifierProvider<LibraryController>(
          create: (context) =>
              LibraryController(context.read<ScanRepository>())..load(),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<SettingsController, ThemeMode>(
      (settings) => settings.themeMode,
    );

    return MaterialApp(
      title: 'DocScanner',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      home: const AppShell(),
    );
  }
}
