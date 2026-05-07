import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../i18n/translations.g.dart';
import '../../../shared/widgets/widgets.dart';

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

  String _periodLabel() => switch (_period) {
        _Period.week => 'últimos 7 días',
        _Period.month => 'este mes',
        _Period.quarter => 'este trimestre',
        _Period.year => 'este año',
      };

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
                padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 32, isWide ? 32 : 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(theme, user?.firstName, t),
                    const SizedBox(height: 24),
                    _buildPeriodChips(theme),
                    const SizedBox(height: 28),
                    _buildHeroNumber(theme),
                    const SizedBox(height: 36),
                    _buildStatStrip(theme),
                    const SizedBox(height: 36),
                    _buildSmartActions(theme, t),
                    const SizedBox(height: 36),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildSalesTrendChart(theme, t)),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: _buildCategoryChart(theme, t)),
                        ],
                      )
                    else ...[
                      _buildSalesTrendChart(theme, t),
                      const SizedBox(height: 20),
                      _buildCategoryChart(theme, t),
                    ],
                    const SizedBox(height: 20),
                    _buildTopProductsChart(theme, t),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildGreeting(ThemeData theme, String? firstName, Translations t) {
    final cs = theme.colorScheme;
    final greeting = greetingForHour();
    final dateLine = formatLongDateEs(DateTime.now()).toUpperCase();
    final name = firstName?.trim().isNotEmpty == true ? ', ${firstName!.trim()}' : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLine,
                style: AppTheme.eyebrow(context, color: cs.primary),
              ),
              const SizedBox(height: 10),
              Text(
                '$greeting$name',
                style: AppTheme.serif(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  letterSpacing: -0.8,
                  height: 1.05,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Esto es lo que pasa con tu negocio hoy.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _loadData,
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          tooltip: t.refresh,
          style: IconButton.styleFrom(
            foregroundColor: cs.onSurfaceVariant,
            backgroundColor: cs.surfaceContainerHigh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChips(ThemeData theme) {
    return SingleChildScrollView(
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
                onTap: () => setState(() {
                  _period = p;
                  _loadData();
                }),
              ),
            ),
        ],
      ),
    );
  }

  // ── Hero number ────────────────────────────────────────────────────────────

  Widget _buildHeroNumber(ThemeData theme) {
    final cs = theme.colorScheme;
    final monthlySales = _kpis?['monthlySales'] as Map<String, dynamic>? ?? {};
    final revenue = double.tryParse(monthlySales['revenue']?.toString() ?? '0') ?? 0;
    final salesCount = int.tryParse(monthlySales['sales_count']?.toString() ?? '0') ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VENTAS · ${_periodLabel().toUpperCase()}',
            style: AppTheme.eyebrow(context, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          // AutoSizeText escala la cifra hacia abajo si overflowa el ancho del card,
          // evitando layout shift entre estado loading y datos cargados.
          SizedBox(
            width: double.infinity,
            child: AutoSizeText(
              _fmt.format(revenue),
              style: AppTheme.mono(
                fontSize: 56,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -1.5,
                height: 1.0,
              ),
              maxLines: 1,
              minFontSize: 28,
              stepGranularity: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.tintBg(context, AppTheme.success),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.trendingUp, size: 12, color: AppTheme.success),
                    const SizedBox(width: 4),
                    Text(
                      '$salesCount facturas',
                      style: AppTheme.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                        letterSpacing: 0,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'emitidas en el período',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── Stat strip ─────────────────────────────────────────────────────────────

  Widget _buildStatStrip(ThemeData theme) {
    final monthlySales = _kpis?['monthlySales'] as Map<String, dynamic>? ?? {};
    final receivables = _kpis?['receivables'] as Map<String, dynamic>? ?? {};

    final revenue = double.tryParse(monthlySales['revenue']?.toString() ?? '0') ?? 0;
    final salesCount = int.tryParse(monthlySales['sales_count']?.toString() ?? '0') ?? 0;
    final avgSale = salesCount > 0 ? revenue / salesCount : 0.0;
    final pendingAmount = double.tryParse(receivables['total_pending']?.toString() ?? '0') ?? 0;
    final pendingCount = int.tryParse(receivables['pending_count']?.toString() ?? '0') ?? 0;

    final stats = [
      _MicroStat(
        eyebrow: 'TICKET PROMEDIO',
        value: _fmt.format(avgSale),
        meta: 'por venta',
        icon: LucideIcons.receipt,
      ),
      _MicroStat(
        eyebrow: 'POR COBRAR',
        value: _fmt.format(pendingAmount),
        meta: '$pendingCount cuenta${pendingCount == 1 ? '' : 's'}',
        icon: LucideIcons.wallet,
        valueColor: pendingAmount > 0 ? AppTheme.warning : null,
      ),
      _MicroStat(
        eyebrow: 'FACTURAS',
        value: '$salesCount',
        meta: 'emitidas',
        icon: LucideIcons.fileText,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > Breakpoints.gridDense ? 3 : 1;
        const gap = 12.0;
        final cardWidth = (constraints.maxWidth - gap * (crossCount - 1)) / crossCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: stats
              .map((s) => SizedBox(
                    width: cardWidth,
                    child: _MicroStatCard(stat: s),
                  ))
              .toList(),
        );
      },
    );
  }

  // ── Smart actions ──────────────────────────────────────────────────────────

  Widget _buildSmartActions(ThemeData theme, Translations t) {
    final cs = theme.colorScheme;
    final receivables = _kpis?['receivables'] as Map<String, dynamic>? ?? {};
    final lowStock = _kpis?['lowStock'] as Map<String, dynamic>? ?? {};

    final pendingAmount = double.tryParse(receivables['total_pending']?.toString() ?? '0') ?? 0;
    final pendingCount = int.tryParse(receivables['pending_count']?.toString() ?? '0') ?? 0;
    final lowStockCount = int.tryParse(lowStock['low_stock_count']?.toString() ?? '0') ?? 0;

    final actions = <_SmartAction>[];

    if (pendingAmount > 0) {
      actions.add(_SmartAction(
        intent: ChipIntent.warning,
        icon: LucideIcons.wallet,
        title: 'Te deben ${_fmt.format(pendingAmount)}',
        body: '$pendingCount cliente${pendingCount == 1 ? '' : 's'} con cuentas pendientes. Hacé seguimiento o registrá los pagos.',
        actionLabel: 'Ver cobros',
        route: '/collections',
      ));
    }

    if (lowStockCount > 0) {
      actions.add(_SmartAction(
        intent: ChipIntent.danger,
        icon: LucideIcons.packageOpen,
        title: '$lowStockCount producto${lowStockCount == 1 ? ' está' : 's están'} a punto de agotarse',
        body: 'Reponé inventario antes que se acaben para no perder ventas.',
        actionLabel: 'Ver alertas',
        route: '/inventory',
      ));
    }

    actions.add(_SmartAction(
      intent: ChipIntent.brand,
      icon: LucideIcons.plus,
      title: '¿Listo para una nueva venta?',
      body: 'Crea una factura en segundos y cobrá al instante o a crédito.',
      actionLabel: 'Nueva venta',
      route: '/sales',
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Lo que necesita tu atención',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        ...actions.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SmartActionCard(action: e.value),
              ),
            ),
      ],
    );
  }

  // ── Charts ─────────────────────────────────────────────────────────────────

  Widget _buildSalesTrendChart(ThemeData theme, Translations t) {
    final cs = theme.colorScheme;

    if (_salesTrend.isEmpty) {
      return _ChartCard(
        title: 'Tendencia de ventas',
        icon: LucideIcons.chartLine,
        child: const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Sin datos en el período'))),
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
      title: 'Tendencia de ventas',
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
                      cs.primary.withValues(alpha: 0.06),
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
        title: 'Ventas por categoría',
        icon: LucideIcons.chartPie,
        child: const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Sin datos'))),
      );
    }

    final colors = [
      cs.primary,
      AppTheme.chartTeal,
      AppTheme.chartViolet,
      AppTheme.chartAmber,
      AppTheme.chartCoral,
      AppTheme.info,
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
        radius: 38,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ));

      legends.add(_LegendItem(color, item['category']?.toString() ?? '', _fmt.format(revenue)));
    }

    return _ChartCard(
      title: 'Ventas por categoría',
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
                    Expanded(child: Text(l.label, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(l.value, style: AppTheme.mono(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
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
        title: 'Productos más vendidos',
        icon: LucideIcons.trophy,
        child: const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Sin datos'))),
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
            color: cs.primary.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ));
    }

    return _ChartCard(
      title: 'Productos más vendidos',
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

// ── Period chip ───────────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
            ),
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

// ── Micro stat card ───────────────────────────────────────────────────────────

class _MicroStat {
  final String eyebrow;
  final String value;
  final String meta;
  final IconData icon;
  final Color? valueColor;

  const _MicroStat({
    required this.eyebrow,
    required this.value,
    required this.meta,
    required this.icon,
    this.valueColor,
  });
}

class _MicroStatCard extends StatelessWidget {
  final _MicroStat stat;
  const _MicroStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(stat.icon, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stat.eyebrow,
                  style: AppTheme.eyebrow(context, color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            stat.value,
            style: AppTheme.mono(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: stat.valueColor ?? cs.onSurface,
              letterSpacing: -0.6,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            stat.meta,
            style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Smart action card ─────────────────────────────────────────────────────────

class _SmartAction {
  final ChipIntent intent;
  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final String route;

  const _SmartAction({
    required this.intent,
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.route,
  });
}

class _SmartActionCard extends StatelessWidget {
  final _SmartAction action;
  const _SmartActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = switch (action.intent) {
      ChipIntent.success => AppTheme.success,
      ChipIntent.warning => AppTheme.warning,
      ChipIntent.danger => AppTheme.danger,
      ChipIntent.info => AppTheme.info,
      ChipIntent.brand => cs.primary,
      ChipIntent.neutral => cs.onSurfaceVariant,
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.go(action.route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderSubtle(context)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.tintBg(context, color),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(action.icon, size: 18, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.tintBg(context, color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.actionLabel,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, size: 13, color: color),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chart card ────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _ChartCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
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
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;
  final String value;

  const _LegendItem(this.color, this.label, this.value);
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
        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 32, isWide ? 32 : 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(width: 140, height: 12),
          const SizedBox(height: 12),
          const _SkeletonBox(width: 280, height: 36, radius: 10),
          const SizedBox(height: 8),
          const _SkeletonBox(width: 220, height: 14),
          const SizedBox(height: 24),
          Row(
            children: List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _SkeletonBox(width: 70 + i * 8.0, height: 32, radius: 20),
                )),
          ),
          const SizedBox(height: 28),
          // Hero — altura intrínseca (mismo cálculo que la card real cargada)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle(context)),
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkeletonBox(width: 160, height: 12),
                SizedBox(height: 14),
                _SkeletonBox(width: 240, height: 48, radius: 10),
                SizedBox(height: 14),
                _SkeletonBox(width: 180, height: 22, radius: 6),
              ],
            ),
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final crossCount = constraints.maxWidth > Breakpoints.gridDense ? 3 : 1;
              final cardWidth = (constraints.maxWidth - (crossCount - 1) * 12) / crossCount;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(3, (_) => _MicroStatSkeleton(width: cardWidth)),
              );
            },
          ),
          const SizedBox(height: 36),
          ...List.generate(2, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SmartActionSkeleton(),
              )),
          const SizedBox(height: 26),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 3, child: _ChartSkeleton(height: 320)),
                SizedBox(width: 20),
                Expanded(flex: 2, child: _ChartSkeleton(height: 320)),
              ],
            )
          else ...[
            const _ChartSkeleton(height: 320),
            const SizedBox(height: 20),
            const _ChartSkeleton(height: 320),
          ],
          const SizedBox(height: 20),
          const _ChartSkeleton(height: 340),
        ],
      ),
    );
  }
}

class _MicroStatSkeleton extends StatelessWidget {
  final double width;
  const _MicroStatSkeleton({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SkeletonBox(width: 100, height: 11),
          SizedBox(height: 16),
          _SkeletonBox(width: 130, height: 22, radius: 6),
          SizedBox(height: 6),
          _SkeletonBox(width: 70, height: 11),
        ],
      ),
    );
  }
}

class _SmartActionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const _SkeletonBox(width: 42, height: 42, radius: 11),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SkeletonBox(width: 220, height: 14),
                SizedBox(height: 6),
                _SkeletonBox(width: 280, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _SkeletonBox(width: 90, height: 32, radius: 8),
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              _SkeletonBox(width: 16, height: 16),
              SizedBox(width: 8),
              _SkeletonBox(width: 160, height: 16),
            ],
          ),
          const SizedBox(height: 20),
          const Expanded(
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
