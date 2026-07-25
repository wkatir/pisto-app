// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchases_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(purchasesRepository)
final purchasesRepositoryProvider = PurchasesRepositoryProvider._();

final class PurchasesRepositoryProvider
    extends
        $FunctionalProvider<
          PurchasesRepository,
          PurchasesRepository,
          PurchasesRepository
        >
    with $Provider<PurchasesRepository> {
  PurchasesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchasesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchasesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PurchasesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchasesRepository create(Ref ref) {
    return purchasesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchasesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchasesRepository>(value),
    );
  }
}

String _$purchasesRepositoryHash() =>
    r'1c82882775c0a196735db88c8fec697fa7adec0b';

@ProviderFor(suppliersList)
final suppliersListProvider = SuppliersListProvider._();

final class SuppliersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Supplier>>,
          List<Supplier>,
          FutureOr<List<Supplier>>
        >
    with $FutureModifier<List<Supplier>>, $FutureProvider<List<Supplier>> {
  SuppliersListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suppliersListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suppliersListHash();

  @$internal
  @override
  $FutureProviderElement<List<Supplier>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Supplier>> create(Ref ref) {
    return suppliersList(ref);
  }
}

String _$suppliersListHash() => r'c8de89b8e1656ac2a0ac05e99a6d19b799b601d7';

@ProviderFor(purchaseOrdersList)
final purchaseOrdersListProvider = PurchaseOrdersListFamily._();

final class PurchaseOrdersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Paginated<PurchaseOrder>>,
          Paginated<PurchaseOrder>,
          FutureOr<Paginated<PurchaseOrder>>
        >
    with
        $FutureModifier<Paginated<PurchaseOrder>>,
        $FutureProvider<Paginated<PurchaseOrder>> {
  PurchaseOrdersListProvider._({
    required PurchaseOrdersListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'purchaseOrdersListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseOrdersListHash();

  @override
  String toString() {
    return r'purchaseOrdersListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Paginated<PurchaseOrder>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Paginated<PurchaseOrder>> create(Ref ref) {
    final argument = this.argument as int;
    return purchaseOrdersList(ref, page: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseOrdersListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseOrdersListHash() =>
    r'3a4e71f419e48ad08128ffe5e9624f9370fe3656';

final class PurchaseOrdersListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Paginated<PurchaseOrder>>, int> {
  PurchaseOrdersListFamily._()
    : super(
        retry: null,
        name: r'purchaseOrdersListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseOrdersListProvider call({int page = 1}) =>
      PurchaseOrdersListProvider._(argument: page, from: this);

  @override
  String toString() => r'purchaseOrdersListProvider';
}

@ProviderFor(purchaseOrderDetail)
final purchaseOrderDetailProvider = PurchaseOrderDetailFamily._();

final class PurchaseOrderDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<PurchaseOrder>,
          PurchaseOrder,
          FutureOr<PurchaseOrder>
        >
    with $FutureModifier<PurchaseOrder>, $FutureProvider<PurchaseOrder> {
  PurchaseOrderDetailProvider._({
    required PurchaseOrderDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'purchaseOrderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$purchaseOrderDetailHash();

  @override
  String toString() {
    return r'purchaseOrderDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PurchaseOrder> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PurchaseOrder> create(Ref ref) {
    final argument = this.argument as String;
    return purchaseOrderDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseOrderDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$purchaseOrderDetailHash() =>
    r'19598644f682002d27e7f5aaeb627e9bf8221b44';

final class PurchaseOrderDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PurchaseOrder>, String> {
  PurchaseOrderDetailFamily._()
    : super(
        retry: null,
        name: r'purchaseOrderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PurchaseOrderDetailProvider call(String id) =>
      PurchaseOrderDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'purchaseOrderDetailProvider';
}

@ProviderFor(payablesList)
final payablesListProvider = PayablesListFamily._();

final class PayablesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Paginated<PayableRow>>,
          Paginated<PayableRow>,
          FutureOr<Paginated<PayableRow>>
        >
    with
        $FutureModifier<Paginated<PayableRow>>,
        $FutureProvider<Paginated<PayableRow>> {
  PayablesListProvider._({
    required PayablesListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'payablesListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$payablesListHash();

  @override
  String toString() {
    return r'payablesListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Paginated<PayableRow>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Paginated<PayableRow>> create(Ref ref) {
    final argument = this.argument as int;
    return payablesList(ref, page: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PayablesListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$payablesListHash() => r'f422fc7994aa169f586dfd05775b541453194a85';

final class PayablesListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Paginated<PayableRow>>, int> {
  PayablesListFamily._()
    : super(
        retry: null,
        name: r'payablesListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PayablesListProvider call({int page = 1}) =>
      PayablesListProvider._(argument: page, from: this);

  @override
  String toString() => r'payablesListProvider';
}

@ProviderFor(purchaseFormData)
final purchaseFormDataProvider = PurchaseFormDataProvider._();

final class PurchaseFormDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<PurchaseFormData>,
          PurchaseFormData,
          FutureOr<PurchaseFormData>
        >
    with $FutureModifier<PurchaseFormData>, $FutureProvider<PurchaseFormData> {
  PurchaseFormDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseFormDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseFormDataHash();

  @$internal
  @override
  $FutureProviderElement<PurchaseFormData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PurchaseFormData> create(Ref ref) {
    return purchaseFormData(ref);
  }
}

String _$purchaseFormDataHash() => r'3fa8b321936fe1b6db1ae62ad14662e843f24073';

@ProviderFor(PurchasesMutations)
final purchasesMutationsProvider = PurchasesMutationsProvider._();

final class PurchasesMutationsProvider
    extends $NotifierProvider<PurchasesMutations, void> {
  PurchasesMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchasesMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchasesMutationsHash();

  @$internal
  @override
  PurchasesMutations create() => PurchasesMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$purchasesMutationsHash() =>
    r'40efe70e198e4fbd7213291a08779f8121307cfa';

abstract class _$PurchasesMutations extends $Notifier<void> {
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
