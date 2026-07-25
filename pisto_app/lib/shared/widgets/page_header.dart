import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Compact page header: single-line title + inline metric chips + actions.
/// Usage: `PageHeader(title: 'Tus ventas', metrics: [MetricChip(label: 'Facturas',
/// value: '24')], actions: [FilledButton(...)])`. Max height ~64px — no kicker,
/// no display titles, no mono subtitle eating vertical space (see docs/DESIGN.md §1).
class PageHeader extends StatelessWidget {
  /// The screen's single title, `titleLarge` (~22px).
  final String title;

  /// `MetricChip`s inline next to the title (e.g. count · total).
  final List<Widget> metrics;

  /// Actions on the right (primary button + secondary ones).
  final List<Widget> actions;

  /// Optional secondary row below the header (filters, periods).
  final List<Widget>? toolbar;

  const PageHeader({
    super.key,
    required this.title,
    this.metrics = const [],
    this.actions = const [],
    this.toolbar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < Breakpoints.compact;

    final titleAndMetrics = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        ...metrics,
      ],
    );

    final headerRow = isCompact || actions.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              titleAndMetrics,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: actions),
              ],
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: titleAndMetrics),
              const SizedBox(width: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: actions,
              ),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        headerRow,
        if (toolbar != null && toolbar!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: toolbar!),
        ],
      ],
    );
  }
}

/// Time-of-day greeting. Returns "Buenos días", "Buenas tardes",
/// "Buenas noches" — used on the dashboard.
String greetingForHour([DateTime? when]) {
  final h = (when ?? DateTime.now()).hour;
  if (h < 6) return 'Buenas noches';
  if (h < 13) return 'Buenos días';
  if (h < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

/// Short Spanish date format: "Lunes 7 de mayo".
String formatLongDateEs(DateTime d) {
  const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  const months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  return '${days[d.weekday - 1]} ${d.day} de ${months[d.month - 1]}';
}
