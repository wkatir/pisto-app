// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(collectionsRepository)
final collectionsRepositoryProvider = CollectionsRepositoryProvider._();

final class CollectionsRepositoryProvider
    extends
        $FunctionalProvider<
          CollectionsRepository,
          CollectionsRepository,
          CollectionsRepository
        >
    with $Provider<CollectionsRepository> {
  CollectionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CollectionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CollectionsRepository create(Ref ref) {
    return collectionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionsRepository>(value),
    );
  }
}

String _$collectionsRepositoryHash() =>
    r'648b98964cd8293fcd85db5485c1806d5d55f129';

@ProviderFor(receivablesList)
final receivablesListProvider = ReceivablesListFamily._();

final class ReceivablesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Paginated<ReceivableListItem>>,
          Paginated<ReceivableListItem>,
          FutureOr<Paginated<ReceivableListItem>>
        >
    with
        $FutureModifier<Paginated<ReceivableListItem>>,
        $FutureProvider<Paginated<ReceivableListItem>> {
  ReceivablesListProvider._({
    required ReceivablesListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'receivablesListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$receivablesListHash();

  @override
  String toString() {
    return r'receivablesListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Paginated<ReceivableListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Paginated<ReceivableListItem>> create(Ref ref) {
    final argument = this.argument as int;
    return receivablesList(ref, page: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceivablesListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$receivablesListHash() => r'657c8709700d2b78af67b41de550c2335279f43d';

final class ReceivablesListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Paginated<ReceivableListItem>>,
          int
        > {
  ReceivablesListFamily._()
    : super(
        retry: null,
        name: r'receivablesListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReceivablesListProvider call({int page = 1}) =>
      ReceivablesListProvider._(argument: page, from: this);

  @override
  String toString() => r'receivablesListProvider';
}

@ProviderFor(agingReport)
final agingReportProvider = AgingReportProvider._();

final class AgingReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AgingBucket>>,
          List<AgingBucket>,
          FutureOr<List<AgingBucket>>
        >
    with
        $FutureModifier<List<AgingBucket>>,
        $FutureProvider<List<AgingBucket>> {
  AgingReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agingReportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agingReportHash();

  @$internal
  @override
  $FutureProviderElement<List<AgingBucket>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AgingBucket>> create(Ref ref) {
    return agingReport(ref);
  }
}

String _$agingReportHash() => r'cf63a497823759aaf77e42fb6310f7bb8ec8a7ae';

@ProviderFor(receivablePayments)
final receivablePaymentsProvider = ReceivablePaymentsFamily._();

final class ReceivablePaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReceivablePayment>>,
          List<ReceivablePayment>,
          FutureOr<List<ReceivablePayment>>
        >
    with
        $FutureModifier<List<ReceivablePayment>>,
        $FutureProvider<List<ReceivablePayment>> {
  ReceivablePaymentsProvider._({
    required ReceivablePaymentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'receivablePaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$receivablePaymentsHash();

  @override
  String toString() {
    return r'receivablePaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ReceivablePayment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReceivablePayment>> create(Ref ref) {
    final argument = this.argument as String;
    return receivablePayments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceivablePaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$receivablePaymentsHash() =>
    r'd62695490031318df25d336d3bcb3a029c50f748';

final class ReceivablePaymentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ReceivablePayment>>, String> {
  ReceivablePaymentsFamily._()
    : super(
        retry: null,
        name: r'receivablePaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReceivablePaymentsProvider call(String receivableId) =>
      ReceivablePaymentsProvider._(argument: receivableId, from: this);

  @override
  String toString() => r'receivablePaymentsProvider';
}

@ProviderFor(collectionsPaymentMethods)
final collectionsPaymentMethodsProvider = CollectionsPaymentMethodsProvider._();

final class CollectionsPaymentMethodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentMethod>>,
          List<PaymentMethod>,
          FutureOr<List<PaymentMethod>>
        >
    with
        $FutureModifier<List<PaymentMethod>>,
        $FutureProvider<List<PaymentMethod>> {
  CollectionsPaymentMethodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionsPaymentMethodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsPaymentMethodsHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentMethod>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentMethod>> create(Ref ref) {
    return collectionsPaymentMethods(ref);
  }
}

String _$collectionsPaymentMethodsHash() =>
    r'430eb558716cda93933e485ec2d011e0e4de8216';

@ProviderFor(CollectionsMutations)
final collectionsMutationsProvider = CollectionsMutationsProvider._();

final class CollectionsMutationsProvider
    extends $NotifierProvider<CollectionsMutations, void> {
  CollectionsMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionsMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsMutationsHash();

  @$internal
  @override
  CollectionsMutations create() => CollectionsMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$collectionsMutationsHash() =>
    r'4f50623d9951fdc969559ff4c5b789603476a894';

abstract class _$CollectionsMutations extends $Notifier<void> {
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
