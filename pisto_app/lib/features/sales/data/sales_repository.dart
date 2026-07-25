import '../../../config/api_client.dart';
import '../../../core/models/paginated.dart';
import '../models/credit_note.dart';
import '../models/customer.dart';
import '../models/customer_statement.dart';
import '../models/invoice.dart';
import '../models/lookups.dart';

/// Typed access to `/sales` (+ inventory catalogs and account statement that
/// the sales flow needs). Dio errors propagate; the shared UI layer parses
/// them (AsyncErrorState / AppToast.guard).
class SalesRepository {
  final ApiClient _api;
  SalesRepository(this._api);

  // ── Customers ──────────────────────────────────────────────────────────────

  Future<Paginated<Customer>> listCustomers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final res = await _api.dio.get('/sales/customers', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, Customer.fromJson);
  }

  Future<Customer> getCustomer(String id) async {
    final res = await _api.dio.get('/sales/customers/$id');
    return Customer.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Customer> createCustomer({
    required String customerType,
    String? firstName,
    String? lastName,
    String? companyName,
    String? taxId,
    String? email,
    String? phone,
    String? address,
  }) async {
    final res = await _api.dio.post('/sales/customers', data: {
      'customerType': customerType,
      'firstName': ?firstName,
      'lastName': ?lastName,
      'companyName': ?companyName,
      'taxId': ?taxId,
      'email': ?email,
      'phone': ?phone,
      'address': ?address,
    });
    return Customer.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> updateCustomer(
    String id, {
    String? firstName,
    String? lastName,
    String? companyName,
    String? email,
    String? phone,
    String? address,
    String? taxId,
  }) async {
    await _api.dio.put('/sales/customers/$id', data: {
      'firstName': ?firstName,
      'lastName': ?lastName,
      'companyName': ?companyName,
      'email': ?email,
      'phone': ?phone,
      'address': ?address,
      'taxId': ?taxId,
    });
  }

  Future<CustomerStatement> getCustomerStatement(String customerId) async {
    final res =
        await _api.dio.get('/collections/customers/$customerId/statement');
    return CustomerStatement.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Invoices ───────────────────────────────────────────────────────────────

  Future<Paginated<Invoice>> listInvoices({
    int page = 1,
    int limit = 20,
    String? customerId,
  }) async {
    final res = await _api.dio.get('/sales/invoices', queryParameters: {
      'page': page,
      'limit': limit,
      'customerId': ?customerId,
    });
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, Invoice.fromJson);
  }

  Future<Invoice> getInvoice(String id) async {
    final res = await _api.dio.get('/sales/invoices/$id');
    return Invoice.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Invoice> createSale({
    String? customerId,
    required String documentTypeId,
    required String warehouseId,
    required String paymentStatus,
    String? paymentMethodId,
    required List<SaleLineInput> lines,
  }) async {
    final total = lines.fold<double>(0, (sum, l) => sum + l.total);
    final res = await _api.dio.post('/sales/invoices', data: {
      'customerId': ?customerId,
      'documentTypeId': documentTypeId,
      'warehouseId': warehouseId,
      'paymentStatus': paymentStatus,
      'lines': [for (final l in lines) l.toJson()],
      if (paymentStatus == 'paid' && paymentMethodId != null)
        'payments': [
          {
            'paymentMethodId': paymentMethodId,
            'amount': total.toStringAsFixed(2),
          },
        ],
    });
    return Invoice.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> cancelSale(String id) async {
    await _api.dio.post('/sales/invoices/$id/cancel');
  }

  // ── Credit notes ───────────────────────────────────────────────────────────

  Future<Paginated<CreditNote>> listCreditNotes({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.dio.get('/sales/credit-notes',
        queryParameters: {'page': page, 'limit': limit});
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, CreditNote.fromJson);
  }

  Future<CreditNote> createCreditNote(
    String saleId, {
    required String reason,
    required List<InvoiceItem> lines,
  }) async {
    final res =
        await _api.dio.post('/sales/invoices/$saleId/credit-note', data: {
      'reason': reason,
      'lines': [
        for (final l in lines)
          {
            'productId': l.productId,
            'quantity': l.quantity,
            'unitPrice': l.unitPrice,
          },
      ],
    });
    return CreditNote.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Lookups ────────────────────────────────────────────────────────────────

  Future<List<PaymentMethod>> listPaymentMethods() async {
    final res = await _api.dio.get('/sales/payment-methods');
    return [
      for (final e in res.data['data'] as List)
        PaymentMethod.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<DocumentType>> listDocumentTypes() async {
    final res = await _api.dio.get('/sales/document-types');
    return [
      for (final e in res.data['data'] as List)
        DocumentType.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<Tax>> listTaxes() async {
    final res = await _api.dio.get('/sales/taxes');
    return [
      for (final e in res.data['data'] as List)
        Tax.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<ProductRef>> listSaleProducts() async {
    final res = await _api.dio
        .get('/inventory/products', queryParameters: {'page': 1, 'limit': 100});
    return [
      for (final e in res.data['data'] as List)
        ProductRef.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<WarehouseRef>> listWarehouses() async {
    final res = await _api.dio.get('/inventory/warehouses');
    return [
      for (final e in res.data['data'] as List)
        WarehouseRef.fromJson(e as Map<String, dynamic>),
    ];
  }
}
