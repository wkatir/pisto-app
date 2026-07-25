import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Small header/summary stat: label + mono value on a `surfaceContainerHigh`
/// pill. Usage: `MetricChip(label: 'Facturas', value: '24')`, typically inline
/// in a `PageHeader` or an `InfoCard` title row. Never used as a card background.
class MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const MetricChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(PistoTokens.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTheme.mono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
