import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const incomeColor = Color(0xFF43A047);
  static const expenseColor = Color(0xFFE53935);

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00796B), brightness: brightness),
      );
}
