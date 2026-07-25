import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// THE flat-section pattern (docs/DESIGN-VOICE.md §1): optional quiet tracked
/// label, `titleMedium` w600 title, optional trailing action, hairline
/// divider below. Default composition for screen sections — `InfoCard` is
/// reserved for KPI blocks / framed tables / accent alerts. Usage:
/// `SectionHeading(label: 'Este mes', title: 'Movimientos recientes',
/// trailing: TextButton(...))`.
class SectionHeading extends StatelessWidget {
  final String? label;
  final String title;
  final Widget? trailing;

  /// Space above the label/title block.
  final double spaceBefore;

  /// Space below the divider, before whatever content follows.
  final double spaceAfter;

  const SectionHeading({
    super.key,
    this.label,
    required this.title,
    this.trailing,
    this.spaceBefore = 32,
    this.spaceAfter = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(top: spaceBefore, bottom: spaceAfter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(label!, style: AppTheme.quietLabel(context)),
            const SizedBox(height: 4),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, thickness: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}
