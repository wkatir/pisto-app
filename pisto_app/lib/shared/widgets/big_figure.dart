import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Size variant → text-theme role the mono figure borrows its size from:
/// `s` = titleLarge, `m` = headlineMedium, `l` = headlineLarge,
/// `xl` = displaySmall.
///
/// M3 reserves display sizes for "short, important text passages, or numerals"
/// and forbids them on section headings, so `xl` is the screen's single hero
/// figure — one per screen, never a heading (docs/RATIONALE.md §11).
enum BigFigureSize { s, m, l, xl }

/// The KPI voice (docs/DESIGN-VOICE.md §1): small quiet label above a big
/// Spline Sans Mono figure, optional delta as tinted text (never a filled
/// chip — see `DeltaBadge` in `money_value.dart` for the boxed variant used
/// inline in lists), optional caption below. Usage: `BigFigure(label: 'Ventas
/// este mes', value: '\$24,500.00', size: BigFigureSize.l, delta: '+12%',
/// deltaPositive: true)`. For inline amounts in rows/tables keep using
/// `MoneyValue`.
class BigFigure extends StatelessWidget {
  final String label;
  final String value;
  final BigFigureSize size;
  final String? delta;
  final bool? deltaPositive;
  final String? caption;
  final Color? valueColor;

  const BigFigure({
    super.key,
    required this.label,
    required this.value,
    this.size = BigFigureSize.m,
    this.delta,
    this.deltaPositive,
    this.caption,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final roleStyle = switch (size) {
      BigFigureSize.s => theme.textTheme.titleLarge,
      BigFigureSize.m => theme.textTheme.headlineMedium,
      BigFigureSize.l => theme.textTheme.headlineLarge,
      BigFigureSize.xl => theme.textTheme.displaySmall,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTheme.quietLabel(context)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                style: AppTheme.mono(
                  fontSize: roleStyle?.fontSize ?? 28,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? cs.onSurface,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (delta != null) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: _DeltaText(text: delta!, positive: deltaPositive),
              ),
            ],
          ],
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(
            caption!,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// Small tinted delta text (success/danger foreground, NOT a filled box) —
/// the voice-primitive alternative to `DeltaBadge` for `BigFigure`.
class _DeltaText extends StatelessWidget {
  final String text;
  final bool? positive;
  const _DeltaText({required this.text, this.positive});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = positive == null
        ? cs.onSurfaceVariant
        : positive!
            ? AppTheme.success
            : AppTheme.danger;

    return Text(
      text,
      style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w600, color: color, letterSpacing: 0),
    );
  }
}
