import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../config/chart_spec.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../i18n/translations.g.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardPeriod _period = DashboardPeriod.month;

  final _fmt = currencyFmt;

  String _periodLabel() => switch (_period) {
        DashboardPeriod.week => 'últimos 7 días',
        DashboardPeriod.month => 'este mes',
        DashboardPeriod.quarter => 'este trimestre',
        DashboardPeriod.year => 'este año',
      };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 900;
    final dashboardAsync = ref.watch(dashboardDataProvider(_period));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardDataProvider(_period).future),
        child: AsyncValueWidget(
          value: dashboardAsync,
          loading: _DashboardSkeleton(isWide: isWide),
          onRetry: () => ref.invalidate(dashboardDataProvider(_period)),
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 24, isWide ? 32 : 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, user?.firstName, data.kpis),
                const SizedBox(height: 24),
                _buildHeroBand(theme, data.kpis),
                const SizedBox(height: 24),
                _buildStatStrip(theme, data.kpis),
                if (_buildSmartActions(theme, t, data.kpis) case final smartActions?) ...[
                  const SizedBox(height: 24),
                  smartActions,
                ],
                const SizedBox(height: 24),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildSalesTrendChart(theme, t, data.salesTrend)),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _buildCategoryChart(theme, t, data.salesByCategory)),
                    ],
                  )
                else ...[
                  _buildSalesTrendChart(theme, t, data.salesTrend),
                  const SizedBox(height: 20),
                  _buildCategoryChart(theme, t, data.salesByCategory),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme, String? firstName, Map<String, dynamic> kpis) {
    final trimmedName = firstName?.trim() ?? '';
    final name = trimmedName.isNotEmpty ? ', $trimmedName' : '';

    return PageHeader(
      title: '${greetingForHour()}$name',
      // Sales/invoices are already the hero number below: not repeated
      // here as a MetricChip (docs/RATIONALE.md §10, "same size = same group").
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/sales'),
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Nueva venta'),
        ),
      ],
      toolbar: [
        for (final p in DashboardPeriod.values)
          _PeriodChip(
            label: switch (p) {
              DashboardPeriod.week => '7 días',
              DashboardPeriod.month => 'Este mes',
              DashboardPeriod.quarter => 'Trimestre',
              DashboardPeriod.year => 'Este año',
            },
            selected: _period == p,
            onTap: () => setState(() => _period = p),
          ),
      ],
    );
  }

  // ── Hero band ──────────────────────────────────────────────────────────────

  // The screen's one block of color (docs/RATIONALE.md §12): hero number
  // + assistant summary in a single `primaryContainer` band. The rest of
  // the screen stays flat on `surface`.
  // No previous-period endpoint loaded: a delta is never invented.
  // Heuristic summary over dashboard data already loaded: there's no
  // insights endpoint yet, so it isn't labeled as AI-generated.
  Widget _buildHeroBand(ThemeData theme, Map<String, dynamic> kpis) {
    final cs = theme.colorScheme;
    final fg = cs.onPrimaryContainer;
    final monthlySales = kpis['monthlySales'] as Map<String, dynamic>? ?? {};
    final receivables = kpis['receivables'] as Map<String, dynamic>? ?? {};
    final lowStock = kpis['lowStock'] as Map<String, dynamic>? ?? {};

    final revenue = double.tryParse(monthlySales['revenue']?.toString() ?? '0') ?? 0;
    final salesCount = int.tryParse(monthlySales['sales_count']?.toString() ?? '0') ?? 0;
    final pendingAmount = double.tryParse(receivables['total_pending']?.toString() ?? '0') ?? 0;
    final pendingCount = int.tryParse(receivables['pending_count']?.toString() ?? '0') ?? 0;
    final lowStockCount = int.tryParse(lowStock['low_stock_count']?.toString() ?? '0') ?? 0;

    final insights = <String>[
      if (pendingAmount > 0)
        'Te deben ${_fmt.format(pendingAmount)} en $pendingCount cuenta${pendingCount == 1 ? '' : 's'} por cobrar.',
      if (lowStockCount > 0)
        '$lowStockCount producto${lowStockCount == 1 ? ' está' : 's están'} con stock bajo.',
    ];
    if (insights.isEmpty) {
      insights.add('Cuando registrés ventas y gastos, acá vas a ver un resumen de tu negocio.');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigFigure(
            label: 'Ventas · ${_periodLabel()}',
            value: _fmt.format(revenue),
            size: BigFigureSize.xl,
            valueColor: fg,
            caption: '$salesCount factura${salesCount == 1 ? '' : 's'} emitida${salesCount == 1 ? '' : 's'} en el período',
          ).animate().fadeIn(duration: 150.ms),
          SectionHeading(
            title: 'Tu resumen',
            // The one non-feed IconBadge allowed on this screen (docs/DESIGN-VOICE.md §1).
            trailing: IconBadge(icon: LucideIcons.sparkles, color: cs.primary, size: IconBadgeSize.s),
          ),
          ...insights.take(2).map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                s,
                style: theme.textTheme.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.85), height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/ai-chat'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: fg.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.sparkles, size: 15, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Preguntale a Pisto…',
                        style: theme.textTheme.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.8)),
                      ),
                    ),
                    Icon(LucideIcons.arrowRight, size: 15, color: fg.withValues(alpha: 0.8)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat strip ─────────────────────────────────────────────────────────────

  Widget _buildStatStrip(ThemeData theme, Map<String, dynamic> kpis) {
    final tokens = context.tokens;
    final cs = theme.colorScheme;
    final monthlySales = kpis['monthlySales'] as Map<String, dynamic>? ?? {};
    final receivables = kpis['receivables'] as Map<String, dynamic>? ?? {};

    final revenue = double.tryParse(monthlySales['revenue']?.toString() ?? '0') ?? 0;
    final salesCount = int.tryParse(monthlySales['sales_count']?.toString() ?? '0') ?? 0;
    final avgSale = salesCount > 0 ? revenue / salesCount : 0.0;
    final pendingAmount = double.tryParse(receivables['total_pending']?.toString() ?? '0') ?? 0;
    final pendingCount = int.tryParse(receivables['pending_count']?.toString() ?? '0') ?? 0;

    final stats = [
      BigFigure(
        label: 'Ticket promedio',
        value: _fmt.format(avgSale),
        size: BigFigureSize.s,
        caption: 'por venta',
      ),
      BigFigure(
        label: 'Por cobrar',
        value: _fmt.format(pendingAmount),
        size: BigFigureSize.s,
        caption: '$pendingCount cuenta${pendingCount == 1 ? '' : 's'}',
        valueColor: pendingAmount > 0 ? tokens.warningText : null,
      ),
    ];

    // Flat row of BigFigures, no wrapping InfoCard (calmer than
    // boxing the whole strip, docs/DESIGN-VOICE.md §1).
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth <= Breakpoints.gridDense;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                stats[i],
                if (i < stats.length - 1) ...[
                  const SizedBox(height: 16),
                  Divider(height: 1, thickness: 1, color: cs.outlineVariant),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              Expanded(child: stats[i]),
              if (i < stats.length - 1) const SizedBox(width: 32),
            ],
          ],
        );
      },
    );
  }

  // ── Smart actions ──────────────────────────────────────────────────────────

  // Returns null when there's nothing to act on: the "Lo que necesita tu
  // atención" heading must not render without a real action behind it.
  Widget? _buildSmartActions(ThemeData theme, Translations t, Map<String, dynamic> kpis) {
    final receivables = kpis['receivables'] as Map<String, dynamic>? ?? {};
    final lowStock = kpis['lowStock'] as Map<String, dynamic>? ?? {};

    final pendingAmount = double.tryParse(receivables['total_pending']?.toString() ?? '0') ?? 0;
    final pendingCount = int.tryParse(receivables['pending_count']?.toString() ?? '0') ?? 0;
    final lowStockCount = int.tryParse(lowStock['low_stock_count']?.toString() ?? '0') ?? 0;

    final actions = <_SmartAction>[];

    if (pendingAmount > 0) {
      actions.add(_SmartAction(
        intent: ChipIntent.warning,
        icon: LucideIcons.wallet,
        title: 'Te deben ${_fmt.format(pendingAmount)}',
        body: '$pendingCount cliente${pendingCount == 1 ? '' : 's'} con cuentas pendientes.',
        route: '/collections',
      ));
    }

    if (lowStockCount > 0) {
      actions.add(_SmartAction(
        intent: ChipIntent.danger,
        icon: LucideIcons.packageOpen,
        title: '$lowStockCount producto${lowStockCount == 1 ? ' está' : 's están'} a punto de agotarse',
        body: 'Reponé inventario antes que se acaben.',
        route: '/inventory',
      ));
    }

    if (actions.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Lo que necesita tu atención', spaceBefore: 0),
        for (var i = 0; i < actions.length; i++)
          _SmartActionRow(action: actions[i], showDivider: i < actions.length - 1),
      ],
    );
  }

  // ── Charts ─────────────────────────────────────────────────────────────────

  Widget _buildSalesTrendChart(ThemeData theme, Translations t, List<dynamic> salesTrend) {
    final cs = theme.colorScheme;

    if (salesTrend.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(title: 'Tendencia de ventas', spaceBefore: 0),
          const EmptyState.compact(title: 'Sin datos en el período'),
        ],
      );
    }

    final spots = <FlSpot>[];
    final labels = <int, String>{};

    for (var i = 0; i < salesTrend.length; i++) {
      final item = salesTrend[i] as Map<String, dynamic>;
      final revenue = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0;
      spots.add(FlSpot(i.toDouble(), revenue));

      if (salesTrend.length <= 10 || i % (salesTrend.length ~/ 6) == 0 || i == salesTrend.length - 1) {
        final dateStr = item['date']?.toString() ?? '';
        if (dateStr.length >= 10) {
          labels[i] = '${dateStr.substring(8, 10)}/${dateStr.substring(5, 7)}';
        }
      }
    }

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final lineColor = ChartSpec.palette(context).first;
    final axisLabelStyle = ChartSpec.axisLabel(context);
    final categoryLabelStyle = ChartSpec.axisLabel(context, mono: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Tendencia de ventas', spaceBefore: 0),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: ChartSpec.grid(context, interval: maxY > 0 ? maxY / 4 : 1),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final label = labels[value.toInt()];
                      if (label == null) return const SizedBox.shrink();
                      return SideTitleWidget(meta: meta, child: Text(label, style: categoryLabelStyle));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: maxY > 0 ? maxY / 4 : 1,
                    getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: axisLabelStyle),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: lineColor,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 3,
                      color: lineColor,
                      strokeWidth: 1.5,
                      strokeColor: cs.surface,
                    ),
                  ),
                  // Sparkline fade: dataviz exemption to the no-gradient rule,
                  // kept subtle (12% → 0% alpha).
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [lineColor.withValues(alpha: 0.12), lineColor.withValues(alpha: 0.0)],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => cs.surfaceContainerHigh,
                  tooltipBorder: BorderSide(color: cs.outlineVariant),
                  tooltipBorderRadius: BorderRadius.circular(10),
                  getTooltipItems: (spots) => spots.map((spot) {
                    final idx = spot.spotIndex;
                    final item = salesTrend[idx] as Map<String, dynamic>;
                    return LineTooltipItem(
                      '${item['date']}\n\$${spot.y.toStringAsFixed(2)}',
                      ChartSpec.tooltipValueStyle(context),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(ThemeData theme, Translations t, List<dynamic> salesByCategory) {
    final cs = theme.colorScheme;

    if (salesByCategory.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(title: 'Ventas por categoría', spaceBefore: 0),
          const EmptyState.compact(title: 'Sin datos'),
        ],
      );
    }

    final colors = ChartSpec.palette(context);

    double totalRevenue = 0;
    for (final item in salesByCategory) {
      totalRevenue += double.tryParse((item as Map<String, dynamic>)['revenue']?.toString() ?? '0') ?? 0;
    }

    final sections = <PieChartSectionData>[];
    final legends = <_LegendItem>[];

    for (var i = 0; i < salesByCategory.length && i < 6; i++) {
      final item = salesByCategory[i] as Map<String, dynamic>;
      final revenue = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0;
      final pct = totalRevenue > 0 ? (revenue / totalRevenue * 100) : 0.0;
      final color = colors[i % colors.length];

      sections.add(PieChartSectionData(
        value: revenue,
        color: color,
        radius: 38,
        title: '${pct.toStringAsFixed(0)}%',
        // Labels outside the slice: some chartPalette colors (amber,
        // light teal) don't give 3:1 with white text on top (WCAG 2.2 SC 1.4.11).
        // Outside the donut, over `surface`, onSurface carries the contrast.
        titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface),
        titlePositionPercentageOffset: 1.3,
      ));

      legends.add(_LegendItem(color, item['category']?.toString() ?? '', _fmt.format(revenue)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Ventas por categoría', spaceBefore: 0),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(sections: sections, centerSpaceRadius: 35, sectionsSpace: 2),
          ),
        ),
        const SizedBox(height: 16),
        ...legends.map((l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: l.color, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.label, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(l.value, style: ChartSpec.tooltipValueStyle(context)),
                ],
              ),
            )),
      ],
    );
  }

}

// ── Period chip ───────────────────────────────────────────────────────────────

// Not migrated to `PTabs` (shared/widgets/p_tabs.dart): elsewhere in the app
// `PTabs` is always used to switch content VIEWS with counts
// (Invoices/Clients, Orders/Suppliers) with its underline-tab chrome.
// Here the toggle is a TIME RANGE selector (7 days/month/quarter/year):
// a different use that already lives as a selectable pill in `PageHeader`'s
// `toolbar`. Forcing `PTabs` here would introduce the only underline-tab
// use for this semantic and break visual consistency with the rest
// of the screens, so the pill stays hand-rolled.
class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PistoTokens.radiusChip),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(PistoTokens.radiusChip),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Smart action row ──────────────────────────────────────────────────────────

class _SmartAction {
  final ChipIntent intent;
  final IconData icon;
  final String title;
  final String body;
  final String route;

  const _SmartAction({
    required this.intent,
    required this.icon,
    required this.title,
    required this.body,
    required this.route,
  });
}

class _SmartActionRow extends StatelessWidget {
  final _SmartAction action;
  final bool showDivider;
  const _SmartActionRow({required this.action, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = context.tokens;
    final color = switch (action.intent) {
      ChipIntent.success => tokens.success,
      ChipIntent.warning => tokens.warning,
      ChipIntent.danger => tokens.danger,
      ChipIntent.info => tokens.info,
      ChipIntent.brand => cs.primary,
      ChipIntent.neutral => cs.onSurfaceVariant,
    };

    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: AppTheme.borderSubtle(context)))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(action.route),
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconBadge(icon: action.icon, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        action.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        action.body,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(LucideIcons.chevronRight, size: 16, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chart legend ──────────────────────────────────────────────────────────────

class _LegendItem {
  final Color color;
  final String label;
  final String value;

  const _LegendItem(this.color, this.label, this.value);
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

// Mirrors the real screen: flat on `surface` except for the hero's color
// band, no bordered filler boxes (docs/DESIGN-VOICE.md §1): loading
// must not promise a card-based dashboard that never shows up.
class _DashboardSkeleton extends StatelessWidget {
  final bool isWide;
  const _DashboardSkeleton({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 24, isWide ? 32 : 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonBox(width: 220, height: 22, radius: 6),
              Spacer(),
              SkeletonBox(width: 130, height: 40, radius: 14),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SkeletonBox(width: 70 + i * 8.0, height: 32, radius: 20),
                )),
          ),
          const SizedBox(height: 24),
          // Hero band: the real screen's one block of color, no
          // border (docs/RATIONALE.md §12).
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: 14),
                SkeletonBox(width: 260, height: 44, radius: 10),
                SizedBox(height: 12),
                SkeletonBox(width: 180, height: 12),
                SizedBox(height: 28),
                SkeletonBox(width: 130, height: 16, radius: 6),
                SizedBox(height: 16),
                SkeletonBox(width: double.infinity, height: 12),
                SizedBox(height: 6),
                SkeletonBox(width: 220, height: 12),
                SizedBox(height: 14),
                SkeletonBox(width: double.infinity, height: 44, radius: 14),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isNarrow = constraints.maxWidth <= Breakpoints.gridDense;
              final statWidth = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 32) / 2;
              return Wrap(
                spacing: 32,
                runSpacing: 16,
                children: List.generate(2, (_) => _MicroStatSkeleton(width: statWidth)),
              );
            },
          ),
          const SizedBox(height: 24),
          Column(
            children: List.generate(2, (_) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: _SmartActionSkeleton(),
                )),
          ),
          const SizedBox(height: 24),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 3, child: _ChartSkeleton(height: 250)),
                SizedBox(width: 20),
                Expanded(flex: 2, child: _ChartSkeleton(height: 250)),
              ],
            )
          else ...[
            const _ChartSkeleton(height: 250),
            const SizedBox(height: 20),
            const _ChartSkeleton(height: 250),
          ],
        ],
      ),
    );
  }
}

// Mirrors flat `BigFigure`, no wrapping box or border.
class _MicroStatSkeleton extends StatelessWidget {
  final double width;
  const _MicroStatSkeleton({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          SkeletonBox(width: 100, height: 11),
          SizedBox(height: 12),
          SkeletonBox(width: 130, height: 20, radius: 6),
          SizedBox(height: 6),
          SkeletonBox(width: 70, height: 11),
        ],
      ),
    );
  }
}

class _SmartActionSkeleton extends StatelessWidget {
  const _SmartActionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonBox(width: 32, height: 32, radius: 12),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 220, height: 14),
              SizedBox(height: 6),
              SkeletonBox(width: 160, height: 11),
            ],
          ),
        ),
      ],
    );
  }
}

// Mirrors a flat chart section: `SectionHeading` skeleton + drawing
// area, no wrapping card (the real screen doesn't box the charts).
class _ChartSkeleton extends StatelessWidget {
  final double height;
  const _ChartSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 140, height: 16),
          const SizedBox(height: 20),
          const Expanded(
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              radius: 8,
            ),
          ),
        ],
      ),
    );
  }
}
