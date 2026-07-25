import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/paginated.dart';
import '../../../core/providers/core_providers.dart';
import '../data/inventory_repository.dart';
import '../models/catalogs.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';
import '../models/transfer.dart';

part 'inventory_providers.g.dart';

@Riverpod(keepAlive: true)
InventoryRepository inventoryRepository(Ref ref) {
  return InventoryRepository(ref.watch(apiClientProvider));
}

// ── Queries ──────────────────────────────────────────────────────────────────

@riverpod
Future<Paginated<Product>> productsList(
  Ref ref, {
  int page = 1,
  String search = '',
}) {
  return ref.watch(inventoryRepositoryProvider).listProducts(
        page: page,
        search: search.isEmpty ? null : search,
      );
}

/// Product catalog for dropdowns (transfers, adjustments).
@riverpod
Future<List<Product>> productOptions(Ref ref) async {
  final page =
      await ref.watch(inventoryRepositoryProvider).listProducts(limit: 100);
  return page.data;
}

@riverpod
Future<List<StockMovement>> productMovements(Ref ref, String productId) {
  return ref.watch(inventoryRepositoryProvider).getProductMovements(productId);
}

/// Everything the non-paginated inventory tabs need, in parallel.
@riverpod
Future<
    ({
      List<Category> categories,
      List<Warehouse> warehouses,
      List<UnitOfMeasure> units,
      List<Transfer> transfers,
      List<LowStockAlert> alerts,
    })> inventoryOverview(Ref ref) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  final (categories, warehouses, units, transfers, alerts) = await (
    repo.listCategories(),
    repo.listWarehouses(),
    repo.listUnits(),
    repo.listTransfers(),
    repo.listLowStockAlerts(),
  ).wait;
  return (
    categories: categories,
    warehouses: warehouses,
    units: units,
    transfers: transfers,
    alerts: alerts,
  );
}

// ── Mutations ────────────────────────────────────────────────────────────────
// Each mutation invalidates only the queries it changed.

@riverpod
class InventoryMutations extends _$InventoryMutations {
  @override
  void build() {}

  void _invalidateProducts() {
    ref.invalidate(productsListProvider);
    ref.invalidate(productOptionsProvider);
    ref.invalidate(inventoryOverviewProvider);
  }

  Future<void> createProduct({
    required String name,
    required String salePrice,
    required String unitId,
    String? costPrice,
    String? sku,
    String? categoryId,
    String? imageUrl,
  }) async {
    await ref.read(inventoryRepositoryProvider).createProduct(
          name: name,
          salePrice: salePrice,
          unitId: unitId,
          costPrice: costPrice,
          sku: sku,
          categoryId: categoryId,
          imageUrl: imageUrl,
        );
    _invalidateProducts();
  }

  Future<void> updateProduct(
    String id, {
    String? name,
    String? salePrice,
    String? costPrice,
    String? sku,
    String? imageUrl,
  }) async {
    await ref.read(inventoryRepositoryProvider).updateProduct(
          id,
          name: name,
          salePrice: salePrice,
          costPrice: costPrice,
          sku: sku,
          imageUrl: imageUrl,
        );
    _invalidateProducts();
  }

  Future<void> deleteProduct(String id) async {
    await ref.read(inventoryRepositoryProvider).deleteProduct(id);
    _invalidateProducts();
  }

  Future<void> createCategory({required String name, String? description}) async {
    await ref
        .read(inventoryRepositoryProvider)
        .createCategory(name: name, description: description);
    ref.invalidate(inventoryOverviewProvider);
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(inventoryRepositoryProvider).deleteCategory(id);
    ref.invalidate(inventoryOverviewProvider);
    // The product list displays the category name.
    ref.invalidate(productsListProvider);
  }

  Future<void> createWarehouse({required String name, String? address}) async {
    await ref
        .read(inventoryRepositoryProvider)
        .createWarehouse(name: name, address: address);
    ref.invalidate(inventoryOverviewProvider);
  }

  Future<void> createAdjustment({
    required String productId,
    required String warehouseId,
    required String type,
    required String quantity,
    String? notes,
  }) async {
    await ref.read(inventoryRepositoryProvider).createAdjustment(
          productId: productId,
          warehouseId: warehouseId,
          type: type,
          quantity: quantity,
          notes: notes,
        );
    ref.invalidate(productsListProvider);
    ref.invalidate(inventoryOverviewProvider);
    ref.invalidate(productMovementsProvider(productId));
  }

  Future<void> createTransfer({
    required String fromWarehouseId,
    required String toWarehouseId,
    String? notes,
    required List<TransferLineInput> lines,
  }) async {
    await ref.read(inventoryRepositoryProvider).createTransfer(
          fromWarehouseId: fromWarehouseId,
          toWarehouseId: toWarehouseId,
          notes: notes,
          lines: lines,
        );
    ref.invalidate(productsListProvider);
    ref.invalidate(inventoryOverviewProvider);
    for (final line in lines) {
      ref.invalidate(productMovementsProvider(line.productId));
    }
  }
}
