import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';
import '../services/inventory_service.dart';
import '../services/sales_service.dart';
import '../services/collections_service.dart';
import '../services/purchases_service.dart';
import '../services/reports_service.dart';
import '../services/exports_service.dart';
import '../services/settings_service.dart';
import '../services/expenses_service.dart';

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService(ref.watch(apiClientProvider));
});

final salesServiceProvider = Provider<SalesService>((ref) {
  return SalesService(ref.watch(apiClientProvider));
});

final collectionsServiceProvider = Provider<CollectionsService>((ref) {
  return CollectionsService(ref.watch(apiClientProvider));
});

final purchasesServiceProvider = Provider<PurchasesService>((ref) {
  return PurchasesService(ref.watch(apiClientProvider));
});

final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService(ref.watch(apiClientProvider));
});

final exportsServiceProvider = Provider<ExportsService>((ref) {
  return ExportsService(ref.watch(apiClientProvider));
});

final expensesServiceProvider = Provider<ExpensesService>((ref) {
  return ExpensesService(ref.watch(apiClientProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(apiClientProvider));
});
