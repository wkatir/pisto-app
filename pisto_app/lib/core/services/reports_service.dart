import '../../config/api_client.dart';

class ReportsService {
  final ApiClient _api;
  ReportsService(this._api);

  Future<Map<String, dynamic>> getDashboardKPIs() async {
    final res = await _api.dio.get('/reports/dashboard');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSalesSummary({String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final res = await _api.dio.get('/reports/sales-summary', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTopProducts({int limit = 10, String? from, String? to}) async {
    final params = <String, dynamic>{'limit': limit};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final res = await _api.dio.get('/reports/top-products', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getInventoryValuation() async {
    final res = await _api.dio.get('/reports/inventory-valuation');
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getSalesTrend({int days = 30}) async {
    final res = await _api.dio.get('/reports/sales-trend', queryParameters: {'days': days});
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getSalesByCategory() async {
    final res = await _api.dio.get('/reports/sales-by-category');
    return res.data as List<dynamic>;
  }

  Future<dynamic> getGrossProfit({String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final res = await _api.dio.get('/reports/gross-profit', queryParameters: params);
    return res.data;
  }
}
