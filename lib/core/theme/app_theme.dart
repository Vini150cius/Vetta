import 'package:flutter/material.dart';

/// Identidade visual do app: índigo/violeta vibrante, fundos suaves,
/// cantos bem arredondados e acentos coloridos (menta, coral, âmbar, azul).
class AppTheme {
  AppTheme._();

  // Cores de marca
  static const primary = Color(0xFF5B3DF5);
  static const primaryDeep = Color(0xFF3A22D6);
  static const violet = Color(0xFF9B6BFF);
  static const sky = Color(0xFF2EA8FF);
  static const amber = Color(0xFFFFB02E);
  static const pink = Color(0xFFEC4899);

  // Cores semânticas
  static const incomeColor = Color(0xFF12B981);
  static const expenseColor = Color(0xFFFF5470);

  // Gradientes usados nos cartões de destaque
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A22D6), Color(0xFF7B4DFF), Color(0xFF9B6BFF)],
  );
  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A3D), Color(0xFFFF4D8D)],
  );
  static const mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0BA5A4), Color(0xFF34D399)],
  );

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final onSurface = dark ? const Color(0xFFF1EEFF) : const Color(0xFF1B1740);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: dark ? const Color(0xFFA78BFF) : primary,
      onPrimary: dark ? const Color(0xFF1B1140) : Colors.white,
      surface: dark ? const Color(0xFF1B1836) : Colors.white,
      onSurface: onSurface,
      surfaceContainerHighest:
          dark ? const Color(0xFF262248) : const Color(0xFFEFEBFF),
    );

    final base = ThemeData(
        useMaterial3: true, colorScheme: scheme, brightness: brightness);
    final t = base.textTheme;

    return base.copyWith(
      scaffoldBackgroundColor:
          dark ? const Color(0xFF110F26) : const Color(0xFFF5F3FF),
      textTheme: t.copyWith(
        headlineMedium: t.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineSmall: t.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        titleLarge: t.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 6,
        extendedTextStyle:
            const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        shape: const StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.primary.withAlpha(90)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          side: const WidgetStatePropertyAll(BorderSide.none),
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? scheme.primary
                  : scheme.surfaceContainerHighest),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? scheme.onPrimary
                  : scheme.onSurface),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.primary : null),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onSurface.withAlpha(20),
        space: 1,
      ),
    );
  }
}
