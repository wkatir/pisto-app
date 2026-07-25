import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/paginated.dart';
import '../../../core/providers/core_providers.dart';
import '../../sales/models/lookups.dart';
import '../data/purchases_repository.dart';
import '../models/goods_receipt.dart';
import '../models/payable.dart';
import '../models/purchase_order.dart';
import '../models/supplier.dart';

part 'purchases_providers.g.dart';

@Riverpod(keepAlive: true)
PurchasesRepository purchasesRepository(Ref ref) {
  return PurchasesRepository(ref.watch(apiClientProvider));
}

// ── Queries ──────────────────────────────────────────────────────────────────

@riverpod
Future<List<Supplier>> suppliersList(Ref ref) {
  return ref.watch(purchasesRepositoryProvider).listSuppliers();
}

@riverpod
Future<Paginated<PurchaseOrder>> purchaseOrdersList(Ref ref, {int page = 1}) {
  return ref.watch(purchasesRepositoryProvider).listOrders(page: page);
}

@riverpod
Future<PurchaseOrder> purchaseOrderDetail(Ref ref, String id) {
  return ref.watch(purchasesRepositoryProvider).getOrder(id);
}

@riverpod
Future<Paginated<PayableRow>> payablesList(Ref ref, {int page = 1}) {
  return ref.watch(purchasesRepositoryProvider).listPayables(page: page);
}

/// Catalogs needed by the purchase forms, in parallel.
class PurchaseFormData {
  final List<Supplier> suppliers;
  final List<WarehouseRef> warehouses;
  final List<ProductRef> products;
  final List<PaymentMethod> paymentMethods;

  const PurchaseFormData({
    required this.suppliers,
    required this.warehouses,
    required this.products,
    required this.paymentMethods,
  });
}

@riverpod
Future<PurchaseFormData> purchaseFormData(Ref ref) async {
  final repo = ref.watch(purchasesRepositoryProvider);
  final (suppliers, warehouses, products, paymentMethods) = await (
    repo.listSuppliers(),
    repo.listWarehouses(),
    repo.listPurchaseProducts(),
    repo.listPaymentMethods(),
  ).wait;
  return PurchaseFormData(
    suppliers: suppliers,
    warehouses: warehouses,
    products: products,
    paymentMethods: paymentMethods,
  );
}

// ── Mutations ────────────────────────────────────────────────────────────────
// Each mutation invalidates only the queries it changed.

@riverpod
class PurchasesMutations extends _$PurchasesMutations {
  @override
  void build() {}

  Future<Supplier> createSupplier({
    required String companyName,
    String? contactName,
    String? taxId,
    String? phone,
    String? email,
    String? address,
  }) async {
    final supplier =
        await ref.read(purchasesRepositoryProvider).createSupplier(
              companyName: companyName,
              contactName: contactName,
              taxId: taxId,
              phone: phone,
              email: email,
              address: address,
            );
    ref.invalidate(suppliersListProvider);
    ref.invalidate(purchaseFormDataProvider);
    return supplier;
  }

  Future<void> updateSupplier(
    String id, {
    String? companyName,
    String? contactName,
    String? email,
    String? phone,
  }) async {
    await ref.read(purchasesRepositoryProvider).updateSupplier(
          id,
          companyName: companyName,
          contactName: contactName,
          email: email,
          phone: phone,
        );
    ref.invalidate(suppliersListProvider);
    ref.invalidate(purchaseFormDataProvider);
  }

  Future<PurchaseOrder> createOrder({
    required String supplierId,
    String? warehouseId,
    String? notes,
    required List<PurchaseLineInput> lines,
  }) async {
    final order = await ref.read(purchasesRepositoryProvider).createOrder(
          supplierId: supplierId,
          warehouseId: warehouseId,
          notes: notes,
          lines: lines,
        );
    ref.invalidate(purchaseOrdersListProvider);
    return order;
  }

  Future<GoodsReceipt> receiveGoods(
    String orderId, {
    String? notes,
    required List<ReceiptLineInput> lines,
  }) async {
    final receipt = await ref
        .read(purchasesRepositoryProvider)
        .receiveGoods(orderId, notes: notes, lines: lines);
    ref.invalidate(purchaseOrdersListProvider);
    ref.invalidate(purchaseOrderDetailProvider);
    ref.invalidate(payablesListProvider);
    return receipt;
  }

  Future<void> createPayment(
    String payableId, {
    required String paymentMethodId,
    required String amount,
    String? reference,
  }) async {
    await ref.read(purchasesRepositoryProvider).createSupplierPayment(
          payableId,
          paymentMethodId: paymentMethodId,
          amount: amount,
          reference: reference,
        );
    ref.invalidate(payablesListProvider);
  }
}
