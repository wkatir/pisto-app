import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

export 'tokens.dart';

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

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const turquoise = Color(0xFF6FCF9A); // soft mint (charts, dark accents)
  // brandGreen fails AA with white text (3.98:1) — only for large accents
  // (icons, illustration, strokes), never a button fill with white text.
  static const brandGreen = Color(0xFF2D8F6F);
  static const _lightPrimary = Color(0xFF237059); // deep green — 4.5:1+ on white
  static const _darkPrimary = Color(0xFF3BA57F); // 4.5:1+ on #1C1916

  // ── Sidebar ────────────────────────────────────────────────────────────────
  static const sidebarMuted = Color(0xFF8B7E6B);
  static const sidebarHover = Color(0xFF2A2420);
  static const sidebarBgDark = Color(0xFF1C1916);
  static const sidebarDividerDark = Color(0xFF3A3228);

  static const sidebarBgLight = Color(0xFFFDF6EE);
  static const sidebarMutedLight = Color(0xFF8B7E6B);
  static const sidebarHoverLight = Color(0xFFF5EDE3);
  static const sidebarDividerLight = Color(0xFFF0E6D9);
  static const sidebarTextLight = Color(0xFF0F172A);

  static Color sidebarBg(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? sidebarBgDark : sidebarBgLight;
  static Color sidebarMutedFg(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? sidebarMuted : sidebarMutedLight;
  static Color sidebarHoverBg(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? sidebarHover : sidebarHoverLight;
  static Color sidebarDivider(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? sidebarDividerDark : sidebarDividerLight;
  static Color sidebarLogoText(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? Colors.white : sidebarTextLight;

  // ── Contextual borders (light/dark) ─────────────────────────────────────────
  static const _borderLight = Color(0xFFF0E6D9); // warm sand
  static const _borderDark = Color(0xFF3A3228);   // warm charcoal

  /// Subtle border for cards/containers.
  static Color borderSubtle(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? _borderDark : _borderLight;

  /// More prominent border (strong separators, dividers between sections).
  static Color borderStrong(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark
          ? const Color(0xFF4A3F35)
          : const Color(0xFFD4C8B8);

  /// Subtle background tinted with [color] for icon/avatar/chip containers.
  ///
  /// BANNED as a full-card background wash (see docs/DESIGN.md §1) — color is
  /// an accent (chip/badge/icon tile), never a room. Wave 1 removes any
  /// remaining full-card `tintBg`/`tintBgStrong` uses found in screens.
  static Color tintBg(BuildContext c, Color color) {
    if (Theme.of(c).brightness == Brightness.dark) {
      final cs = Theme.of(c).colorScheme;
      return Color.alphaBlend(color.withValues(alpha: 0.14), cs.surfaceContainer);
    }
    return color.withValues(alpha: 0.10);
  }

  /// Stronger tinted background — for selection states.
  static Color tintBgStrong(BuildContext c, Color color) {
    if (Theme.of(c).brightness == Brightness.dark) {
      final cs = Theme.of(c).colorScheme;
      return Color.alphaBlend(color.withValues(alpha: 0.20), cs.surfaceContainer);
    }
    return color.withValues(alpha: 0.12);
  }

  // ── Pastel card fills (light mode; use cs.surfaceContainer in dark) ────────
  static const mintContainer = Color(0xFFE8F5ED);
  static const peachContainer = Color(0xFFFFF0E6);
  static const lavenderContainer = Color(0xFFF0EDFB);

  // ── Avatar palette (deterministic color per entity in RowAvatar) ───────────
  static const avatarPalette = <Color>[
    brandGreen,
    Color(0xFF7E6BBF), // soft violet
    Color(0xFF8B7EC8), // lavender
    danger,
    accentText,
    success,
    info,
    chartViolet,
    brandGreen,
    chartCoral,
  ];

  // ── Channel brands ─────────────────────────────────────────────────────────
  static const whatsappBrand = Color(0xFF25D366);

  // ── Chart palette (decorative, not semantic) ────────────────────────────────
  static const chartAmber = Color(0xFFF5C563);
  static const chartViolet = Color(0xFFA78BDB);
  static const chartCoral = Color(0xFFF0A07C);
  static const chartTeal = Color(0xFF6FCF9A);

  // ── Semantic intent (used in chips, deltas, status) ────────────────────────
  static const success = Color(0xFF34A853);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFE35D5D);
  static const info = Color(0xFF5B8DEF);

  // Legacy aliases — deprecated, use success/warning/danger.
  static const positive = success;
  static const negative = danger;

  // ── Warm tint for non-financial data (customers, updates) ──────────────────
  // accent is ONLY for fills/containers (with #1C1916 text on top). As a text
  // or icon color over cream it fails AA — use accentText instead.
  static const accent = Color(0xFFE8835A);
  static const accentText = Color(0xFFB4542E); // darkened peach, 4.7:1 on cream

  // ── Color schemes ──────────────────────────────────────────────────────────
  static const FlexSchemeColor _lightColors = FlexSchemeColor(
    primary: _lightPrimary,
    primaryContainer: Color(0xFFD4F0E5),
    secondary: Color(0xFFE8835A),
    secondaryContainer: Color(0xFFFFF0E6),
    tertiary: Color(0xFF8B7EC8),
    tertiaryContainer: Color(0xFFF0EDFB),
    appBarColor: Colors.white,
    error: Color(0xFFE35D5D),
    errorContainer: Color(0xFFFEE2E2),
  );

  static const FlexSchemeColor _darkColors = FlexSchemeColor(
    primary: _darkPrimary,
    primaryContainer: Color(0xFF1A3D2A),
    secondary: Color(0xFFF5A623),
    secondaryContainer: Color(0xFF3A2E1A),
    tertiary: Color(0xFFA78BDB),
    tertiaryContainer: Color(0xFF2A2440),
    appBarColor: Color(0xFF1C1916),
    error: Color(0xFFF87171),
    errorContainer: Color(0xFF3B0A0A),
  );

  static ThemeData get light {
    final base = FlexThemeData.light(
      colors: _lightColors,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 4,
      appBarStyle: FlexAppBarStyle.surface,
      appBarElevation: 0,
      scaffoldBackground: const Color(0xFFFFF8F0),
      useMaterial3: true,
      visualDensity: VisualDensity.comfortable,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnLevel: 6,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: false,
        defaultRadius: 14,
        inputDecoratorRadius: 14,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorIsFilled: true,
        cardRadius: 18,
        cardElevation: 0,
        dialogRadius: 20,
        dialogElevation: 0,
        chipRadius: 20,
        popupMenuElevation: 0,
        menuElevation: 0,
        drawerElevation: 0,
        bottomSheetElevation: 0,
        bottomSheetModalElevation: 0,
        tabBarItemSchemeColor: SchemeColor.primary,
        tabBarUnselectedItemSchemeColor: SchemeColor.onSurfaceVariant,
        tabBarIndicatorSize: TabBarIndicatorSize.label,
        tabBarDividerColor: Color(0xFFF0E6D9),
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
        snackBarElevation: 0,
        fabUseShape: true,
        fabAlwaysCircular: false,
        elevatedButtonElevation: 0,
      ),
      // keep* pins the exact brand colors — the M3 seed would lighten primary
      // below the AA ratio that #237059/#3BA57F were chosen for.
      keyColors: const FlexKeyColors(
        useKeyColors: true,
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
        keepPrimaryContainer: true,
        keepSecondary: true,
        keepSecondaryContainer: true,
        keepTertiary: true,
        keepTertiaryContainer: true,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      primaryTextTheme: _buildTextTheme(Brightness.light),
    );
    return _applyOverrides(base, Brightness.light);
  }

  static ThemeData get dark {
    final base = FlexThemeData.dark(
      colors: _darkColors,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 4,
      darkIsTrueBlack: false,
      appBarStyle: FlexAppBarStyle.background,
      appBarElevation: 0,
      scaffoldBackground: const Color(0xFF1C1916),
      useMaterial3: true,
      visualDensity: VisualDensity.comfortable,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnLevel: 20,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: false,
        defaultRadius: 14,
        inputDecoratorRadius: 14,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorIsFilled: true,
        cardRadius: 18,
        cardElevation: 0,
        dialogRadius: 20,
        dialogElevation: 0,
        chipRadius: 20,
        popupMenuElevation: 0,
        menuElevation: 0,
        drawerElevation: 0,
        bottomSheetElevation: 0,
        bottomSheetModalElevation: 0,
        tabBarItemSchemeColor: SchemeColor.primary,
        tabBarUnselectedItemSchemeColor: SchemeColor.onSurfaceVariant,
        tabBarIndicatorSize: TabBarIndicatorSize.label,
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
        snackBarElevation: 0,
        fabUseShape: true,
        fabAlwaysCircular: false,
        elevatedButtonElevation: 0,
      ),
      // keep* pins the exact brand colors — the M3 seed would lighten primary
      // below the AA ratio that #237059/#3BA57F were chosen for.
      keyColors: const FlexKeyColors(
        useKeyColors: true,
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
        keepPrimaryContainer: true,
        keepSecondary: true,
        keepSecondaryContainer: true,
        keepTertiary: true,
        keepTertiaryContainer: true,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      primaryTextTheme: _buildTextTheme(Brightness.dark),
    );
    return _applyOverrides(base, Brightness.dark);
  }

  // ── Typography ─────────────────────────────────────────────────────────────
  // Figtree          → UI body, labels, buttons, display headings (w800).
  // Spline Sans Mono → financial, monetary, and tabular figures
  //                    (Regular 400 / Medium 500 / SemiBold 600 for totals).

  /// Mono style for monetary figures and dense data.
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.splineSansMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? -0.3,
        height: height ?? 1.2,
      );

  /// Display heading — Figtree w800 for large headings (24px+).
  static TextStyle serif({
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.figtree(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? -0.5,
        height: height ?? 1.15,
        fontStyle: fontStyle,
      );

  /// Eyebrow style — small uppercase for contextual labels above headings
  /// ("HOY · 7 MAY", "VENTAS · ESTE MES").
  static TextStyle eyebrow(BuildContext context, {Color? color}) {
    final cs = Theme.of(context).colorScheme;
    return GoogleFonts.figtree(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: color ?? cs.onSurfaceVariant,
      letterSpacing: 1.2,
      height: 1.2,
    );
  }

  /// Quiet tracked label — sentence case (NOT uppercase), `labelMedium` size,
  /// +0.4 tracking. The voice-primitive label used above `SectionHeading`
  /// titles and `BigFigure` values (docs/DESIGN-VOICE.md §1). Distinct from
  /// [eyebrow], which is uppercase/wider-tracked for context chips.
  static TextStyle quietLabel(BuildContext context, {Color? color}) {
    final theme = Theme.of(context);
    return (theme.textTheme.labelMedium ?? const TextStyle(fontSize: 12)).copyWith(
      color: color ?? theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );
  }

  /// Builds the text theme with the correct colors per brightness.
  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? const Color(0xFFE7E5E4)
        : const Color(0xFF1C1B1F);
    final base = GoogleFonts.figtreeTextTheme(
      Typography.englishLike2021.apply(displayColor: color, bodyColor: color),
    );
    return base.copyWith(
      displayLarge:   base.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.5),
      displayMedium:  base.displayMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1.0),
      displaySmall:   base.displaySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.75),
      headlineLarge:  base.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.25),
      headlineSmall:  base.headlineSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.15),
      titleLarge:     base.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.1),
      labelLarge:     base.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
    );
  }

  /// Applies component overrides that FlexColorScheme doesn't cover well.
  static ThemeData _applyOverrides(ThemeData base, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    // outline must reach 3:1 against the surface for input borders to be an
    // actual visible boundary — the sand #F0E6D9 only gives 1.15:1.
    final outline = isDark ? const Color(0xFF857664) : const Color(0xFF8B7E6B);
    final cs = base.colorScheme.copyWith(
      surfaceTint: Colors.transparent,
      outline: outline,
      outlineVariant: isDark ? const Color(0xFF3A3228) : const Color(0xFFD4C8B8),
      // peach and lavender never carry white text (fails AA) — dark on-color instead.
      onSecondary: isDark ? base.colorScheme.onSecondary : const Color(0xFF1C1916),
      onTertiary: isDark ? base.colorScheme.onTertiary : const Color(0xFF1C1916),
    );

    return base.copyWith(
      colorScheme: cs,
      extensions: [isDark ? PistoTokens.dark : PistoTokens.light],
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PistoTokens.radiusControl),
          borderSide: BorderSide(color: outline),
        ),
      ),
      // FilledButton — taller, more presence, tighter font
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.figtree(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      // OutlinedButton — subtle border, not the thick default
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: GoogleFonts.figtree(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(
            color: isDark ? const Color(0xFF4A3F35) : const Color(0xFFD4C8B8),
          ),
        ),
      ),
      // TextButton — more discreet
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: GoogleFonts.figtree(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // FAB — not Material's huge round default
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        extendedTextStyle: GoogleFonts.figtree(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
      // Dialogs — no shadow, subtle border
      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF2A2420) : const Color(0xFFFFFAF5),
      ),
      // BottomSheet — softer corners
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF2A2420) : const Color(0xFFFFFAF5),
        modalBackgroundColor: isDark ? const Color(0xFF2A2420) : const Color(0xFFFFFAF5),
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      // Popup menu — cleaner
      popupMenuTheme: PopupMenuThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF2A2420) : const Color(0xFFFFFAF5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? const Color(0xFF3A3228) : const Color(0xFFF0E6D9),
          ),
        ),
      ),
      // Divider — more subtle
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF3A3228) : const Color(0xFFF0E6D9),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Color helpers for intent semantics in widgets.
extension SemanticColors on BuildContext {
  Color get successFg => AppTheme.success;
  Color get warningFg => AppTheme.warning;
  Color get dangerFg => AppTheme.danger;
  Color get infoFg => AppTheme.info;
  Color get accentFg => AppTheme.accentText;
}
