import 'package:flutter/material.dart';

const Color kSeedColor = Color(0xFF90CAF9);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: kSeedColor,
    brightness: brightness,
  );
  return ThemeData(colorScheme: scheme, useMaterial3: true);
}
