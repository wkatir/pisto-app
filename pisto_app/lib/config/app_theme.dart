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
  static const turquoise = Color(0xFF1DE9B6);
  static const _lightPrimary = Color(0xFF00897B);

  // ── Sidebar ────────────────────────────────────────────────────────────────
  static const sidebarMuted = Color(0xFFA0A0A8);
  static const sidebarHover = Color(0xFF1A1A1F);
  static const sidebarBgDark = Color(0xFF0F0F12);
  static const sidebarDividerDark = Color(0xFF1F1F25);

  static const sidebarBgLight = Color(0xFFFAFAF9);
  static const sidebarMutedLight = Color(0xFF64748B);
  static const sidebarHoverLight = Color(0xFFF1F1EE);
  static const sidebarDividerLight = Color(0xFFE7E5E4);
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
  // Reemplazo del patrón `cs.outlineVariant.withValues(alpha: 0.5)` que en light
  // sale casi invisible y en dark inconsistente. Estos están calibrados para
  // dar el mismo nivel de "presencia" sutil en ambos modos.
  static const _borderLight = Color(0xFFE7E5E4); // stone-200
  static const _borderDark = Color(0xFF26262B);  // entre scaffold y surface dark

  /// Border sutil para cards/contenedores. Más fuerte que outlineVariant default
  /// en light (donde es casi imperceptible) y consistente en dark.
  static Color borderSubtle(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? _borderDark : _borderLight;

  /// Border más prominente (separadores fuertes, divisores entre secciones).
  static Color borderStrong(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark
          ? const Color(0xFF35353C)
          : const Color(0xFFD4D4D8);

  /// Background sutil tinted con [color] para containers de íconos/avatares/chips.
  ///
  /// **Por qué existe**: usar `color.withValues(alpha: 0.10)` directo causa
  /// "glow" en dark mode cuando [color] es saturado (ej. primary turquoise
  /// `#1DE9B6` brillante). El alpha sobre fondo oscuro deja pasar mucha
  /// luminosidad del color puro y se ve como un brillo decorativo de IA-slop.
  ///
  /// Solución: en dark hacemos `alphaBlend` del color con surfaceContainer.
  /// El resultado es un tono mate apagado del color sobre el fondo del card
  /// — no glow, pero conserva la conexión visual de intent.
  ///
  /// En light, `color.withValues(alpha: 0.10)` ya da el resultado correcto
  /// (pálido natural sobre fondo claro), así que usamos eso.
  static Color tintBg(BuildContext c, Color color) {
    if (Theme.of(c).brightness == Brightness.dark) {
      final cs = Theme.of(c).colorScheme;
      return Color.alphaBlend(color.withValues(alpha: 0.14), cs.surfaceContainer);
    }
    return color.withValues(alpha: 0.10);
  }

  /// Background tinted más fuerte — para selection states (sidebar item activo,
  /// list row selected). Mismo principio anti-glow que [tintBg].
  static Color tintBgStrong(BuildContext c, Color color) {
    if (Theme.of(c).brightness == Brightness.dark) {
      final cs = Theme.of(c).colorScheme;
      return Color.alphaBlend(color.withValues(alpha: 0.20), cs.surfaceContainer);
    }
    return color.withValues(alpha: 0.12);
  }

  // ── Channel brands ─────────────────────────────────────────────────────────
  static const whatsappBrand = Color(0xFF25D366);

  // ── Chart palette (decorativo, no semántico) ───────────────────────────────
  static const chartAmber = Color(0xFFF59E0B);
  static const chartViolet = Color(0xFF8B5CF6);
  static const chartCoral = Color(0xFFFB923C);
  static const chartTeal = Color(0xFF14B8A6);

  // ── Semantic intent (uso en chips, deltas, status) ─────────────────────────
  // Reemplaza positive/negative/warning con tokens claros y consistentes.
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Aliases legacy — deprecated, usa success/warning/danger.
  static const positive = success;
  static const negative = danger;

  // ── Tinte cálido para datos no financieros (clientes, novedades) ───────────
  static const accent = Color(0xFFFB923C);

  // ── Color schemes ──────────────────────────────────────────────────────────
  static const FlexSchemeColor _lightColors = FlexSchemeColor(
    primary: _lightPrimary,
    primaryContainer: Color(0xFFB2DFDB),
    secondary: Color(0xFF00897B),
    secondaryContainer: Color(0xFFE0F2F1),
    tertiary: Color(0xFF475569),
    tertiaryContainer: Color(0xFFF1F5F9),
    appBarColor: Colors.white,
    error: Color(0xFFEF4444),
    errorContainer: Color(0xFFFEE2E2),
  );

  static const FlexSchemeColor _darkColors = FlexSchemeColor(
    primary: turquoise,
    primaryContainer: Color(0xFF003D30),
    secondary: Color(0xFF00BFA5),
    secondaryContainer: Color(0xFF002E26),
    tertiary: Color(0xFF94A3B8),
    tertiaryContainer: Color(0xFF1E293B),
    appBarColor: Color(0xFF0F0F12),
    error: Color(0xFFF87171),
    errorContainer: Color(0xFF3B0A0A),
  );

  static ThemeData get light => FlexThemeData.light(
        colors: _lightColors,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 4,
        appBarStyle: FlexAppBarStyle.surface,
        appBarElevation: 0,
        scaffoldBackground: const Color(0xFFFAFAF9),
        useMaterial3: true,
        visualDensity: VisualDensity.comfortable,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          tintedDisabledControls: true,
          blendOnLevel: 6,
          blendOnColors: false,
          useMaterial3Typography: true,
          useM2StyleDividerInM3: false,
          defaultRadius: 10,
          inputDecoratorRadius: 10,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorIsFilled: true,
          cardRadius: 14,
          cardElevation: 0,
          dialogRadius: 16,
          dialogElevation: 0,
          chipRadius: 8,
          popupMenuElevation: 0,
          menuElevation: 0,
          drawerElevation: 0,
          bottomSheetElevation: 0,
          bottomSheetModalElevation: 0,
          tabBarItemSchemeColor: SchemeColor.primary,
          tabBarUnselectedItemSchemeColor: SchemeColor.onSurfaceVariant,
          tabBarIndicatorSize: TabBarIndicatorSize.label,
          tabBarDividerColor: Color(0xFFE7E5E4),
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

  static ThemeData get dark => FlexThemeData.dark(
        colors: _darkColors,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        darkIsTrueBlack: false,
        appBarStyle: FlexAppBarStyle.background,
        appBarElevation: 0,
        scaffoldBackground: const Color(0xFF0F0F12),
        useMaterial3: true,
        visualDensity: VisualDensity.comfortable,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          tintedDisabledControls: true,
          blendOnLevel: 20,
          blendOnColors: false,
          useMaterial3Typography: true,
          useM2StyleDividerInM3: false,
          defaultRadius: 10,
          inputDecoratorRadius: 10,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorIsFilled: true,
          cardRadius: 14,
          cardElevation: 0,
          dialogRadius: 16,
          dialogElevation: 0,
          chipRadius: 8,
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

  // ── Typography ─────────────────────────────────────────────────────────────
  // Plus Jakarta Sans → UI body, labels, buttons.
  // Lora           → display headlines (24px+) — alta legibilidad en pantalla.
  // DM Mono        → números financieros, monetarios y datos tabulares.

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

  /// Serif Lora — solo para titulares display (24px+).
  /// Da personality editorial sin sacrificar legibilidad en pantalla.
  static TextStyle serif({
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.lora(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing ?? -0.5,
        height: height ?? 1.15,
        fontStyle: fontStyle,
      );

  /// Eyebrow style — uppercase mono pequeño para labels contextuales arriba de
  /// titulares ("HOY · 7 MAY", "VENTAS · ESTE MES").
  static TextStyle eyebrow(BuildContext context, {Color? color}) {
    final cs = Theme.of(context).colorScheme;
    return GoogleFonts.dmMono(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color ?? cs.onSurfaceVariant,
      letterSpacing: 1.2,
      height: 1.2,
    );
  }

  /// Construye el text theme con colores correctos por brightness.
  ///
  /// **Importante**: `Typography.englishLike2021` viene con colores hardcoded
  /// (negros para light) que `copyWith` preserva. Si pasamos ese theme tal cual
  /// a light y dark, los textos quedan negros incluso en dark mode (bug).
  ///
  /// Aplicamos `apply(displayColor/bodyColor)` ANTES del copyWith para que cada
  /// brightness tenga sus colores correctos. FlexColorScheme respeta esos
  /// colores y no los pisa.
  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? const Color(0xFFE7E5E4) // matched con onSurface dark de FlexColorScheme
        : const Color(0xFF1C1B1F); // matched con onSurface light
    final base = GoogleFonts.plusJakartaSansTextTheme(
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
}

/// Color helpers para semántica de intent en widgets.
extension SemanticColors on BuildContext {
  Color get successFg => AppTheme.success;
  Color get warningFg => AppTheme.warning;
  Color get dangerFg => AppTheme.danger;
  Color get infoFg => AppTheme.info;
  Color get accentFg => AppTheme.accent;
}
