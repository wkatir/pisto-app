import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Standard fl_chart dressing (docs/DESIGN-VOICE.md §1): horizontal-only
/// grid in `outlineVariant` 1px, mono axis labels, 4px bar radius, tooltip =
/// small surface card with a mono value. Pure config helpers: screens build
/// `LineChartData`/`BarChartData` and splice these in, e.g. `gridData:
/// ChartSpec.grid(context, interval: maxY / 4)`.
class ChartSpec {
  ChartSpec._();

  /// Rounded top only, the standard bar cap.
  static const barRadius = BorderRadius.vertical(top: Radius.circular(4));

  /// Horizontal-only grid line, no vertical grid.
  static FlGridData grid(BuildContext context, {double? interval}) {
    final cs = Theme.of(context).colorScheme;
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (value) => FlLine(
        color: cs.outlineVariant.withValues(alpha: 0.5),
        strokeWidth: 1,
      ),
    );
  }

  /// Axis label style: `labelSmall` size; mono face for numeric axes
  /// (amounts), regular face for categorical axes (dates/names).
  static TextStyle axisLabel(BuildContext context, {bool mono = true}) {
    final cs = Theme.of(context).colorScheme;
    final base = Theme.of(context).textTheme.labelSmall;
    final size = base?.fontSize ?? 11;
    return mono
        ? AppTheme.mono(fontSize: size, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)
        : (base ?? TextStyle(fontSize: size)).copyWith(color: cs.onSurfaceVariant);
  }

  /// Decorative chart palette from tokens, cycle with `i % palette.length`.
  static List<Color> palette(BuildContext context) => context.tokens.chartPalette;

  static Color _tooltipBg(BuildContext context) => Theme.of(context).colorScheme.surfaceContainerHigh;

  /// Mono value text style used inside tooltips.
  static TextStyle tooltipValueStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppTheme.mono(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface);
  }

  /// Line chart tooltip: `surface` card, 1px `outlineVariant` border, no shadow.
  static LineTouchTooltipData lineTooltip(BuildContext context) => LineTouchTooltipData(
        getTooltipColor: (_) => _tooltipBg(context),
        tooltipBorder: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        tooltipBorderRadius: BorderRadius.circular(10),
      );

  /// Bar chart tooltip: same card treatment as [lineTooltip].
  static BarTouchTooltipData barTooltip(BuildContext context) => BarTouchTooltipData(
        getTooltipColor: (_) => _tooltipBg(context),
        tooltipBorder: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        tooltipBorderRadius: BorderRadius.circular(10),
      );
}
