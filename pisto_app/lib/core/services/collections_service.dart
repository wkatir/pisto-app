import '../../config/api_client.dart';

class CollectionsService {
  final ApiClient _api;
  CollectionsService(this._api);

  Future<Map<String, dynamic>> listReceivables({int page = 1, int limit = 20}) async {
    final res = await _api.dio.get('/collections/receivables', queryParameters: {'page': page, 'limit': limit});
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAgingReport() async {
    final res = await _api.dio.get('/collections/receivables/aging');
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getReceivablePayments(String id) async {
    final res = await _api.dio.get('/collections/receivables/$id/payments');
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createPayment(String receivableId, Map<String, dynamic> data) async {
    final res = await _api.dio.post('/collections/receivables/$receivableId/payments', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCustomerStatement(String customerId) async {
    final res = await _api.dio.get('/collections/customers/$customerId/statement');
    return res.data as Map<String, dynamic>;
  }
}
