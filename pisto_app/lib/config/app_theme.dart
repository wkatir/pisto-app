import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Breakpoints {
  Breakpoints._();

  static const compact = 600.0;
  static const medium = 840.0;
  static const expanded = 1240.0;

  static const formStack = 500.0;
  static const gridDense = 700.0;
  static const gridSparse = 900.0;
  static const sidebarExtended = 1200.0;
}

class AppTheme {
  AppTheme._();

  // ── Brand colors ──────────────────────────────────────────────────────────
  static const turquoise = Color(0xFF1DE9B6);
  static const _black = Color(0xFF000000);
  static const _surface = Color(0xFF0D0D0D);
  static const _surfaceContainer = Color(0xFF161616);
  static const _surfaceContainerHigh = Color(0xFF1F1F1F);
  static const _border = Color(0xFF2A2A2A);

  // ── Sidebar / dark navigation ─────────────────────────────────────────────
  static const sidebarMuted = Color(0xFFAAAAAA);
  static const sidebarHover = Color(0xFF1A1A1A);

  // ── Light theme tokens (used in landing/auth/sales detail screens) ────────
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightSurface = Color(0xFFF6F9FC);
  static const lightSurfaceAlt = Color(0xFFF8FAFC);

  // ── Third-party brand colors ──────────────────────────────────────────────
  static const whatsappBrand = Color(0xFF25D366);

  // ── Chart colors ──────────────────────────────────────────────────────────
  static const chartAmber = Color(0xFFF59E0B);
  static const chartViolet = Color(0xFF8B5CF6);
  static const chartCoral = Color(0xFFF97316);
  static const chartTeal = Color(0xFF14B8A6);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const positive = Color(0xFF1DE9B6);
  static const negative = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);


  // ── Dark theme (principal) ────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: turquoise,
          onPrimary: _black,
          primaryContainer: Color(0xFF003D30),
          onPrimaryContainer: turquoise,
          secondary: Color(0xFF00BFA5),
          onSecondary: _black,
          secondaryContainer: Color(0xFF002E26),
          onSecondaryContainer: Color(0xFF80FFEA),
          tertiary: Color(0xFF94A3B8),
          onTertiary: _black,
          tertiaryContainer: Color(0xFF1E293B),
          onTertiaryContainer: Color(0xFFCBD5E1),
          error: Color(0xFFEF4444),
          onError: _black,
          errorContainer: Color(0xFF3B0A0A),
          onErrorContainer: Color(0xFFFCA5A5),
          surface: _surface,
          onSurface: Colors.white,
          surfaceContainerLowest: _black,
          surfaceContainerLow: _surface,
          surfaceContainer: _surfaceContainer,
          surfaceContainerHigh: _surfaceContainerHigh,
          surfaceContainerHighest: Color(0xFF262626),
          onSurfaceVariant: Color(0xFFB0B0B0),
          outline: Color(0xFF3A3A3A),
          outlineVariant: _border,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Colors.white,
          onInverseSurface: _black,
          inversePrimary: Color(0xFF00695C),
        ),
        scaffoldBackgroundColor: _black,
        textTheme: _buildTextTheme(Brightness.dark),
        primaryTextTheme: _buildTextTheme(Brightness.dark),
        visualDensity: VisualDensity.comfortable,
        // Cards
        cardTheme: CardThemeData(
          color: _surfaceContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: _border),
          ),
          margin: EdgeInsets.zero,
        ),
        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: turquoise, width: 1.5),
          ),
          hintStyle: const TextStyle(color: Color(0xFF666666)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        // Botones
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: turquoise,
            foregroundColor: _black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF3A3A3A)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: turquoise,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _surfaceContainerHigh,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: _border),
            ),
          ),
        ),
        // Tabs
        tabBarTheme: const TabBarThemeData(
          labelColor: turquoise,
          unselectedLabelColor: Color(0xFF808080),
          indicatorColor: turquoise,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: _border,
        ),
        // Divider
        dividerTheme: const DividerThemeData(color: _border, thickness: 1, space: 1),
        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: _black,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: _surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _border),
          ),
          elevation: 0,
        ),
        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: _surfaceContainerHigh,
          selectedColor: const Color(0xFF003D30),
          labelStyle: const TextStyle(color: Colors.white),
          side: const BorderSide(color: _border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? _black : const Color(0xFF666666)),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? turquoise : const Color(0xFF2A2A2A)),
        ),
        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? turquoise : Colors.transparent),
          checkColor: WidgetStateProperty.all(_black),
          side: const BorderSide(color: Color(0xFF3A3A3A), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        // FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: turquoise,
          foregroundColor: _black,
        ),
        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _surfaceContainerHigh,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: _border),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        // PopupMenu
        popupMenuTheme: PopupMenuThemeData(
          color: _surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: _border),
          ),
          elevation: 0,
        ),
        // NavigationRail
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: _surface,
          selectedIconTheme: IconThemeData(color: turquoise),
          unselectedIconTheme: IconThemeData(color: Color(0xFFAAAAAA)),
          selectedLabelTextStyle: TextStyle(color: turquoise, fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelTextStyle: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
          indicatorColor: Color(0x331DE9B6),
        ),
        // ListTile
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          iconColor: Color(0xFF808080),
          textColor: Colors.white,
        ),
        // Icon
        iconTheme: const IconThemeData(color: Color(0xFF808080)),
        // BottomSheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: _surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
      );

  // ── Light theme (complementario) ──────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: turquoise,
          brightness: Brightness.light,
          primary: const Color(0xFF00897B),
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F9FC),
        textTheme: _buildTextTheme(Brightness.light),
        primaryTextTheme: _buildTextTheme(Brightness.light),
        visualDensity: VisualDensity.comfortable,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0), thickness: 1),
      );

  // ── Mono helper ───────────────────────────────────────────────────────────
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
  }) =>
      GoogleFonts.dmMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? -0.3,
        height: 1.2,
      );

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    final bodyColor = brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A);
    final subtleColor = brightness == Brightness.dark ? const Color(0xFFB0B0B0) : const Color(0xFF64748B);

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(letterSpacing: -1.5, fontWeight: FontWeight.w800, color: bodyColor),
      displayMedium: base.displayMedium?.copyWith(letterSpacing: -1.0, fontWeight: FontWeight.w700, color: bodyColor),
      displaySmall: base.displaySmall?.copyWith(letterSpacing: -0.75, fontWeight: FontWeight.w700, color: bodyColor),
      headlineLarge: base.headlineLarge?.copyWith(letterSpacing: -0.5, fontWeight: FontWeight.w700, color: bodyColor),
      headlineMedium: base.headlineMedium?.copyWith(letterSpacing: -0.25, fontWeight: FontWeight.w600, color: bodyColor),
      headlineSmall: base.headlineSmall?.copyWith(letterSpacing: -0.15, fontWeight: FontWeight.w600, color: bodyColor),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.1, color: bodyColor),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: bodyColor),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w500, color: bodyColor),
      bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.6, color: bodyColor),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w400, height: 1.5, color: bodyColor),
      bodySmall: base.bodySmall?.copyWith(fontWeight: FontWeight.w400, height: 1.4, color: subtleColor),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0, color: bodyColor),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500, color: subtleColor),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.1, color: subtleColor),
    );
  }
}
