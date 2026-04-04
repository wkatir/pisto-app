import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../i18n/translations.g.dart';

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

  final _fmt = currencyFmt;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final svc = ref.read(reportsServiceProvider);
      final results = await Future.wait([
        svc.getDashboardKPIs(),
        svc.getSalesTrend(days: 30),
        svc.getTopProducts(limit: 5),
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
    final cs = theme.colorScheme;
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.layoutDashboard, size: 28, color: cs.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.dashboard,
                                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  if (user != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        t.welcome(name: user.firstName),
                                        style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _loadData,
                              icon: const Icon(LucideIcons.refreshCw, size: 16),
                              label: Text(t.refresh),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
    final salesCount = monthlySales['sales_count'] as int? ?? 0;
    final avgSale = salesCount > 0 ? revenue / salesCount : 0.0;

    final kpis = [
      _KpiData(t.monthlySales, _fmt.format(revenue), t.invoicesCount(count: salesCount), LucideIcons.trendingUp, cs.primary, cs.primary.withValues(alpha: 0.1)),
      _KpiData(t.accountsReceivable, _fmt.format(double.tryParse(receivables['total_pending']?.toString() ?? '0') ?? 0), t.accounts(count: receivables['pending_count'] ?? 0), LucideIcons.wallet, cs.tertiary, cs.tertiary.withValues(alpha: 0.1)),
      _KpiData(t.lowStock, '${lowStock['low_stock_count'] ?? 0}', t.products_low, LucideIcons.alertTriangle, cs.error, cs.error.withValues(alpha: 0.1)),
      _KpiData(t.averagePerSale, _fmt.format(avgSale), t.thisMonth, LucideIcons.barChart3, cs.secondary, cs.secondary.withValues(alpha: 0.1)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
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
        icon: LucideIcons.lineChart,
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
      icon: LucideIcons.lineChart,
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
        icon: LucideIcons.pieChart,
        child: const Center(child: Text('Sin datos')),
      );
    }

    final colors = [
      cs.primary,
      cs.tertiary,
      cs.secondary,
      AppTheme.chartOrange,
      AppTheme.chartPurple,
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
      icon: LucideIcons.pieChart,
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

  const _KpiData(this.title, this.value, this.subtitle, this.icon, this.color, this.bgColor);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    data.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: data.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(data.icon, size: 18, color: data.color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AutoSizeText(
              data.value,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              minFontSize: 14,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
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
