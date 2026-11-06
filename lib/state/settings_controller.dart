import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This is to save user's preferences for the app, such as theme mode and other settings.
class SettingsController extends ChangeNotifier {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  // Add it in future
  // static const String _languageKey = 'language';
  static const String _themeModeKey = 'theme_mode';
  static const String _pagesKey = 'page_limit';
  static const String _askNameKey = 'ask_for_name';

  ThemeMode _themeMode = ThemeMode.system;
  int _pageLimit = 15;
  bool _askForName = true;

  ThemeMode get themeMode => _themeMode;
  int get pageLimit => _pageLimit;
  bool get askForName => _askForName;

  Future<void> loadSettings() async {
    final theme = await _preferences.getString(_themeModeKey);
    final pages = await _preferences.getInt(_pagesKey);
    final askName = await _preferences.getBool(_askNameKey);

    _themeMode =
        ThemeMode.values.asNameMap()[theme ?? 'system'] ??
        ThemeMode.system; // or just [theme] to get the enum value directly
    _pageLimit = pages ?? 15;
    _askForName = askName ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;

    final previousMode = _themeMode;
    _themeMode = mode;
    notifyListeners();
    try {
      await _preferences.setString(_themeModeKey, mode.name);
    } catch (e) {
      _themeMode = previousMode;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setPageLimit(int value) async {
    final limit = value.clamp(1, 30); // Ensure the limit is between 1 and 30
    if (limit == _pageLimit) return;

    final previousLimit = _pageLimit;
    _pageLimit = limit;
    notifyListeners();
    try {
      await _preferences.setInt(_pagesKey, limit);
    } catch (e) {
      _pageLimit = previousLimit;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setAskForName(bool ask) async {
    if (ask == _askForName) return;

    final previousAsk = _askForName;
    _askForName = ask;
    notifyListeners();
    try {
      await _preferences.setBool(_askNameKey, ask);
    } catch (e) {
      _askForName = previousAsk;
      notifyListeners();
      rethrow;
    }
  }
}
