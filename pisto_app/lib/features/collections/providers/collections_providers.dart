import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/paginated.dart';
import '../../../core/providers/core_providers.dart';
import '../../sales/models/lookups.dart';
import '../../sales/providers/sales_providers.dart';
import '../data/collections_repository.dart';
import '../models/aging_bucket.dart';
import '../models/receivable.dart';
import '../models/receivable_payment.dart';

part 'collections_providers.g.dart';

@Riverpod(keepAlive: true)
CollectionsRepository collectionsRepository(Ref ref) {
  return CollectionsRepository(ref.watch(apiClientProvider));
}

// ── Queries ──────────────────────────────────────────────────────────────────

@riverpod
Future<Paginated<ReceivableListItem>> receivablesList(Ref ref, {int page = 1}) {
  return ref.watch(collectionsRepositoryProvider).listReceivables(page: page);
}

@riverpod
Future<List<AgingBucket>> agingReport(Ref ref) {
  return ref.watch(collectionsRepositoryProvider).getAgingReport();
}

@riverpod
Future<List<ReceivablePayment>> receivablePayments(
    Ref ref, String receivableId) {
  return ref
      .watch(collectionsRepositoryProvider)
      .getReceivablePayments(receivableId);
}

@riverpod
Future<List<PaymentMethod>> collectionsPaymentMethods(Ref ref) {
  return ref.watch(collectionsRepositoryProvider).listPaymentMethods();
}

// ── Mutations ────────────────────────────────────────────────────────────────
// Each mutation invalidates only the queries it changed.

@riverpod
class CollectionsMutations extends _$CollectionsMutations {
  @override
  void build() {}

  Future<ReceivablePayment> createPayment(
    String receivableId, {
    required String paymentMethodId,
    required String amount,
    String? reference,
    String? notes,
  }) async {
    final payment =
        await ref.read(collectionsRepositoryProvider).createPayment(
              receivableId,
              paymentMethodId: paymentMethodId,
              amount: amount,
              reference: reference,
              notes: notes,
            );
    ref.invalidate(receivablesListProvider);
    ref.invalidate(agingReportProvider);
    ref.invalidate(receivablePaymentsProvider(receivableId));
    // El abono cambia el saldo del cliente en la feature de ventas.
    ref.invalidate(customerStatementProvider);
    ref.invalidate(customerOverviewProvider);
    return payment;
  }
}
