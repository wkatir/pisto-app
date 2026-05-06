import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../i18n/translations.g.dart';

enum _Period { week, month, quarter, year }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? _kpis;
  List<dynamic> _salesTrend = [];
  List<dynamic> _topProducts = [];
  List<dynamic> _salesByCategory = [];
  bool _loading = true;
  _Period _period = _Period.month;

  final _fmt = currencyFmt;

  (DateTime, DateTime) _periodDates() {
    final now = DateTime.now();
    return switch (_period) {
      _Period.week => (now.subtract(const Duration(days: 7)), now),
      _Period.month => (DateTime(now.year, now.month, 1), now),
      _Period.quarter => (DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1), now),
      _Period.year => (DateTime(now.year, 1, 1), now),
    };
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final (start, end) = _periodDates();
    try {
      final svc = ref.read(reportsServiceProvider);
      final results = await Future.wait([
        svc.getDashboardKPIs(startDate: start, endDate: end),
        svc.getSalesTrend(days: 30, startDate: start, endDate: end),
        svc.getTopProducts(limit: 5, startDate: start, endDate: end),
        svc.getSalesByCategory(),
      ]);
      setState(() {
        _kpis = results[0] as Map<String, dynamic>;
        _salesTrend = results[1] as List<dynamic>;
        _topProducts = results[2] as List<dynamic>;
        _salesByCategory = results[3] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.parseError(e))),
        );
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? _DashboardSkeleton(isWide: isWide)
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user != null ? 'Hola, ${user.firstName}' : t.dashboard,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Panel de control',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Resumen en tiempo real de tu negocio',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _loadData,
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          tooltip: t.refresh,
                          style: IconButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                            backgroundColor: theme.colorScheme.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final p in _Period.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _PeriodChip(
                                label: switch (p) {
                                  _Period.week => '7 días',
                                  _Period.month => 'Este mes',
                                  _Period.quarter => 'Trimestre',
                                  _Period.year => 'Este año',
                                },
                                selected: _period == p,
                                onTap: () => setState(() { _period = p; _loadData(); }),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildKpiCards(theme, t),
                    const SizedBox(height: 24),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildSalesTrendChart(theme, t)),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: _buildCategoryChart(theme, t)),
                        ],
                      )
                    else ...[
                      _buildSalesTrendChart(theme, t),
                      const SizedBox(height: 24),
                      _buildCategoryChart(theme, t),
                    ],
                    const SizedBox(height: 24),
                    _buildTopProductsChart(theme, t),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildKpiCards(ThemeData theme, Translations t) {
    final cs = theme.colorScheme;
    final monthlySales = _kpis?['monthlySales'] as Map<String, dynamic>? ?? {};
    final receivables = _kpis?['receivables'] as Map<String, dynamic>? ?? {};
    final lowStock = _kpis?['lowStock'] as Map<String, dynamic>? ?? {};

    final revenue = double.tryParse(monthlySales['revenue']?.toString() ?? '0') ?? 0;
    final salesCount = int.tryParse(monthlySales['sales_count']?.toString() ?? '0') ?? 0;
    final avgSale = salesCount > 0 ? revenue / salesCount : 0.0;

    final kpis = [
      _KpiData(t.monthlySales, _fmt.format(revenue), t.invoicesCount(count: salesCount), LucideIcons.trendingUp, cs.primary, cs.primary.withValues(alpha: 0.1)),
      _KpiData(t.accountsReceivable, _fmt.format(double.tryParse(receivables['total_pending']?.toString() ?? '0') ?? 0), t.accounts(count: int.tryParse(receivables['pending_count']?.toString() ?? '0') ?? 0), LucideIcons.wallet, cs.tertiary, cs.tertiary.withValues(alpha: 0.1)),
      _KpiData(t.lowStock, '${int.tryParse(lowStock['low_stock_count']?.toString() ?? '0') ?? 0}', t.products_low, LucideIcons.triangleAlert, cs.error, cs.error.withValues(alpha: 0.1), route: '/inventory?tab=alerts'),
      _KpiData(t.averagePerSale, _fmt.format(avgSale), t.thisMonth, LucideIcons.chartColumn, cs.secondary, cs.secondary.withValues(alpha: 0.1)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > Breakpoints.gridDense + 100 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, i) => _KpiCard(data: kpis[i]),
        );
      },
    );
  }

  Widget _buildSalesTrendChart(ThemeData theme, Translations t) {
    final cs = theme.colorScheme;

    if (_salesTrend.isEmpty) {
      return _ChartCard(
        title: t.salesTrend,
        icon: LucideIcons.chartLine,
        child: const Center(child: Text('Sin datos de ventas')),
      );
    }

    final spots = <FlSpot>[];
    final labels = <int, String>{};

    for (var i = 0; i < _salesTrend.length; i++) {
      final item = _salesTrend[i] as Map<String, dynamic>;
      final revenue = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0;
      spots.add(FlSpot(i.toDouble(), revenue));

      if (_salesTrend.length <= 10 || i % (_salesTrend.length ~/ 6) == 0 || i == _salesTrend.length - 1) {
        final dateStr = item['date']?.toString() ?? '';
        if (dateStr.length >= 10) {
          labels[i] = '${dateStr.substring(8, 10)}/${dateStr.substring(5, 7)}';
        }
      }
    }

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return _ChartCard(
      title: t.salesTrend,
      icon: LucideIcons.chartLine,
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY > 0 ? maxY / 4 : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: cs.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 1,
              ),
            ),
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
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: cs.onSurfaceVariant)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: maxY > 0 ? maxY / 4 : 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: cs.onSurfaceVariant),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.25,
                color: cs.primary,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                    radius: 3,
                    color: cs.primary,
                    strokeWidth: 1.5,
                    strokeColor: cs.surface,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.primary.withValues(alpha: 0.2),
                      cs.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => cs.inverseSurface,
                getTooltipItems: (spots) => spots.map((spot) {
                  final idx = spot.spotIndex;
                  final item = _salesTrend[idx] as Map<String, dynamic>;
                  return LineTooltipItem(
                    '${item['date']}\n\$${spot.y.toStringAsFixed(2)}',
                    TextStyle(color: cs.onInverseSurface, fontSize: 12, fontWeight: FontWeight.w500),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChart(ThemeData theme, Translations t) {
    final cs = theme.colorScheme;

    if (_salesByCategory.isEmpty) {
      return _ChartCard(
        title: t.salesByCategory,
        icon: LucideIcons.chartPie,
        child: const Center(child: Text('Sin datos')),
      );
    }

    final colors = [
      cs.primary,
      cs.tertiary,
      cs.secondary,
      AppTheme.chartAmber,
      AppTheme.chartViolet,
      cs.error,
    ];

    double totalRevenue = 0;
    for (final item in _salesByCategory) {
      totalRevenue += double.tryParse((item as Map<String, dynamic>)['revenue']?.toString() ?? '0') ?? 0;
    }

    final sections = <PieChartSectionData>[];
    final legends = <_LegendItem>[];

    for (var i = 0; i < _salesByCategory.length && i < 6; i++) {
      final item = _salesByCategory[i] as Map<String, dynamic>;
      final revenue = double.tryParse(item['revenue']?.toString() ?? '0') ?? 0;
      final pct = totalRevenue > 0 ? (revenue / totalRevenue * 100) : 0.0;
      final color = colors[i % colors.length];

      sections.add(PieChartSectionData(
        value: revenue,
        color: color,
        radius: 40,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ));

      legends.add(_LegendItem(color, item['category']?.toString() ?? '', _fmt.format(revenue)));
    }

    return _ChartCard(
      title: t.salesByCategory,
      icon: LucideIcons.chartPie,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 35,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...legends.map((l) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: l.color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Expanded(child: Text(l.label, style: theme.textTheme.bodySmall)),
                Text(l.value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTopProductsChart(ThemeData theme, Translations t) {
    final cs = theme.colorScheme;

    if (_topProducts.isEmpty) {
      return _ChartCard(
        title: t.topProducts,
        icon: LucideIcons.trophy,
        child: const Center(child: Text('Sin datos')),
      );
    }

    final maxRevenue = _topProducts.fold<double>(0, (max, item) {
      final rev = double.tryParse((item as Map<String, dynamic>)['total_revenue']?.toString() ?? '0') ?? 0;
      return rev > max ? rev : max;
    });

    final barGroups = <BarChartGroupData>[];
    final names = <int, String>{};

    for (var i = 0; i < _topProducts.length; i++) {
      final item = _topProducts[i] as Map<String, dynamic>;
      final revenue = double.tryParse(item['total_revenue']?.toString() ?? '0') ?? 0;
      names[i] = item['name']?.toString() ?? '';

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: revenue,
            width: 28,
            color: cs.primary.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxRevenue * 1.1,
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
          ),
        ],
      ));
    }

    return _ChartCard(
      title: t.topProducts,
      icon: LucideIcons.trophy,
      child: SizedBox(
        height: 280,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxRevenue * 1.15,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxRevenue > 0 ? maxRevenue / 4 : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: cs.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 55,
                  interval: maxRevenue > 0 ? maxRevenue / 4 : 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: cs.onSurfaceVariant),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (value, meta) {
                    final name = names[value.toInt()] ?? '';
                    final short = name.length > 12 ? '${name.substring(0, 12)}...' : name;
                    return SideTitleWidget(
                      meta: meta,
                      angle: -0.4,
                      child: Text(short, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => cs.inverseSurface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${names[group.x]}\n${_fmt.format(rod.toY)}',
                    TextStyle(color: cs.onInverseSurface, fontSize: 12, fontWeight: FontWeight.w500),
                  );
                },
              ),
            ),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
}

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? route;

  const _KpiData(this.title, this.value, this.subtitle, this.icon, this.color, this.bgColor, {this.route});
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.route != null ? () => context.go(data.route!) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      data.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(data.icon, size: 15, color: data.color),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    data.value,
                    style: AppTheme.mono(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    minFontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ChartCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;
  final String value;

  const _LegendItem(this.color, this.label, this.value);
}

// ── Period chip ───────────────────────────────────────────────────────────────

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.turquoise : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.turquoise : const Color(0xFF2A2A2A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.black : const Color(0xFFAAAAAA),
          ),
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 700.ms, curve: Curves.easeIn)
        .fadeOut(delay: 700.ms, duration: 700.ms, curve: Curves.easeOut);
  }
}

class _DashboardSkeleton extends StatelessWidget {
  final bool isWide;
  const _DashboardSkeleton({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const _SkeletonBox(width: 200, height: 28),
          const SizedBox(height: 8),
          const _SkeletonBox(width: 260, height: 16),
          const SizedBox(height: 16),
          // Period chips
          Row(
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SkeletonBox(width: 60 + i * 12.0, height: 32, radius: 20),
            )),
          ),
          const SizedBox(height: 16),
          // KPI grid
          LayoutBuilder(
            builder: (ctx, constraints) {
              final crossCount = constraints.maxWidth > Breakpoints.gridDense + 100 ? 4 : 2;
              final cardWidth = (constraints.maxWidth - (crossCount - 1) * 16) / crossCount;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(4, (_) => _KpiSkeleton(width: cardWidth)),
              );
            },
          ),
          const SizedBox(height: 24),
          // Charts row
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _ChartSkeleton(height: 310)),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _ChartSkeleton(height: 310)),
              ],
            )
          else ...[
            _ChartSkeleton(height: 310),
            const SizedBox(height: 24),
            _ChartSkeleton(height: 310),
          ],
          const SizedBox(height: 24),
          _ChartSkeleton(height: 340),
        ],
      ),
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  final double width;
  const _KpiSkeleton({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width / 1.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SkeletonBox(width: 90, height: 12),
              _SkeletonBox(width: 28, height: 28, radius: 7),
            ],
          ),
          const Spacer(),
          const _SkeletonBox(width: 110, height: 22),
          const SizedBox(height: 6),
          const _SkeletonBox(width: 70, height: 12),
        ],
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  final double height;
  const _ChartSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              _SkeletonBox(width: 18, height: 18),
              SizedBox(width: 8),
              _SkeletonBox(width: 140, height: 16),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _SkeletonBox(
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
