import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/page_header.dart';

class AiForecastScreen extends ConsumerStatefulWidget {
  const AiForecastScreen({super.key});

  @override
  ConsumerState<AiForecastScreen> createState() => _AiForecastScreenState();
}

class _AiForecastScreenState extends ConsumerState<AiForecastScreen> {
  ForecastResult? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.getForecast();
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = ApiClient.parseError(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < Breakpoints.compact;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 32,
          vertical: isCompact ? 16 : 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              eyebrow: 'ASISTENTE IA',
              title: 'Pronóstico Financiero',
              meta: 'Proyección basada en datos históricos',
            ),
            const SizedBox(height: 28),
            if (_loading) _buildSkeleton(cs),
            if (_error != null) _buildError(cs),
            if (!_loading && _error == null && _data != null) _buildContent(cs, isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(ColorScheme cs) {
    return Column(
      children: List.generate(4, (i) {
        final heights = [60.0, 100.0, 200.0, 120.0];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            height: heights[i],
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildError(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, AppTheme.danger),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.circleAlert, size: 32, color: AppTheme.danger),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurface, fontSize: 14),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _loadForecast,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme cs, bool isCompact) {
    final data = _data!;
    final fmt = currencyFmt;

    final riskLevel = data.risk;
    final projectedIncome = data.summary.totalProjectedIncome;
    final projectedExpenses = data.summary.totalProjectedExpenses;
    final projectedNet = data.summary.netProjection;
    final insights = data.insights;
    final cashFlowData = data.forecast;

    // Risk color + label
    final (riskColor, riskLabel) = switch (riskLevel) {
      'low' => (AppTheme.success, 'Bajo'),
      'high' => (AppTheme.danger, 'Alto'),
      _ => (AppTheme.warning, 'Medio'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Risk indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.tintBg(context, riskColor),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: riskColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.shieldAlert, size: 20, color: riskColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel de riesgo',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Riesgo $riskLabel',
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  riskLabel.toUpperCase(),
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Summary stats
        _buildStatsRow(cs, fmt, isCompact, projectedIncome, projectedExpenses, projectedNet),
        const SizedBox(height: 20),

        // Cash flow chart
        if (cashFlowData.isNotEmpty) ...[
          Text('FLUJO DE CAJA PROYECTADO', style: AppTheme.eyebrow(context)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 220,
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderSubtle(context)),
            ),
            child: _buildChart(cs, cashFlowData),
          ),
          const SizedBox(height: 20),
        ],

        // Insights
        if (insights.isNotEmpty) ...[
          Text('ANÁLISIS', style: AppTheme.eyebrow(context)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderSubtle(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: insights.map((insight) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(LucideIcons.sparkles, size: 14, color: cs.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          insight,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatsRow(
    ColorScheme cs,
    dynamic fmt,
    bool isCompact,
    double income,
    double expenses,
    double net,
  ) {
    final cards = [
      _StatData('Ingresos', fmt.format(income), LucideIcons.trendingUp, AppTheme.success),
      _StatData('Gastos', fmt.format(expenses), LucideIcons.trendingDown, AppTheme.danger),
      _StatData('Neto', fmt.format(net), LucideIcons.equal, net >= 0 ? AppTheme.success : AppTheme.danger),
    ];

    if (isCompact) {
      return Column(
        children: cards.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _StatCard(data: c),
        )).toList(),
      );
    }

    return Row(
      children: cards.map((c) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _StatCard(data: c),
        ),
      )).toList(),
    );
  }

  Widget _buildChart(ColorScheme cs, List<ForecastDay> cashFlowData) {
    final spots = <FlSpot>[];
    for (var i = 0; i < cashFlowData.length; i++) {
      spots.add(FlSpot(i.toDouble(), cashFlowData[i].netCashFlow));
    }

    if (spots.isEmpty) {
      return Center(
        child: Text(
          'Sin datos de flujo',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calcInterval(spots),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.borderSubtle(context),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= cashFlowData.length) return const SizedBox.shrink();
                final label = formatDateShortEs(cashFlowData[idx].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.isEmpty ? '${idx + 1}' : label,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (value, meta) => Text(
                _formatCompact(value),
                style: AppTheme.mono(fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: cs.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: cs.primary,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: cs.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => cs.surfaceContainer,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                currencyFmt.format(spot.y),
                AppTheme.mono(fontSize: 12, color: cs.onSurface),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  double _calcInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final values = spots.map((s) => s.y);
    final range = values.reduce((a, b) => a > b ? a : b) - values.reduce((a, b) => a < b ? a : b);
    if (range <= 0) return 1;
    return (range / 4).ceilToDouble();
  }

  String _formatCompact(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

}

// ── Supporting widgets ──────────────────────────────────────────────────────

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 14, color: data.color),
              const SizedBox(width: 6),
              Text(
                data.label,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: AppTheme.mono(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
