import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  Map<String, dynamic>? _salesSummary;
  List<dynamic> _topProducts = [];
  dynamic _grossProfit;
  List<dynamic> _inventoryValuation = [];
  bool _loading = true;

  final _fmt = currencyFmt;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final svc = ref.read(reportsServiceProvider);
      final results = await Future.wait([
        svc.getSalesSummary(),
        svc.getTopProducts(limit: 5),
        svc.getGrossProfit(),
        svc.getInventoryValuation(),
      ]);
      setState(() {
        _salesSummary = results[0] as Map<String, dynamic>;
        _topProducts = results[1] as List<dynamic>;
        _grossProfit = results[2];
        _inventoryValuation = results[3] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.parseError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > Breakpoints.gridDense;
    final isExtra = width > 900;

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      eyebrow: 'INSIGHTS',
                      title: 'Cómo va tu negocio',
                      meta: 'Resumen y tendencias del mes en curso.',
                    ),
                    const SizedBox(height: 24),
                    _buildSalesSummaryCards(theme),
                    const SizedBox(height: 24),
                    if (isExtra)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildTopProductsChart(theme)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildGrossProfitSection(theme)),
                        ],
                      )
                    else ...[
                      _buildTopProductsChart(theme),
                      const SizedBox(height: 20),
                      _buildGrossProfitSection(theme),
                    ],
                    const SizedBox(height: 20),
                    _buildInventoryValuationTable(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSalesSummaryCards(ThemeData theme) {
    final cs = theme.colorScheme;
    if (_salesSummary == null) return const SizedBox.shrink();

    final items = [
      _SummaryItem('Total Ventas', _salesSummary!['total_sales']?.toString() ?? '0', LucideIcons.shoppingBag, cs.primary),
      _SummaryItem('Ingresos', _fmt.format(double.tryParse(_salesSummary!['total_revenue']?.toString() ?? '0') ?? 0), LucideIcons.dollarSign, cs.secondary),
      _SummaryItem('Impuestos', _fmt.format(double.tryParse(_salesSummary!['total_tax']?.toString() ?? '0') ?? 0), LucideIcons.receipt, cs.tertiary),
      _SummaryItem('Descuentos', _fmt.format(double.tryParse(_salesSummary!['total_discount']?.toString() ?? '0') ?? 0), LucideIcons.tag, cs.error),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.calendarDays, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('Resumen de Ventas (mes actual)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth > Breakpoints.gridDense ? 4 : 2;
            const gap = 12.0;
            final cardWidth = (constraints.maxWidth - gap * (crossCount - 1)) / crossCount;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(items.length, (i) {
                final item = items[i];
                return SizedBox(
                  width: cardWidth,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: AppTheme.borderSubtle(context)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(item.icon, size: 16, color: item.color),
                              const SizedBox(width: 6),
                              Expanded(child: Text(item.label, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AutoSizeText(
                            item.value,
                            style: AppTheme.mono(fontSize: 20, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            minFontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopProductsChart(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_topProducts.isEmpty) {
      return _SectionCard(
        title: 'Top 5 Productos',
        icon: LucideIcons.trophy,
        child: SizedBox(height: 200, child: Center(child: Text('Sin datos', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))),
      );
    }

    final maxRevenue = _topProducts.fold<double>(0, (max, item) {
      final rev = double.tryParse((item as Map<String, dynamic>)['total_revenue']?.toString() ?? '0') ?? 0;
      return rev > max ? rev : max;
    });

    return _SectionCard(
      title: 'Top 5 Productos',
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
              getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.borderSubtle(context), strokeWidth: 1),
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
                  getTitlesWidget: (value, meta) => Text('\$${value.toInt()}', style: AppTheme.mono(fontSize: 10, color: cs.onSurfaceVariant)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= _topProducts.length) return const SizedBox.shrink();
                    final name = (_topProducts[value.toInt()] as Map<String, dynamic>)['name']?.toString() ?? '';
                    final short = name.length > 12 ? '${name.substring(0, 12)}...' : name;
                    return SideTitleWidget(meta: meta, angle: -0.4, child: Text(short, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)));
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => cs.inverseSurface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final name = (_topProducts[group.x] as Map<String, dynamic>)['name'] ?? '';
                  return BarTooltipItem('$name\n${_fmt.format(rod.toY)}', AppTheme.mono(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onInverseSurface));
                },
              ),
            ),
            barGroups: List.generate(_topProducts.length, (i) {
              final revenue = double.tryParse((_topProducts[i] as Map<String, dynamic>)['total_revenue']?.toString() ?? '0') ?? 0;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: revenue,
                    width: 28,
                    color: cs.primary.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildGrossProfitSection(ThemeData theme) {
    final cs = theme.colorScheme;

    final data = _grossProfit is Map<String, dynamic> ? (_grossProfit as Map<String, dynamic>) : null;
    if (data == null) {
      return _SectionCard(
        title: 'Margen Bruto',
        icon: LucideIcons.percent,
        child: SizedBox(height: 200, child: Center(child: Text('Sin datos', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)))),
      );
    }
    final revenue = double.tryParse(data['revenue']?.toString() ?? '0') ?? 0;
    final cost = double.tryParse(data['cost']?.toString() ?? '0') ?? 0;
    final profit = double.tryParse(data['gross_profit']?.toString() ?? '0') ?? 0;
    final marginPct = double.tryParse(data['margin_pct']?.toString() ?? '0') ?? 0;

    return _SectionCard(
      title: 'Margen Bruto',
      icon: LucideIcons.percent,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: profit,
                    color: cs.primary,
                    radius: 45,
                    title: 'Utilidad\n${marginPct.toStringAsFixed(1)}%',
                    titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
                    titlePositionPercentageOffset: 0.55,
                  ),
                  PieChartSectionData(
                    value: cost,
                    color: cs.error.withValues(alpha: 0.7),
                    radius: 40,
                    title: 'Costo',
                    titleStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
                    titlePositionPercentageOffset: 0.55,
                  ),
                ],
                centerSpaceRadius: 30,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ProfitRow(icon: LucideIcons.arrowUpRight, label: 'Ingresos', value: _fmt.format(revenue), color: cs.primary),
          const SizedBox(height: 6),
          _ProfitRow(icon: LucideIcons.arrowDownRight, label: 'Costo', value: _fmt.format(cost), color: cs.error),
          const Divider(height: 16),
          _ProfitRow(icon: LucideIcons.trendingUp, label: 'Utilidad Bruta', value: _fmt.format(profit), color: cs.secondary),
        ],
      ),
    );
  }

  Widget _buildInventoryValuationTable(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_inventoryValuation.isEmpty) {
      return _SectionCard(
        title: 'Valuación de Inventario',
        icon: LucideIcons.warehouse,
        child: Center(child: Text('Sin datos', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
      );
    }

    final topItems = _inventoryValuation.take(10).toList();

    return _SectionCard(
      title: 'Valuación de Inventario (Top 10)',
      icon: LucideIcons.warehouse,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 40,
          columnSpacing: 24,
          headingTextStyle: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
          columns: const [
            DataColumn(label: Text('Producto')),
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Stock'), numeric: true),
            DataColumn(label: Text('Costo Unit.'), numeric: true),
            DataColumn(label: Text('Valuación'), numeric: true),
          ],
          rows: topItems.map((item) {
            final p = item as Map<String, dynamic>;
            return DataRow(cells: [
              DataCell(Text(p['name']?.toString() ?? '', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500))),
              DataCell(Text(p['sku']?.toString() ?? '', style: theme.textTheme.bodySmall)),
              DataCell(Text(p['total_stock']?.toString() ?? '0', style: theme.textTheme.bodySmall)),
              DataCell(Text(_fmt.format(double.tryParse(p['cost_price']?.toString() ?? '0') ?? 0), style: AppTheme.mono(fontSize: 12))),
              DataCell(Text(
                _fmt.format(double.tryParse(p['valuation']?.toString() ?? '0') ?? 0),
                style: AppTheme.mono(fontSize: 12, fontWeight: FontWeight.w600),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem(this.label, this.value, this.icon, this.color);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.borderSubtle(context)),
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
                  child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
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

class _ProfitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProfitRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        Text(value, style: AppTheme.mono(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
