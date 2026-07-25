import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/app_theme.dart';
import '../../../config/chart_spec.dart';
import '../../../core/models/paginated.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/reports_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;

    final overviewAsync = ref.watch(reportsOverviewProvider);

    return Scaffold(
      body: AsyncValueWidget(
        value: overviewAsync,
        onRetry: () => ref.invalidate(reportsOverviewProvider),
        data: (overview) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(reportsOverviewProvider.future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Cómo va tu negocio',
                    actions: [
                      OutlinedButton(
                        onPressed: () => ref.invalidate(reportsOverviewProvider),
                        child: const Text('Actualizar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFinancialSummary(context, theme, overview.salesSummary, overview.grossProfit),
                  const SizedBox(height: 28),
                  _buildTopProductsChart(context, theme, overview.topProducts),
                  const SizedBox(height: 28),
                  _buildInventoryValuationTable(theme, overview.inventoryValuation),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Hero section: gross profit is the reason this screen exists, so it's
  /// the single `xl` figure; revenue/cost support it at `s`; tax/discount —
  /// figures nobody opens reports for — drop to a secondary text line.
  Widget _buildFinancialSummary(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> salesSummary,
    dynamic grossProfit,
  ) {
    final cs = theme.colorScheme;
    final data = grossProfit is Map<String, dynamic> ? grossProfit : null;

    Widget body;
    if (data == null) {
      body = const EmptyState.compact(
        title: 'Sin datos de utilidad',
        description: 'Aún no hay ventas registradas este mes.',
      );
    } else {
      final revenue = double.tryParse(data['revenue']?.toString() ?? '0') ?? 0;
      final cost = double.tryParse(data['cost']?.toString() ?? '0') ?? 0;
      final profit = double.tryParse(data['gross_profit']?.toString() ?? '0') ?? 0;
      final marginPct = double.tryParse(data['margin_pct']?.toString() ?? '0') ?? 0;
      final totalSales = salesSummary['total_sales']?.toString() ?? '0';
      final totalTax = double.tryParse(salesSummary['total_tax']?.toString() ?? '0') ?? 0;
      final totalDiscount = double.tryParse(salesSummary['total_discount']?.toString() ?? '0') ?? 0;

      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigFigure(
            label: 'Utilidad bruta',
            value: currencyFmt.format(profit),
            size: BigFigureSize.xl,
            delta: '${marginPct.toStringAsFixed(1)}% margen',
            deltaPositive: marginPct >= 0,
            valueColor: AppTheme.accentText,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: BigFigure(
                  label: 'Ingresos',
                  value: currencyFmt.format(revenue),
                  size: BigFigureSize.s,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: BigFigure(
                  label: 'Costo',
                  value: currencyFmt.format(cost),
                  size: BigFigureSize.s,
                  valueColor: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$totalSales ventas · ${currencyFmt.format(totalTax)} impuestos · ${currencyFmt.format(totalDiscount)} descuentos',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Cómo te fue este mes'),
        const SizedBox(height: 12),
        body,
      ],
    );
  }

  Widget _buildTopProductsChart(
    BuildContext context,
    ThemeData theme,
    List<dynamic> topProducts,
  ) {
    if (topProducts.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(title: 'Top 5 productos'),
          EmptyState.compact(
            title: 'Sin ventas todavía',
            description: 'Cuando registres ventas verás aquí tus productos más vendidos.',
          ),
        ],
      );
    }

    final cs = theme.colorScheme;
    final maxRevenue = topProducts.fold<double>(0, (max, item) {
      final rev = double.tryParse((item as Map<String, dynamic>)['total_revenue']?.toString() ?? '0') ?? 0;
      return rev > max ? rev : max;
    });
    final barColor = ChartSpec.palette(context).first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Top 5 productos'),
        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxRevenue * 1.15,
              gridData: ChartSpec.grid(context, interval: maxRevenue > 0 ? maxRevenue / 4 : 1),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 55,
                    interval: maxRevenue > 0 ? maxRevenue / 4 : 1,
                    getTitlesWidget: (value, meta) =>
                        Text('\$${value.toInt()}', style: ChartSpec.axisLabel(context)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= topProducts.length) return const SizedBox.shrink();
                      final name = (topProducts[value.toInt()] as Map<String, dynamic>)['name']?.toString() ?? '';
                      final short = name.length > 12 ? '${name.substring(0, 12)}...' : name;
                      return SideTitleWidget(
                        meta: meta,
                        angle: -0.4,
                        child: Text(short, style: ChartSpec.axisLabel(context, mono: false)),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => cs.surfaceContainerHigh,
                  tooltipBorder: BorderSide(color: cs.outlineVariant),
                  tooltipBorderRadius: BorderRadius.circular(10),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final name = (topProducts[group.x] as Map<String, dynamic>)['name'] ?? '';
                    return BarTooltipItem(
                      '$name\n${currencyFmt.format(rod.toY)}',
                      ChartSpec.tooltipValueStyle(context),
                    );
                  },
                ),
              ),
              barGroups: List.generate(topProducts.length, (i) {
                final revenue = double.tryParse((topProducts[i] as Map<String, dynamic>)['total_revenue']?.toString() ?? '0') ?? 0;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: revenue,
                      width: 28,
                      color: barColor,
                      borderRadius: ChartSpec.barRadius,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryValuationTable(ThemeData theme, List<dynamic> inventoryValuation) {
    final cs = theme.colorScheme;

    if (inventoryValuation.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(title: 'Valuación de inventario'),
          EmptyState.compact(
            title: 'Sin inventario valuado',
            description: 'Registra stock con costo para ver la valuación aquí.',
          ),
        ],
      );
    }

    final topItems = inventoryValuation.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Valuación de inventario', label: 'Top 10'),
        InfoCard(
          padding: EdgeInsets.zero,
          child: DataList<Map<String, dynamic>>(
            data: Paginated(
              data: topItems.cast<Map<String, dynamic>>(),
              meta: PageMeta(page: 1, limit: topItems.length, total: topItems.length, totalPages: 1),
            ),
            emptyState: const SizedBox.shrink(),
            columns: [
              DataListColumn<Map<String, dynamic>>(
                label: 'Producto',
                flex: 4,
                cell: (context, p) => Text(
                  p['name']?.toString() ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataListColumn<Map<String, dynamic>>(
                label: 'SKU',
                flex: 2,
                cell: (context, p) => Text(
                  p['sku']?.toString() ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              DataListColumn<Map<String, dynamic>>(
                label: 'Stock',
                flex: 1,
                align: TextAlign.right,
                cell: (context, p) => Text(
                  formatQty(double.tryParse(p['total_stock']?.toString() ?? '') ?? 0),
                  style: AppTheme.mono(fontSize: 13, color: cs.onSurface),
                ),
              ),
              DataListColumn<Map<String, dynamic>>(
                label: 'Costo unit.',
                flex: 2,
                align: TextAlign.right,
                isMoney: true,
                cell: (context, p) => Text(
                  currencyFmt.format(double.tryParse(p['cost_price']?.toString() ?? '0') ?? 0),
                  style: AppTheme.mono(fontSize: 13),
                ),
              ),
              DataListColumn<Map<String, dynamic>>(
                label: 'Valuación',
                flex: 2,
                align: TextAlign.right,
                isMoney: true,
                cell: (context, p) => Text(
                  currencyFmt.format(double.tryParse(p['valuation']?.toString() ?? '0') ?? 0),
                  style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
