import 'package:flex_color_scheme/flex_color_scheme.dart';
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

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const turquoise = Color(0xFF6FCF9A); // soft mint (dark primary)
  static const _lightPrimary = Color(0xFF2D8F6F); // warm forest green

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

  // ── Borders contextuales (light/dark) ──────────────────────────────────────
  static const _borderLight = Color(0xFFF0E6D9); // warm sand
  static const _borderDark = Color(0xFF3A3228);   // warm charcoal

  /// Border sutil para cards/contenedores.
  static Color borderSubtle(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? _borderDark : _borderLight;

  /// Border mas prominente (separadores fuertes, divisores entre secciones).
  static Color borderStrong(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark
          ? const Color(0xFF4A3F35)
          : const Color(0xFFD4C8B8);

  /// Background sutil tinted con [color] para containers de iconos/avatares/chips.
  static Color tintBg(BuildContext c, Color color) {
    if (Theme.of(c).brightness == Brightness.dark) {
      final cs = Theme.of(c).colorScheme;
      return Color.alphaBlend(color.withValues(alpha: 0.14), cs.surfaceContainer);
    }
    return color.withValues(alpha: 0.10);
  }

  /// Background tinted mas fuerte — para selection states.
  static Color tintBgStrong(BuildContext c, Color color) {
    if (Theme.of(c).brightness == Brightness.dark) {
      final cs = Theme.of(c).colorScheme;
      return Color.alphaBlend(color.withValues(alpha: 0.20), cs.surfaceContainer);
    }
    return color.withValues(alpha: 0.12);
  }

  // ── Channel brands ─────────────────────────────────────────────────────────
  static const whatsappBrand = Color(0xFF25D366);

  // ── Chart palette (decorativo, no semantico) ───────────────────────────────
  static const chartAmber = Color(0xFFF5C563);
  static const chartViolet = Color(0xFFA78BDB);
  static const chartCoral = Color(0xFFF0A07C);
  static const chartTeal = Color(0xFF6FCF9A);

  // ── Semantic intent (uso en chips, deltas, status) ─────────────────────────
  static const success = Color(0xFF34A853);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFE35D5D);
  static const info = Color(0xFF5B8DEF);

  // Aliases legacy — deprecated, usa success/warning/danger.
  static const positive = success;
  static const negative = danger;

  // ── Tinte calido para datos no financieros (clientes, novedades) ───────────
  static const accent = Color(0xFFE8835A);

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
    primary: turquoise,
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
        chipRadius: 12,
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
      keyColors: const FlexKeyColors(
        useKeyColors: true,
        useSecondary: true,
        useTertiary: true,
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
        chipRadius: 12,
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
      keyColors: const FlexKeyColors(
        useKeyColors: true,
        useSecondary: true,
        useTertiary: true,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      primaryTextTheme: _buildTextTheme(Brightness.dark),
    );
    return _applyOverrides(base, Brightness.dark);
  }

  // ── Typography ─────────────────────────────────────────────────────────────
  // Nunito       → UI body, labels, buttons, display headings (w800).
  // DM Mono      → numeros financieros, monetarios y datos tabulares.

  /// Mono para cifras monetarias y datos densos.
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.dmMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? -0.3,
        height: height ?? 1.2,
      );

  /// Display heading — Nunito w800 para titulares grandes (24px+).
  static TextStyle serif({
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? -0.5,
        height: height ?? 1.15,
        fontStyle: fontStyle,
      );

  /// Eyebrow style — uppercase pequeno para labels contextuales arriba de
  /// titulares ("HOY · 7 MAY", "VENTAS · ESTE MES").
  static TextStyle eyebrow(BuildContext context, {Color? color}) {
    final cs = Theme.of(context).colorScheme;
    return GoogleFonts.nunito(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: color ?? cs.onSurfaceVariant,
      letterSpacing: 1.2,
      height: 1.2,
    );
  }

  /// Construye el text theme con colores correctos por brightness.
  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? const Color(0xFFE7E5E4)
        : const Color(0xFF1C1B1F);
    final base = GoogleFonts.nunitoTextTheme(
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

  /// Aplica overrides de componentes que FlexColorScheme no cubre bien.
  static ThemeData _applyOverrides(ThemeData base, Brightness brightness) {
    final cs = base.colorScheme;
    final isDark = brightness == Brightness.dark;

    return base.copyWith(
      // FilledButton — mas alto, mas presencia, font tighter
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.nunito(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      // OutlinedButton — borde sutil, no el default grueso
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: GoogleFonts.nunito(
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
      // TextButton — mas discreto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: GoogleFonts.nunito(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // FAB — no el default redondo enorme de Material
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        extendedTextStyle: GoogleFonts.nunito(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
      // Dialogos — sin sombra, borde sutil
      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF2A2420) : const Color(0xFFFFFAF5),
      ),
      // BottomSheet — bordes mas suaves
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF2A2420) : const Color(0xFFFFFAF5),
        modalBackgroundColor: isDark ? const Color(0xFF2A2420) : const Color(0xFFFFFAF5),
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      // Popup menu — mas limpio
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
      // Divider — mas sutil
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF3A3228) : const Color(0xFFF0E6D9),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Color helpers para semantica de intent en widgets.
extension SemanticColors on BuildContext {
  Color get successFg => AppTheme.success;
  Color get warningFg => AppTheme.warning;
  Color get dangerFg => AppTheme.danger;
  Color get infoFg => AppTheme.info;
  Color get accentFg => AppTheme.accent;
}
