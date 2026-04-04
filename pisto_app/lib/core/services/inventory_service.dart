import '../../config/api_client.dart';

class InventoryService {
  final ApiClient _api;
  InventoryService(this._api);

  Future<Map<String, dynamic>> listProducts({int page = 1, int limit = 20, String? search, int? categoryId}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['categoryId'] = categoryId;
    final res = await _api.dio.get('/inventory/products', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    final res = await _api.dio.get('/inventory/products/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/inventory/products', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> data) async {
    final res = await _api.dio.put('/inventory/products/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteProduct(String id) async {
    await _api.dio.delete('/inventory/products/$id');
  }

  Future<List<dynamic>> listCategories() async {
    final res = await _api.dio.get('/inventory/categories');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/inventory/categories', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteCategory(int id) async {
    await _api.dio.delete('/inventory/categories/$id');
  }

  Future<List<dynamic>> listWarehouses() async {
    final res = await _api.dio.get('/inventory/warehouses');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createWarehouse(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/inventory/warehouses', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> listUnits() async {
    final res = await _api.dio.get('/inventory/units');
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getProductMovements(String productId) async {
    final res = await _api.dio.get('/inventory/products/$productId/movements');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createAdjustment(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/inventory/adjustments', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> listTransfers() async {
    final res = await _api.dio.get('/inventory/transfers');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createTransfer(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/inventory/transfers', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getLowStockAlerts() async {
    final res = await _api.dio.get('/inventory/alerts');
    return res.data as List<dynamic>;
  }
}
