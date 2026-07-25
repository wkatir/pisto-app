import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/paginated.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/formatters.dart';
import '../data/sales_repository.dart';
import '../models/credit_note.dart';
import '../models/customer.dart';
import '../models/customer_statement.dart';
import '../models/invoice.dart';
import '../models/lookups.dart';

part 'sales_providers.g.dart';

@Riverpod(keepAlive: true)
SalesRepository salesRepository(Ref ref) {
  return SalesRepository(ref.watch(apiClientProvider));
}

// ── Queries ──────────────────────────────────────────────────────────────────

@riverpod
Future<Paginated<Customer>> customersList(
  Ref ref, {
  int page = 1,
  String search = '',
}) {
  return ref.watch(salesRepositoryProvider).listCustomers(
        page: page,
        search: search.isEmpty ? null : search,
      );
}

@riverpod
Future<Paginated<Invoice>> invoicesList(
  Ref ref, {
  int page = 1,
  String? customerId,
}) {
  return ref
      .watch(salesRepositoryProvider)
      .listInvoices(page: page, customerId: customerId);
}

/// Subtitle for the "Tus ventas" header. The billed amount is computed over
/// the visible page of the historical list, so the scope is labeled —
/// without the label it reads as a monthly figure and contradicts the dashboard.
String salesHeaderMeta(Paginated<Invoice> invoices) {
  final total = invoices.meta.total;
  final pageRevenue =
      invoices.data.fold<double>(0, (sum, inv) => sum + inv.totalValue);
  final credit = invoices.data.where((inv) => inv.isCredit).length;
  final scope = total > invoices.data.length
      ? 'en las ${invoices.data.length} más recientes'
      : 'en total';
  return '$total factura${total == 1 ? '' : 's'} · '
      '${currencyFmt.format(pageRevenue)} facturado $scope'
      '${credit > 0 ? ' · $credit a crédito' : ''}';
}

@riverpod
Future<Invoice> invoiceDetail(Ref ref, String id) {
  return ref.watch(salesRepositoryProvider).getInvoice(id);
}

@riverpod
Future<Paginated<CreditNote>> creditNotesList(Ref ref, {int page = 1}) {
  return ref.watch(salesRepositoryProvider).listCreditNotes(page: page);
}

@riverpod
Future<CustomerStatement> customerStatement(Ref ref, String customerId) {
  return ref.watch(salesRepositoryProvider).getCustomerStatement(customerId);
}

/// Product catalog for the sales flow — shared by the new-sale form and the
/// invoice detail (to resolve names by productId).
@riverpod
Future<List<ProductRef>> saleProducts(Ref ref) {
  return ref.watch(salesRepositoryProvider).listSaleProducts();
}

/// Invoice detail + resolved product names, in parallel.
/// API lines only carry productId; the name comes from the catalog.
@riverpod
Future<({Invoice invoice, Map<String, String> productNames})>
    invoiceDetailWithNames(Ref ref, String id) async {
  final (invoice, products) = await (
    ref.watch(invoiceDetailProvider(id).future),
    ref.watch(saleProductsProvider.future),
  ).wait;
  return (
    invoice: invoice,
    productNames: {for (final p in products) p.id: p.name},
  );
}

/// Everything the customer detail screen needs, in parallel.
@riverpod
Future<
    ({
      Customer customer,
      CustomerStatement statement,
      Paginated<Invoice> invoices,
    })> customerOverview(Ref ref, String customerId) async {
  final repo = ref.watch(salesRepositoryProvider);
  final (customer, statement, invoices) = await (
    repo.getCustomer(customerId),
    repo.getCustomerStatement(customerId),
    repo.listInvoices(customerId: customerId),
  ).wait;
  return (customer: customer, statement: statement, invoices: invoices);
}

/// Catalogs needed by the new-sale form, in parallel.
class SaleFormData {
  final List<ProductRef> products;
  final List<WarehouseRef> warehouses;
  final List<Customer> customers;
  final List<PaymentMethod> paymentMethods;
  final List<DocumentType> documentTypes;
  final List<Tax> taxes;

  const SaleFormData({
    required this.products,
    required this.warehouses,
    required this.customers,
    required this.paymentMethods,
    required this.documentTypes,
    required this.taxes,
  });
}

@riverpod
Future<SaleFormData> saleFormData(Ref ref) async {
  final repo = ref.watch(salesRepositoryProvider);
  final (products, warehouses, customers, paymentMethods, documentTypes, taxes) =
      await (
    ref.watch(saleProductsProvider.future),
    repo.listWarehouses(),
    repo.listCustomers(limit: 100),
    repo.listPaymentMethods(),
    repo.listDocumentTypes(),
    repo.listTaxes(),
  ).wait;
  return SaleFormData(
    products: products,
    warehouses: warehouses,
    customers: customers.data,
    paymentMethods: paymentMethods,
    documentTypes: documentTypes,
    taxes: taxes,
  );
}

// ── Mutations ────────────────────────────────────────────────────────────────
// Each mutation invalidates only the queries it changed.

@riverpod
class CustomerMutations extends _$CustomerMutations {
  @override
  void build() {}

  Future<Customer> create({
    required String customerType,
    String? firstName,
    String? lastName,
    String? companyName,
    String? taxId,
    String? email,
    String? phone,
    String? address,
  }) async {
    final customer = await ref.read(salesRepositoryProvider).createCustomer(
          customerType: customerType,
          firstName: firstName,
          lastName: lastName,
          companyName: companyName,
          taxId: taxId,
          email: email,
          phone: phone,
          address: address,
        );
    ref.invalidate(customersListProvider);
    ref.invalidate(saleFormDataProvider);
    return customer;
  }

  Future<void> update(
    String id, {
    String? firstName,
    String? lastName,
    String? companyName,
    String? email,
    String? phone,
  }) async {
    await ref.read(salesRepositoryProvider).updateCustomer(
          id,
          firstName: firstName,
          lastName: lastName,
          companyName: companyName,
          email: email,
          phone: phone,
        );
    ref.invalidate(customersListProvider);
    ref.invalidate(customerOverviewProvider);
    ref.invalidate(saleFormDataProvider);
  }
}

@riverpod
class SaleMutations extends _$SaleMutations {
  @override
  void build() {}

  Future<Invoice> create({
    String? customerId,
    required String documentTypeId,
    required String warehouseId,
    required String paymentStatus,
    String? paymentMethodId,
    required List<SaleLineInput> lines,
  }) async {
    final invoice = await ref.read(salesRepositoryProvider).createSale(
          customerId: customerId,
          documentTypeId: documentTypeId,
          warehouseId: warehouseId,
          paymentStatus: paymentStatus,
          paymentMethodId: paymentMethodId,
          lines: lines,
        );
    ref.invalidate(invoicesListProvider);
    ref.invalidate(customerStatementProvider);
    ref.invalidate(customerOverviewProvider);
    return invoice;
  }

  Future<void> cancel(String id) async {
    await ref.read(salesRepositoryProvider).cancelSale(id);
    ref.invalidate(invoicesListProvider);
    ref.invalidate(invoiceDetailProvider);
    ref.invalidate(customerOverviewProvider);
  }

  Future<CreditNote> createCreditNote(
    String saleId, {
    required String reason,
    required List<InvoiceItem> lines,
  }) async {
    final note = await ref
        .read(salesRepositoryProvider)
        .createCreditNote(saleId, reason: reason, lines: lines);
    ref.invalidate(creditNotesListProvider);
    ref.invalidate(invoicesListProvider);
    ref.invalidate(customerStatementProvider);
    ref.invalidate(customerOverviewProvider);
    return note;
  }
}
