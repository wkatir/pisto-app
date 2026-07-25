import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/service_providers.dart';

part 'dashboard_providers.g.dart';

/// Dashboard date range — local UI state in the screen,
/// passed as a param to the provider (not async state).
enum DashboardPeriod { week, month, quarter, year }

(DateTime, DateTime) dashboardPeriodDates(DashboardPeriod period) {
  final now = DateTime.now();
  return switch (period) {
    DashboardPeriod.week => (now.subtract(const Duration(days: 7)), now),
    DashboardPeriod.month => (DateTime(now.year, now.month, 1), now),
    DashboardPeriod.quarter =>
      (DateTime(now.year, (now.month - 1) ~/ 3 * 3 + 1, 1), now),
    DashboardPeriod.year => (DateTime(now.year, 1, 1), now),
  };
}

// ── Queries ──────────────────────────────────────────────────────────────────

/// Everything the dashboard needs for a given period, fetched in parallel.
@riverpod
Future<
    ({
      Map<String, dynamic> kpis,
      List<dynamic> salesTrend,
      List<dynamic> topProducts,
      List<dynamic> salesByCategory,
    })> dashboardData(Ref ref, DashboardPeriod period) async {
  final svc = ref.watch(reportsServiceProvider);
  final (start, end) = dashboardPeriodDates(period);
  final (kpis, salesTrend, topProducts, salesByCategory) = await (
    svc.getDashboardKPIs(startDate: start, endDate: end),
    svc.getSalesTrend(days: 30, startDate: start, endDate: end),
    svc.getTopProducts(limit: 5, startDate: start, endDate: end),
    svc.getSalesByCategory(),
  ).wait;

  return (
    kpis: kpis,
    salesTrend: salesTrend,
    topProducts: topProducts,
    salesByCategory: salesByCategory,
  );
}
