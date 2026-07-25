// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider = InventoryRepositoryProvider._();

final class InventoryRepositoryProvider
    extends
        $FunctionalProvider<
          InventoryRepository,
          InventoryRepository,
          InventoryRepository
        >
    with $Provider<InventoryRepository> {
  InventoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<InventoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InventoryRepository create(Ref ref) {
    return inventoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryRepository>(value),
    );
  }
}

String _$inventoryRepositoryHash() =>
    r'3dec484a992b9dc1d7229fd8c3bd2ca2ee4e443f';

@ProviderFor(productsList)
final productsListProvider = ProductsListFamily._();

final class ProductsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<Paginated<Product>>,
          Paginated<Product>,
          FutureOr<Paginated<Product>>
        >
    with
        $FutureModifier<Paginated<Product>>,
        $FutureProvider<Paginated<Product>> {
  ProductsListProvider._({
    required ProductsListFamily super.from,
    required ({int page, String search}) super.argument,
  }) : super(
         retry: null,
         name: r'productsListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productsListHash();

  @override
  String toString() {
    return r'productsListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Paginated<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Paginated<Product>> create(Ref ref) {
    final argument = this.argument as ({int page, String search});
    return productsList(ref, page: argument.page, search: argument.search);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductsListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productsListHash() => r'64d1791c2c453105e4d69795e5e0f0bfb6a50956';

final class ProductsListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Paginated<Product>>,
          ({int page, String search})
        > {
  ProductsListFamily._()
    : super(
        retry: null,
        name: r'productsListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductsListProvider call({int page = 1, String search = ''}) =>
      ProductsListProvider._(
        argument: (page: page, search: search),
        from: this,
      );

  @override
  String toString() => r'productsListProvider';
}

/// Catálogo de productos para dropdowns (transferencias, ajustes).

@ProviderFor(productOptions)
final productOptionsProvider = ProductOptionsProvider._();

/// Catálogo de productos para dropdowns (transferencias, ajustes).

final class ProductOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  /// Catálogo de productos para dropdowns (transferencias, ajustes).
  ProductOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    return productOptions(ref);
  }
}

String _$productOptionsHash() => r'8f2b31bb651abc6142d6cb5f0d9c1c6af770d396';

@ProviderFor(productMovements)
final productMovementsProvider = ProductMovementsFamily._();

final class ProductMovementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StockMovement>>,
          List<StockMovement>,
          FutureOr<List<StockMovement>>
        >
    with
        $FutureModifier<List<StockMovement>>,
        $FutureProvider<List<StockMovement>> {
  ProductMovementsProvider._({
    required ProductMovementsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productMovementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productMovementsHash();

  @override
  String toString() {
    return r'productMovementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<StockMovement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StockMovement>> create(Ref ref) {
    final argument = this.argument as String;
    return productMovements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductMovementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productMovementsHash() => r'0472164feb222c1a77487686232172e7cedaa03b';

final class ProductMovementsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<StockMovement>>, String> {
  ProductMovementsFamily._()
    : super(
        retry: null,
        name: r'productMovementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductMovementsProvider call(String productId) =>
      ProductMovementsProvider._(argument: productId, from: this);

  @override
  String toString() => r'productMovementsProvider';
}

/// Todo lo que las pestañas no paginadas del inventario necesitan, en paralelo.

@ProviderFor(inventoryOverview)
final inventoryOverviewProvider = InventoryOverviewProvider._();

/// Todo lo que las pestañas no paginadas del inventario necesitan, en paralelo.

final class InventoryOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<
            ({
              List<LowStockAlert> alerts,
              List<Category> categories,
              List<Transfer> transfers,
              List<UnitOfMeasure> units,
              List<Warehouse> warehouses,
            })
          >,
          ({
            List<LowStockAlert> alerts,
            List<Category> categories,
            List<Transfer> transfers,
            List<UnitOfMeasure> units,
            List<Warehouse> warehouses,
          }),
          FutureOr<
            ({
              List<LowStockAlert> alerts,
              List<Category> categories,
              List<Transfer> transfers,
              List<UnitOfMeasure> units,
              List<Warehouse> warehouses,
            })
          >
        >
    with
        $FutureModifier<
          ({
            List<LowStockAlert> alerts,
            List<Category> categories,
            List<Transfer> transfers,
            List<UnitOfMeasure> units,
            List<Warehouse> warehouses,
          })
        >,
        $FutureProvider<
          ({
            List<LowStockAlert> alerts,
            List<Category> categories,
            List<Transfer> transfers,
            List<UnitOfMeasure> units,
            List<Warehouse> warehouses,
          })
        > {
  /// Todo lo que las pestañas no paginadas del inventario necesitan, en paralelo.
  InventoryOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryOverviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryOverviewHash();

  @$internal
  @override
  $FutureProviderElement<
    ({
      List<LowStockAlert> alerts,
      List<Category> categories,
      List<Transfer> transfers,
      List<UnitOfMeasure> units,
      List<Warehouse> warehouses,
    })
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<
    ({
      List<LowStockAlert> alerts,
      List<Category> categories,
      List<Transfer> transfers,
      List<UnitOfMeasure> units,
      List<Warehouse> warehouses,
    })
  >
  create(Ref ref) {
    return inventoryOverview(ref);
  }
}

String _$inventoryOverviewHash() => r'07c6f44704f74b67d74f1064230f1e94a7b4b251';

@ProviderFor(InventoryMutations)
final inventoryMutationsProvider = InventoryMutationsProvider._();

final class InventoryMutationsProvider
    extends $NotifierProvider<InventoryMutations, void> {
  InventoryMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryMutationsHash();

  @$internal
  @override
  InventoryMutations create() => InventoryMutations();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$inventoryMutationsHash() =>
    r'79ba9d2b69fc73973428521747f8b65ec9f2536c';

abstract class _$InventoryMutations extends $Notifier<void> {
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
