import '../../../config/api_client.dart';
import '../../../core/models/paginated.dart';
import '../../sales/models/lookups.dart';
import '../models/goods_receipt.dart';
import '../models/payable.dart';
import '../models/purchase_order.dart';
import '../models/supplier.dart';

/// Typed access to `/purchases` (+ inventory catalogs and payment methods
/// that the purchase flow needs). Dio errors propagate; the shared UI layer
/// parses them (AsyncErrorState / AppToast.guard).
class PurchasesRepository {
  final ApiClient _api;
  PurchasesRepository(this._api);

  // ── Suppliers ──────────────────────────────────────────────────────────────

  Future<List<Supplier>> listSuppliers() async {
    final res = await _api.dio.get('/purchases/suppliers');
    return [
      for (final e in res.data as List)
        Supplier.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<Supplier> createSupplier({
    required String companyName,
    String? contactName,
    String? taxId,
    String? phone,
    String? email,
    String? address,
  }) async {
    final res = await _api.dio.post('/purchases/suppliers', data: {
      'companyName': companyName,
      'contactName': ?contactName,
      'taxId': ?taxId,
      'phone': ?phone,
      'email': ?email,
      'address': ?address,
    });
    return Supplier.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> updateSupplier(
    String id, {
    String? companyName,
    String? contactName,
    String? taxId,
    String? phone,
    String? email,
    String? address,
  }) async {
    await _api.dio.put('/purchases/suppliers/$id', data: {
      'companyName': ?companyName,
      'contactName': ?contactName,
      'taxId': ?taxId,
      'phone': ?phone,
      'email': ?email,
      'address': ?address,
    });
  }

  // ── Purchase orders ────────────────────────────────────────────────────────

  Future<Paginated<PurchaseOrder>> listOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.dio.get('/purchases/orders',
        queryParameters: {'page': page, 'limit': limit});
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, PurchaseOrder.fromJson);
  }

  Future<PurchaseOrder> getOrder(String id) async {
    final res = await _api.dio.get('/purchases/orders/$id');
    return PurchaseOrder.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PurchaseOrder> createOrder({
    required String supplierId,
    String? warehouseId,
    String? expectedDate,
    String? notes,
    required List<PurchaseLineInput> lines,
  }) async {
    final res = await _api.dio.post('/purchases/orders', data: {
      'supplierId': supplierId,
      'warehouseId': ?warehouseId,
      'expectedDate': ?expectedDate,
      'notes': ?notes,
      'lines': [for (final l in lines) l.toJson()],
    });
    return PurchaseOrder.fromJson(res.data as Map<String, dynamic>);
  }

  Future<GoodsReceipt> receiveGoods(
    String orderId, {
    String? notes,
    required List<ReceiptLineInput> lines,
  }) async {
    final res = await _api.dio.post('/purchases/orders/$orderId/receive', data: {
      'notes': ?notes,
      'lines': [for (final l in lines) l.toJson()],
    });
    return GoodsReceipt.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Payables ───────────────────────────────────────────────────────────────

  Future<Paginated<PayableRow>> listPayables({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.dio.get('/purchases/payables',
        queryParameters: {'page': page, 'limit': limit});
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, PayableRow.fromJson);
  }

  Future<void> createSupplierPayment(
    String payableId, {
    required String paymentMethodId,
    required String amount,
    String? reference,
  }) async {
    await _api.dio.post('/purchases/payables/$payableId/payments', data: {
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'reference': ?reference,
    });
  }

  // ── Lookups ────────────────────────────────────────────────────────────────

  Future<List<WarehouseRef>> listWarehouses() async {
    final res = await _api.dio.get('/inventory/warehouses');
    return [
      for (final e in res.data['data'] as List)
        WarehouseRef.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<ProductRef>> listPurchaseProducts() async {
    final res = await _api.dio
        .get('/inventory/products', queryParameters: {'page': 1, 'limit': 100});
    return [
      for (final e in res.data['data'] as List)
        ProductRef.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<PaymentMethod>> listPaymentMethods() async {
    final res = await _api.dio.get('/sales/payment-methods');
    return [
      for (final e in res.data['data'] as List)
        PaymentMethod.fromJson(e as Map<String, dynamic>),
    ];
  }
}
