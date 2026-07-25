import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Quiet card: `surfaceContainerLow` fill + 1px `outlineVariant` border +
/// radius 18. Optional title row with a trailing action, optional 3px left
/// accent bar for state (overdue/warning). Usage: `InfoCard(title: 'Vencidas',
/// accentColor: cs.error, child: ...)`. NO tinted full-card fills, shadows or
/// gradients: see docs/DESIGN.md §1 (color is an accent, never a room).
///
/// DEMOTED (docs/DESIGN-VOICE.md §1): `InfoCard` is sanctioned for exactly
/// three uses: (a) KPI/stat blocks, (b) tables/lists that need a visible
/// frame, (c) alerts with an accent edge. Everything else is flat: compose
/// `SectionHeading` + content directly on `surface`, no wrapper card. If a
/// screen shows more than 4 bordered boxes at once, it's wrong.
class InfoCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;

  /// 3px left bar for state (overdue/warning), not a background wash.
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final Color? background;

  const InfoCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(16),
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
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
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: background ?? cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PistoTokens.radiusCard),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      clipBehavior: Clip.antiAlias,
      // IntrinsicHeight: stretch alone forces infinite height inside
      // unbounded-height parents (dashboard lists), blanking the screen.
      child: accentColor == null
          ? content
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: accentColor),
                  Expanded(child: content),
                ],
              ),
            ),
    );
  }
}
