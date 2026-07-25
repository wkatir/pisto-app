import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/service_providers.dart';

part 'settings_providers.g.dart';

/// Everything the settings screen needs, fetched in parallel.
@riverpod
Future<
    ({
      Map<String, dynamic>? business,
      List<Map<String, dynamic>> taxes,
      List<Map<String, dynamic>> paymentMethods,
    })> settingsOverview(Ref ref) async {
  final svc = ref.watch(settingsServiceProvider);
  final (business, taxes, paymentMethods) = await (
    svc.getBusiness(),
    svc.listTaxes(),
    svc.listPaymentMethods(),
  ).wait;
  return (business: business, taxes: taxes, paymentMethods: paymentMethods);
}

// ── Mutations ────────────────────────────────────────────────────────────────
// Each mutation invalidates the overview to refresh the screen.

@riverpod
class SettingsMutations extends _$SettingsMutations {
  @override
  void build() {}

  Future<void> updateBusiness(Map<String, dynamic> data) async {
    await ref.read(settingsServiceProvider).updateBusiness(data);
    ref.invalidate(settingsOverviewProvider);
  }

  Future<void> toggleTax(String id, bool isActive) async {
    await ref.read(settingsServiceProvider).toggleTax(id, isActive);
    ref.invalidate(settingsOverviewProvider);
  }

  Future<void> createTax(String name, String rate) async {
    await ref.read(settingsServiceProvider).createTax(name, rate);
    ref.invalidate(settingsOverviewProvider);
  }

  Future<void> togglePaymentMethod(String id, bool isActive) async {
    await ref.read(settingsServiceProvider).togglePaymentMethod(id, isActive);
    ref.invalidate(settingsOverviewProvider);
  }

  Future<void> createPaymentMethod(String name) async {
    await ref.read(settingsServiceProvider).createPaymentMethod(name);
    ref.invalidate(settingsOverviewProvider);
  }
}
