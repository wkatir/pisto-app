import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/app_theme.dart';

enum MoneySize {
  /// 14px, inline in list rows.
  small,

  /// 18px, compact KPI.
  medium,

  /// 28px, KPI card.
  large,

  /// 56px, dashboard hero number.
  hero,
}

/// Monetary figure with consistent financial hierarchy.
///
/// Renders the value with Spline Sans Mono and optionally a delta (% or
/// absolute) below or beside it, colored by intent (success/danger).
class MoneyValue extends StatelessWidget {
  /// Pre-formatted figure text (e.g. "$24,500.00"). The caller formats with
  /// `currencyFmt` to keep the currency configurable.
  final String formatted;

  /// Visual size.
  final MoneySize size;

  /// Color override. Defaults to cs.onSurface.
  final Color? color;

  /// Optional delta: descriptive text (e.g. "+12% vs abril", "-3 unidades").
  final String? delta;

  /// Whether [delta] represents a positive change. Controls the chip color.
  final bool? deltaPositive;

  /// Optional label below the figure (e.g. "Ventas este mes").
  final String? label;

  const MoneyValue({
    super.key,
    required this.formatted,
    this.size = MoneySize.medium,
    this.color,
    this.delta,
    this.deltaPositive,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final fontSize = switch (size) {
      MoneySize.small => 14.0,
      MoneySize.medium => 18.0,
      MoneySize.large => 28.0,
      MoneySize.hero => 56.0,
    };

    // Spline Sans Mono: Medium for inline, SemiBold for totals/KPIs.
    final weight = switch (size) {
      MoneySize.small || MoneySize.medium => FontWeight.w500,
      MoneySize.large || MoneySize.hero => FontWeight.w600,
    };

    final valueWidget = Text(
      formatted,
      style: AppTheme.mono(
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? cs.onSurface,
        letterSpacing: size == MoneySize.hero ? -1.5 : -0.5,
        height: 1.0,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && size == MoneySize.hero) ...[
          Text(
            label!.toUpperCase(),
            style: AppTheme.eyebrow(context, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
        ],
        valueWidget,
        if (label != null && size != MoneySize.hero) ...[
          const SizedBox(height: 4),
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (delta != null) ...[
          SizedBox(height: size == MoneySize.hero ? 14 : 6),
          DeltaBadge(text: delta!, positive: deltaPositive),
        ],
      ],
    );
  }
}

/// Small badge for showing deltas: "+12%", "-3 unidades", etc.
/// Color is decided by [positive]: null → neutral, true → success, false → danger.
class DeltaBadge extends StatelessWidget {
  final String text;
  final bool? positive;
  final bool showArrow;

  const DeltaBadge({
    super.key,
    required this.text,
    this.positive,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final color = positive == null
        ? cs.onSurfaceVariant
        : positive!
            ? tokens.successText
            : tokens.dangerText;

    final arrow = positive == null
        ? null
        : positive!
            ? LucideIcons.trendingUp
            : LucideIcons.trendingDown;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, color),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showArrow && arrow != null) ...[
            Icon(arrow, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
