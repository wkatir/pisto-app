// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(salesRepository)
final salesRepositoryProvider = SalesRepositoryProvider._();

final class SalesRepositoryProvider
    extends
        $FunctionalProvider<SalesRepository, SalesRepository, SalesRepository>
    with $Provider<SalesRepository> {
  SalesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SalesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SalesRepository create(Ref ref) {
    return salesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SalesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SalesRepository>(value),
    );
  }
}

String _$salesRepositoryHash() => r'86245a46bda4168fb151388997d0118bbbecb67f';

@ProviderFor(customersList)
final customersListProvider = CustomersListFamily._();

final class CustomersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Paginated<Customer>>,
          Paginated<Customer>,
          FutureOr<Paginated<Customer>>
        >
    with
        $FutureModifier<Paginated<Customer>>,
        $FutureProvider<Paginated<Customer>> {
  CustomersListProvider._({
    required CustomersListFamily super.from,
    required ({int page, String search}) super.argument,
  }) : super(
         retry: null,
         name: r'customersListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customersListHash();

  @override
  String toString() {
    return r'customersListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Paginated<Customer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Paginated<Customer>> create(Ref ref) {
    final argument = this.argument as ({int page, String search});
    return customersList(ref, page: argument.page, search: argument.search);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomersListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customersListHash() => r'9f5750646bd4f8f7c3412e0d3f3fb6e2b46ef16c';

final class CustomersListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Paginated<Customer>>,
          ({int page, String search})
        > {
  CustomersListFamily._()
    : super(
        retry: null,
        name: r'customersListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomersListProvider call({int page = 1, String search = ''}) =>
      CustomersListProvider._(
        argument: (page: page, search: search),
        from: this,
      );

  @override
  String toString() => r'customersListProvider';
}

@ProviderFor(invoicesList)
final invoicesListProvider = InvoicesListFamily._();

final class InvoicesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Paginated<Invoice>>,
          Paginated<Invoice>,
          FutureOr<Paginated<Invoice>>
        >
    with
        $FutureModifier<Paginated<Invoice>>,
        $FutureProvider<Paginated<Invoice>> {
  InvoicesListProvider._({
    required InvoicesListFamily super.from,
    required ({int page, String? customerId}) super.argument,
  }) : super(
         retry: null,
         name: r'invoicesListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invoicesListHash();

  @override
  String toString() {
    return r'invoicesListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Paginated<Invoice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Paginated<Invoice>> create(Ref ref) {
    final argument = this.argument as ({int page, String? customerId});
    return invoicesList(
      ref,
      page: argument.page,
      customerId: argument.customerId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InvoicesListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invoicesListHash() => r'f511767bbf0839464942fc25ec074f48de1904ac';

final class InvoicesListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Paginated<Invoice>>,
          ({int page, String? customerId})
        > {
  InvoicesListFamily._()
    : super(
        retry: null,
        name: r'invoicesListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InvoicesListProvider call({int page = 1, String? customerId}) =>
      InvoicesListProvider._(
        argument: (page: page, customerId: customerId),
        from: this,
      );

  @override
  String toString() => r'invoicesListProvider';
}

@ProviderFor(invoiceDetail)
final invoiceDetailProvider = InvoiceDetailFamily._();

final class InvoiceDetailProvider
    extends $FunctionalProvider<AsyncValue<Invoice>, Invoice, FutureOr<Invoice>>
    with $FutureModifier<Invoice>, $FutureProvider<Invoice> {
  InvoiceDetailProvider._({
    required InvoiceDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'invoiceDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invoiceDetailHash();

  @override
  String toString() {
    return r'invoiceDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Invoice> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Invoice> create(Ref ref) {
    final argument = this.argument as String;
    return invoiceDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoiceDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invoiceDetailHash() => r'6aa849602956fa1bd5387ee55067ca798583a5e5';

final class InvoiceDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Invoice>, String> {
  InvoiceDetailFamily._()
    : super(
        retry: null,
        name: r'invoiceDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InvoiceDetailProvider call(String id) =>
      InvoiceDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'invoiceDetailProvider';
}

@ProviderFor(creditNotesList)
final creditNotesListProvider = CreditNotesListFamily._();

final class CreditNotesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Paginated<CreditNote>>,
          Paginated<CreditNote>,
          FutureOr<Paginated<CreditNote>>
        >
    with
        $FutureModifier<Paginated<CreditNote>>,
        $FutureProvider<Paginated<CreditNote>> {
  CreditNotesListProvider._({
    required CreditNotesListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'creditNotesListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creditNotesListHash();

  @override
  String toString() {
    return r'creditNotesListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Paginated<CreditNote>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Paginated<CreditNote>> create(Ref ref) {
    final argument = this.argument as int;
    return creditNotesList(ref, page: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreditNotesListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creditNotesListHash() => r'91188756c75f13b50126218543daa395e3296f60';

final class CreditNotesListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Paginated<CreditNote>>, int> {
  CreditNotesListFamily._()
    : super(
        retry: null,
        name: r'creditNotesListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreditNotesListProvider call({int page = 1}) =>
      CreditNotesListProvider._(argument: page, from: this);

  @override
  String toString() => r'creditNotesListProvider';
}

@ProviderFor(customerStatement)
final customerStatementProvider = CustomerStatementFamily._();

final class CustomerStatementProvider
    extends
        $FunctionalProvider<
          AsyncValue<CustomerStatement>,
          CustomerStatement,
          FutureOr<CustomerStatement>
        >
    with
        $FutureModifier<CustomerStatement>,
        $FutureProvider<CustomerStatement> {
  CustomerStatementProvider._({
    required CustomerStatementFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customerStatementProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerStatementHash();

  @override
  String toString() {
    return r'customerStatementProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CustomerStatement> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CustomerStatement> create(Ref ref) {
    final argument = this.argument as String;
    return customerStatement(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerStatementProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerStatementHash() => r'0689ffcf2c2a809a1a5b17ed2c93f869a5e7b49e';

final class CustomerStatementFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CustomerStatement>, String> {
  CustomerStatementFamily._()
    : super(
        retry: null,
        name: r'customerStatementProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerStatementProvider call(String customerId) =>
      CustomerStatementProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerStatementProvider';
}

/// Catálogo de productos del flujo de venta — lo comparten el formulario de
/// nueva venta y el detalle de factura (para resolver nombres por productId).

@ProviderFor(saleProducts)
final saleProductsProvider = SaleProductsProvider._();

/// Catálogo de productos del flujo de venta — lo comparten el formulario de
/// nueva venta y el detalle de factura (para resolver nombres por productId).

final class SaleProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductRef>>,
          List<ProductRef>,
          FutureOr<List<ProductRef>>
        >
    with $FutureModifier<List<ProductRef>>, $FutureProvider<List<ProductRef>> {
  /// Catálogo de productos del flujo de venta — lo comparten el formulario de
  /// nueva venta y el detalle de factura (para resolver nombres por productId).
  SaleProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleProductsHash();

  @$internal
  @override
  $FutureProviderElement<List<ProductRef>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductRef>> create(Ref ref) {
    return saleProducts(ref);
  }
}

String _$saleProductsHash() => r'7cbbac93f9e24e66ce1e10ad5e289cf40f08ca31';

/// Detalle de factura + nombres de producto resueltos, en paralelo.
/// Las líneas del API solo traen productId; el nombre sale del catálogo.

@ProviderFor(invoiceDetailWithNames)
final invoiceDetailWithNamesProvider = InvoiceDetailWithNamesFamily._();

/// Detalle de factura + nombres de producto resueltos, en paralelo.
/// Las líneas del API solo traen productId; el nombre sale del catálogo.

final class InvoiceDetailWithNamesProvider
    extends
        $FunctionalProvider<
          AsyncValue<({Invoice invoice, Map<String, String> productNames})>,
          ({Invoice invoice, Map<String, String> productNames}),
          FutureOr<({Invoice invoice, Map<String, String> productNames})>
        >
    with
        $FutureModifier<({Invoice invoice, Map<String, String> productNames})>,
        $FutureProvider<({Invoice invoice, Map<String, String> productNames})> {
  /// Detalle de factura + nombres de producto resueltos, en paralelo.
  /// Las líneas del API solo traen productId; el nombre sale del catálogo.
  InvoiceDetailWithNamesProvider._({
    required InvoiceDetailWithNamesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'invoiceDetailWithNamesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invoiceDetailWithNamesHash();

  @override
  String toString() {
    return r'invoiceDetailWithNamesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<({Invoice invoice, Map<String, String> productNames})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({Invoice invoice, Map<String, String> productNames})> create(
    Ref ref,
  ) {
    final argument = this.argument as String;
    return invoiceDetailWithNames(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoiceDetailWithNamesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invoiceDetailWithNamesHash() =>
    r'157c85f1f10310e96edaa9712c64fdc39d486fdd';

/// Detalle de factura + nombres de producto resueltos, en paralelo.
/// Las líneas del API solo traen productId; el nombre sale del catálogo.

final class InvoiceDetailWithNamesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({Invoice invoice, Map<String, String> productNames})>,
          String
        > {
  InvoiceDetailWithNamesFamily._()
    : super(
        retry: null,
        name: r'invoiceDetailWithNamesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Detalle de factura + nombres de producto resueltos, en paralelo.
  /// Las líneas del API solo traen productId; el nombre sale del catálogo.

  InvoiceDetailWithNamesProvider call(String id) =>
      InvoiceDetailWithNamesProvider._(argument: id, from: this);

  @override
  String toString() => r'invoiceDetailWithNamesProvider';
}

/// Todo lo que la pantalla de detalle de cliente necesita, en paralelo.

@ProviderFor(customerOverview)
final customerOverviewProvider = CustomerOverviewFamily._();

/// Todo lo que la pantalla de detalle de cliente necesita, en paralelo.

final class CustomerOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({
              Customer customer,
              Paginated<Invoice> invoices,
              CustomerStatement statement,
            })
          >,
          ({
            Customer customer,
            Paginated<Invoice> invoices,
            CustomerStatement statement,
          }),
          FutureOr<
            ({
              Customer customer,
              Paginated<Invoice> invoices,
              CustomerStatement statement,
            })
          >
        >
    with
        $FutureModifier<
          ({
            Customer customer,
            Paginated<Invoice> invoices,
            CustomerStatement statement,
          })
        >,
        $FutureProvider<
          ({
            Customer customer,
            Paginated<Invoice> invoices,
            CustomerStatement statement,
          })
        > {
  /// Todo lo que la pantalla de detalle de cliente necesita, en paralelo.
  CustomerOverviewProvider._({
    required CustomerOverviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customerOverviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerOverviewHash();

  @override
  String toString() {
    return r'customerOverviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<
    ({
      Customer customer,
      Paginated<Invoice> invoices,
      CustomerStatement statement,
    })
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<
    ({
      Customer customer,
      Paginated<Invoice> invoices,
      CustomerStatement statement,
    })
  >
  create(Ref ref) {
    final argument = this.argument as String;
    return customerOverview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerOverviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerOverviewHash() => r'23c305049954f1584d12358adf861d60b6e1b6a2';

/// Todo lo que la pantalla de detalle de cliente necesita, en paralelo.

final class CustomerOverviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<
            ({
              Customer customer,
              Paginated<Invoice> invoices,
              CustomerStatement statement,
            })
          >,
          String
        > {
  CustomerOverviewFamily._()
    : super(
        retry: null,
        name: r'customerOverviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Todo lo que la pantalla de detalle de cliente necesita, en paralelo.

  CustomerOverviewProvider call(String customerId) =>
      CustomerOverviewProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerOverviewProvider';
}

@ProviderFor(saleFormData)
final saleFormDataProvider = SaleFormDataProvider._();

final class SaleFormDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaleFormData>,
          SaleFormData,
          FutureOr<SaleFormData>
        >
    with $FutureModifier<SaleFormData>, $FutureProvider<SaleFormData> {
  SaleFormDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleFormDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleFormDataHash();

  @$internal
  @override
  $FutureProviderElement<SaleFormData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaleFormData> create(Ref ref) {
    return saleFormData(ref);
  }
}

String _$saleFormDataHash() => r'8549b0ea20dcc03e66982affb4812a34ce4b8ddc';

@ProviderFor(CustomerMutations)
final customerMutationsProvider = CustomerMutationsProvider._();

final class CustomerMutationsProvider
    extends $NotifierProvider<CustomerMutations, void> {
  CustomerMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerMutationsHash();

  @$internal
  @override
  CustomerMutations create() => CustomerMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$customerMutationsHash() => r'3f106cc5ccab4c0b6b54a9fbc56ef49264daf8ab';

abstract class _$CustomerMutations extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SaleMutations)
final saleMutationsProvider = SaleMutationsProvider._();

final class SaleMutationsProvider
    extends $NotifierProvider<SaleMutations, void> {
  SaleMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saleMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saleMutationsHash();

  @$internal
  @override
  SaleMutations create() => SaleMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$saleMutationsHash() => r'268bfe01b567b76b4bb08062c96a2ffd047dc9ee';

abstract class _$SaleMutations extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
