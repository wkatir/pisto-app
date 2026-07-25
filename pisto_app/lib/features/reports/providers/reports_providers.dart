import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/service_providers.dart';

part 'reports_providers.g.dart';

/// Everything the reports screen needs, fetched in parallel.
@riverpod
Future<
    ({
      Map<String, dynamic> salesSummary,
      List<dynamic> topProducts,
      dynamic grossProfit,
      List<dynamic> inventoryValuation,
    })> reportsOverview(Ref ref) async {
  final svc = ref.watch(reportsServiceProvider);
  final results = await Future.wait([
    svc.getSalesSummary(),
    svc.getTopProducts(limit: 5),
    svc.getGrossProfit(),
    svc.getInventoryValuation(),
  ]);
  return (
    salesSummary: results[0] as Map<String, dynamic>,
    topProducts: results[1] as List<dynamic>,
    grossProfit: results[2],
    inventoryValuation: results[3] as List<dynamic>,
  );
}
