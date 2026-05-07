import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/app_theme.dart';

enum MoneySize {
  /// 14px — inline en filas de lista.
  small,

  /// 18px — KPI compacto.
  medium,

  /// 28px — card de KPI.
  large,

  /// 56px — hero number del dashboard.
  hero,
}

/// Cifra monetaria con jerarquía financiera consistente.
///
/// Renderiza el valor con DM Mono y opcionalmente un delta (% o absoluto)
/// debajo o al lado, coloreado por intent (success/danger).
class MoneyValue extends StatelessWidget {
  /// Texto pre-formateado de la cifra (ej. "$24,500.00"). Quien llama formatea
  /// con `currencyFmt` para mantener la moneda configurable.
  final String formatted;

  /// Tamaño visual.
  final MoneySize size;

  /// Color override. Por defecto usa cs.onSurface.
  final Color? color;

  /// Delta opcional — texto descriptivo (ej. "+12% vs abril", "-3 unidades").
  final String? delta;

  /// Si [delta] representa un cambio positivo. Controla color del chip.
  final bool? deltaPositive;

  /// Label opcional debajo de la cifra (ej. "Ventas este mes").
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

    final weight = switch (size) {
      MoneySize.small || MoneySize.medium => FontWeight.w600,
      MoneySize.large => FontWeight.w700,
      MoneySize.hero => FontWeight.w700,
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

/// Badge pequeño para mostrar deltas: "+12%", "-3 unidades", etc.
/// Color se decide por [positive]: null → neutral, true → success, false → danger.
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
    final color = positive == null
        ? cs.onSurfaceVariant
        : positive!
            ? AppTheme.success
            : AppTheme.danger;

    final arrow = positive == null
        ? null
        : positive!
            ? LucideIcons.trendingUp
            : LucideIcons.trendingDown;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, color),
        borderRadius: BorderRadius.circular(6),
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
