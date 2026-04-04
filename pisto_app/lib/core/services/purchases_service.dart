import '../../config/api_client.dart';

class PurchasesService {
  final ApiClient _api;
  PurchasesService(this._api);

  Future<List<dynamic>> listSuppliers() async {
    final res = await _api.dio.get('/purchases/suppliers');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createSupplier(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/purchases/suppliers', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSupplier(String id, Map<String, dynamic> data) async {
    final res = await _api.dio.put('/purchases/suppliers/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteSupplier(String id) async {
    await _api.dio.delete('/purchases/suppliers/$id');
  }

  Future<List<dynamic>> listSupplierProducts({String? supplierId}) async {
    final params = supplierId != null ? {'supplierId': supplierId} : null;
    final res = await _api.dio.get('/purchases/supplier-products', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createSupplierProduct(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/purchases/supplier-products', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSupplierProduct(String id, Map<String, dynamic> data) async {
    final res = await _api.dio.put('/purchases/supplier-products/$id', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteSupplierProduct(String id) async {
    await _api.dio.delete('/purchases/supplier-products/$id');
  }

  Future<Map<String, dynamic>> listOrders({int page = 1, int limit = 20}) async {
    final res = await _api.dio.get('/purchases/orders', queryParameters: {'page': page, 'limit': limit});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getOrder(String id) async {
    final res = await _api.dio.get('/purchases/orders/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final res = await _api.dio.post('/purchases/orders', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> receiveGoods(String orderId, Map<String, dynamic> data) async {
    final res = await _api.dio.post('/purchases/orders/$orderId/receive', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listPayables({int page = 1, int limit = 20}) async {
    final res = await _api.dio.get('/purchases/payables', queryParameters: {'page': page, 'limit': limit});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSupplierPayment(String payableId, Map<String, dynamic> data) async {
    final res = await _api.dio.post('/purchases/payables/$payableId/payments', data: data);
    return res.data as Map<String, dynamic>;
  }
}
