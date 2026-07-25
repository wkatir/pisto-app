import 'package:flutter/material.dart';

/// Design tokens as a ThemeExtension — single source for spacing, radii,
/// semantic colors, and chart palette. See docs/DESIGN.md (normative).
///
/// Accessed from widgets via `context.tokens` (colors, chart palette) or the
/// static constants (spacing/radii, which don't vary by brightness).
class PistoTokens extends ThemeExtension<PistoTokens> {
  const PistoTokens({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.info,
    required this.infoContainer,
    required this.successText,
    required this.warningText,
    required this.dangerText,
    required this.infoText,
    required this.chartPalette,
  });

  // ── Spacing scale ──────────────────────────────────────────────────────────
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;

  // ── Radii ──────────────────────────────────────────────────────────────────
  static const radiusCard = 18.0;
  static const radiusChip = 20.0; // pill
  static const radiusControl = 14.0; // buttons, inputs
  static const radiusTile = 12.0; // icon tiles / square avatars — single value

  // ── Semantic intent ────────────────────────────────────────────────────────
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color info;
  final Color infoContainer;

  /// Intent colors as FOREGROUND text on bare surface. The container-intent
  /// colors above are tuned to sit on their own tinted backgrounds and fail
  /// WCAG on cream (`warning` is 1.9:1, `success` 2.9:1) — same trap that
  /// `AppTheme.accentText` exists for. Use these whenever an intent colors
  /// text; use the plain ones for fills, icons on tint, and chart marks.
  final Color successText;
  final Color warningText;
  final Color dangerText;
  final Color infoText;

  /// Decorative palette for charts (not semantic). Cycle with `i % length`.
  final List<Color> chartPalette;

  static const light = PistoTokens(
    success: Color(0xFF34A853),
    successContainer: Color(0xFFE8F5ED),
    warning: Color(0xFFF5A623),
    warningContainer: Color(0xFFFDF1DC),
    danger: Color(0xFFE35D5D),
    dangerContainer: Color(0xFFFEE2E2),
    info: Color(0xFF5B8DEF),
    infoContainer: Color(0xFFE4EDFD),
    successText: Color(0xFF1E7A3C), // 5.11:1 on cream
    warningText: Color(0xFF96610A), // 4.97:1 on cream
    dangerText: Color(0xFFB3261E), // 6.21:1 on cream, 5.4:1 on dangerContainer
    infoText: Color(0xFF2E5FBF), // 5.69:1 on cream
    chartPalette: [
      Color(0xFF237059), // deep green (primary)
      Color(0xFF6FCF9A), // teal
      Color(0xFFA78BDB), // violet
      Color(0xFFF5C563), // amber
      Color(0xFFF0A07C), // coral
      Color(0xFF5B8DEF), // blue
    ],
  );

  static const dark = PistoTokens(
    success: Color(0xFF5BBF7E),
    successContainer: Color(0xFF1A3D2A),
    warning: Color(0xFFF5B94F),
    warningContainer: Color(0xFF3A2E1A),
    danger: Color(0xFFF87171),
    dangerContainer: Color(0xFF3B0A0A),
    info: Color(0xFF7FA6F2),
    infoContainer: Color(0xFF1E2A44),
    successText: Color(0xFF5BBF7E), // 7.67:1 on #1C1916
    warningText: Color(0xFFF5B94F), // 9.95:1 on #1C1916
    dangerText: Color(0xFFF87171), // 6.33:1 on #1C1916
    infoText: Color(0xFF7FA6F2), // 6.6:1 on #1C1916
    chartPalette: [
      Color(0xFF3BA57F), // green (primary)
      Color(0xFF6FCF9A), // teal
      Color(0xFFA78BDB), // violet
      Color(0xFFF5C563), // amber
      Color(0xFFF0A07C), // coral
      Color(0xFF7FA6F2), // blue
    ],
  );

  @override
  PistoTokens copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? info,
    Color? infoContainer,
    Color? successText,
    Color? warningText,
    Color? dangerText,
    Color? infoText,
    List<Color>? chartPalette,
  }) =>
      PistoTokens(
        success: success ?? this.success,
        successContainer: successContainer ?? this.successContainer,
        warning: warning ?? this.warning,
        warningContainer: warningContainer ?? this.warningContainer,
        danger: danger ?? this.danger,
        dangerContainer: dangerContainer ?? this.dangerContainer,
        info: info ?? this.info,
        infoContainer: infoContainer ?? this.infoContainer,
        successText: successText ?? this.successText,
        warningText: warningText ?? this.warningText,
        dangerText: dangerText ?? this.dangerText,
        infoText: infoText ?? this.infoText,
        chartPalette: chartPalette ?? this.chartPalette,
      );

  @override
  PistoTokens lerp(PistoTokens? other, double t) {
    if (other == null) return this;
    return PistoTokens(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      infoText: Color.lerp(infoText, other.infoText, t)!,
      chartPalette: t < 0.5 ? chartPalette : other.chartPalette,
    );
  }
}

extension PistoTokensX on BuildContext {
  PistoTokens get tokens => Theme.of(this).extension<PistoTokens>()!;
}
