import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/app_theme.dart';
import '../../../config/chart_spec.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/ai_provider.dart';

class AiForecastScreen extends ConsumerWidget {
  const AiForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < Breakpoints.compact;
    final forecastAsync = ref.watch(forecastResultProvider);

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
            const PageHeader(title: 'Pronóstico financiero'),
            const SizedBox(height: 4),
            Text(
              'Proyección basada en datos históricos.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 24),
            AsyncValueWidget<ForecastResult>(
              value: forecastAsync,
              loading: _buildSkeleton(cs),
              onRetry: () => ref.invalidate(forecastResultProvider),
              data: (data) => _buildContent(context, cs, isCompact, data),
            ),
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

  Widget _buildContent(
    BuildContext context,
    ColorScheme cs,
    bool isCompact,
    ForecastResult data,
  ) {
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
        // The ONE sanctioned alert card on this screen — 3px accent edge
        // carries the risk state, not a tinted fill.
        InfoCard(
          accentColor: riskColor,
          child: Row(
            children: [
              IconBadge(icon: LucideIcons.shieldAlert, color: riskColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nivel de riesgo', style: AppTheme.quietLabel(context)),
                    const SizedBox(height: 2),
                    Text(
                      'Riesgo $riskLabel',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IntentChip(
                label: riskLabel.toUpperCase(),
                intent: switch (riskLevel) {
                  'low' => ChipIntent.success,
                  'high' => ChipIntent.danger,
                  _ => ChipIntent.warning,
                },
              ),
            ],
          ),
        ),

        // Projected figures — the hero numbers, flat, no card.
        SectionHeading(title: 'Proyección a 30 días'),
        _buildStatsRow(context, fmt, isCompact, projectedIncome, projectedExpenses, projectedNet),

        // Cash flow — the one framed chart on this screen.
        if (cashFlowData.isNotEmpty) ...[
          SectionHeading(title: 'Flujo de caja proyectado'),
          InfoCard(
            child: SizedBox(
              height: 220,
              child: _buildChart(context, cs, cashFlowData),
            ),
          ),
        ],

        // Insights — flat list, no card.
        if (insights.isNotEmpty) ...[
          SectionHeading(title: 'Análisis'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: insights.asMap().entries.map((entry) {
              final isLast = entry.key == insights.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
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
                        entry.value,
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
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    dynamic fmt,
    bool isCompact,
    double income,
    double expenses,
    double net,
  ) {
    final figures = [
      BigFigure(
        label: 'Ingresos',
        value: fmt.format(income),
        size: BigFigureSize.s,
        valueColor: context.tokens.successText,
      ),
      BigFigure(
        label: 'Gastos',
        value: fmt.format(expenses),
        size: BigFigureSize.s,
        valueColor: context.tokens.dangerText,
      ),
      BigFigure(
        label: 'Neto',
        value: fmt.format(net),
        size: BigFigureSize.s,
        valueColor: net >= 0 ? context.tokens.successText : context.tokens.dangerText,
      ),
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: figures
            .map((f) => Padding(padding: const EdgeInsets.only(bottom: 20), child: f))
            .toList(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: figures
            .map((f) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 24), child: f)))
            .toList(),
      ),
    );
  }

  Widget _buildChart(BuildContext context, ColorScheme cs, List<ForecastDay> cashFlowData) {
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
        gridData: ChartSpec.grid(context, interval: _calcInterval(spots)),
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
                    style: ChartSpec.axisLabel(context, mono: false),
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
                style: ChartSpec.axisLabel(context),
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
            getTooltipColor: (_) => cs.surfaceContainerHigh,
            tooltipBorder: BorderSide(color: cs.outlineVariant),
            tooltipBorderRadius: BorderRadius.circular(10),
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              return LineTooltipItem(
                currencyFmt.format(spot.y),
                ChartSpec.tooltipValueStyle(context),
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
