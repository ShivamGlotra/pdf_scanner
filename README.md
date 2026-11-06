# Doc Scanner

An Android document scanner built with Flutter. Scan paper documents with your phone camera, save them as a PDF or as images, and find them again later in a searchable library. Everything stays on your device: no account, no cloud, no network needed.

<!-- Add screenshots here, for example:
<p>
  <img src="docs/screenshots/library.png" width="220" alt="Library">
  <img src="docs/screenshots/scan.png" width="220" alt="Scan">
  <img src="docs/screenshots/detail.png" width="220" alt="Document detail">
</p>
-->

## Features

- **Scan to PDF or to images.** You pick the format before scanning, then the scanner handles edge detection, cropping and clean-up.
- **Multi-page scans.** Up to 10 pages per scan by default; change the limit (10 to 50) in Settings.
- **Library.** Search by name, filter by format, sort (newest, oldest, name A to Z, largest), and switch between list and grid.
- **Document view.** Swipe and pinch-zoom through image scans, or scroll a PDF in a real viewer. A full-screen mode hides the system bars.
- **Manage.** Rename, delete and see details (format, pages, size, date) for any scan.
- **Share.** Send a scan through Android's share sheet.
- **Private by design.** Files are stored in the app's own folder on the phone.

### Planned

- Edit pages (rotate, delete a page, reorder) for image scans.

## Tech stack

| Purpose | Package |
|---|---|
| Scanning | [`flutter_doc_scanner`](https://pub.dev/packages/flutter_doc_scanner) |
| State management | [`provider`](https://pub.dev/packages/provider) (`ChangeNotifier`) |
| PDF preview | [`pdfrx`](https://pub.dev/packages/pdfrx) |
| Sharing | [`share_plus`](https://pub.dev/packages/share_plus) |
| File locations | [`path_provider`](https://pub.dev/packages/path_provider), [`path`](https://pub.dev/packages/path) |
| Settings | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |

UI is Material 3. Android only.

## Getting started

### Requirements

- Flutter (a recent stable release) and the Android toolchain. Check with `flutter doctor`.
- An Android phone or emulator. Scanning needs a real camera, so a physical phone is best.
- `pdfrx` builds a small native library, so it needs a C toolchain and a recent Flutter version. See its [documentation](https://pub.dev/packages/pdfrx) if the build complains.

### Run it

```bash
git clone <your-repo-url>
cd doc_scanner
flutter pub get
flutter run
```

### Test and analyze

```bash
flutter analyze
flutter test
```

### Build a developer/debug APK

```bash
flutter build apk --debug
```

### Build a release APK

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## How it is organized

The code is split into layers, so screens never touch files directly and the storage code never touches widgets.

```
lib/
  models/      Plain data: ScanItem, ScanFormat
  services/    ScanRepository (files + index.json), ScannerService (wraps the plugin)
  state/       LibraryController, SettingsController (ChangeNotifier)
  screens/     Library, Scan, Settings, Detail, Full-screen viewer
  widgets/     Reusable pieces: thumbnails, grid cards, name dialog, PDF preview
  utils/       Formatting helpers and shared scan actions (rename, share, delete)
  app.dart     MaterialApp, theme and bottom navigation
  main.dart    Starts the app and loads the library
```

```
Screens  ->  Controllers (Provider)  ->  Repository / Services  ->  Disk + plugin
```

## How scans are stored

Plain files plus a small JSON index, with no database.

- Scanned files are copied into `<app documents>/scans/` as `<id>_<page>.jpg` or `<id>_1.pdf`.
- `index.json` in the same folder lists every scan: id, name, format, file names, page count, size and date.
- Only **file names** are stored, never full paths, so the data survives Android moving the app folder.
- Saves are **atomic**: the index is written to a temp file and renamed, and saves are queued so two never overlap.
- If `index.json` is damaged, it is backed up as `index.json.bak-<timestamp>` and the app starts with an empty library instead of crashing.
- If saving fails, the screen rolls back to what is actually on disk.

Moving to SQLite later would only change `ScanRepository`; the rest of the app would not need to change.

## Privacy

The app does not request an account and does not upload anything. Scans leave the phone only when you choose Share.

## Contributing

Issues and pull requests are welcome. Please run `flutter analyze` and `flutter test` before opening a pull request.

## License

Add a license before publishing, for example [MIT](https://choosealicense.com/licenses/mit/).
