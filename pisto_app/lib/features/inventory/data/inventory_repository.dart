import '../../../config/api_client.dart';
import '../../../core/models/paginated.dart';
import '../models/catalogs.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';
import '../models/transfer.dart';

/// Acceso tipado a `/inventory`. Los errores de Dio se propagan; los parsea la
/// capa de UI compartida (AsyncErrorState / AppToast.guard). Las mutaciones no
/// devuelven la entidad: la UI siempre invalida y refetchea las listas.
class InventoryRepository {
  final ApiClient _api;
  InventoryRepository(this._api);

  // ── Products ───────────────────────────────────────────────────────────────

  Future<Paginated<Product>> listProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final res = await _api.dio.get('/inventory/products', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return Paginated.fromJson(
        res.data as Map<String, dynamic>, Product.fromJson);
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
    await _api.dio.post('/inventory/products', data: {
      'name': name,
      'salePrice': salePrice,
      'unitId': unitId,
      'costPrice': ?costPrice,
      'sku': ?sku,
      'categoryId': ?categoryId,
      'imageUrl': ?imageUrl,
    });
  }

  Future<void> updateProduct(
    String id, {
    String? name,
    String? salePrice,
    String? costPrice,
    String? sku,
    String? imageUrl,
  }) async {
    await _api.dio.put('/inventory/products/$id', data: {
      'name': ?name,
      'salePrice': ?salePrice,
      'costPrice': ?costPrice,
      'sku': ?sku,
      'imageUrl': ?imageUrl,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _api.dio.delete('/inventory/products/$id');
  }

  Future<List<StockMovement>> getProductMovements(String productId) async {
    final res = await _api.dio.get('/inventory/products/$productId/movements');
    return [
      for (final e in res.data as List)
        StockMovement.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<LowStockAlert>> listLowStockAlerts() async {
    final res = await _api.dio.get('/inventory/alerts');
    return [
      for (final e in res.data as List)
        LowStockAlert.fromJson(e as Map<String, dynamic>),
    ];
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  Future<List<Category>> listCategories() async {
    final res = await _api.dio.get('/inventory/categories');
    return [
      for (final e in res.data['data'] as List)
        Category.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<void> createCategory({
    required String name,
    String? description,
  }) async {
    await _api.dio.post('/inventory/categories', data: {
      'name': name,
      'description': ?description,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _api.dio.delete('/inventory/categories/$id');
  }

  // ── Warehouses ─────────────────────────────────────────────────────────────

  Future<List<Warehouse>> listWarehouses() async {
    final res = await _api.dio.get('/inventory/warehouses');
    return [
      for (final e in res.data['data'] as List)
        Warehouse.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<void> createWarehouse({required String name, String? address}) async {
    await _api.dio.post('/inventory/warehouses', data: {
      'name': name,
      'address': ?address,
    });
  }

  // ── Units ──────────────────────────────────────────────────────────────────

  Future<List<UnitOfMeasure>> listUnits() async {
    final res = await _api.dio.get('/inventory/units');
    return [
      for (final e in res.data['data'] as List)
        UnitOfMeasure.fromJson(e as Map<String, dynamic>),
    ];
  }

  // ── Adjustments ────────────────────────────────────────────────────────────

  Future<void> createAdjustment({
    required String productId,
    required String warehouseId,
    required String type,
    required String quantity,
    String? notes,
  }) async {
    await _api.dio.post('/inventory/adjustments', data: {
      'productId': productId,
      'warehouseId': warehouseId,
      'type': type,
      'quantity': quantity,
      'notes': ?notes,
    });
  }

  // ── Transfers ──────────────────────────────────────────────────────────────

  Future<List<Transfer>> listTransfers() async {
    final res = await _api.dio.get('/inventory/transfers');
    return [
      for (final e in res.data as List)
        Transfer.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<void> createTransfer({
    required String fromWarehouseId,
    required String toWarehouseId,
    String? notes,
    required List<TransferLineInput> lines,
  }) async {
    await _api.dio.post('/inventory/transfers', data: {
      'fromWarehouseId': fromWarehouseId,
      'toWarehouseId': toWarehouseId,
      'notes': ?notes,
      'lines': [for (final l in lines) l.toJson()],
    });
  }
}
