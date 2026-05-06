import '../../config/api_client.dart';

class ReportsService {
  final ApiClient _api;
  ReportsService(this._api);

  Future<Map<String, dynamic>> getDashboardKPIs({DateTime? startDate, DateTime? endDate}) async {
    final params = <String, dynamic>{};
    if (startDate != null) params['startDate'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) params['endDate'] = endDate.toIso8601String().split('T')[0];
    final res = await _api.dio.get('/reports/dashboard', queryParameters: params.isEmpty ? null : params);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSalesSummary({String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final res = await _api.dio.get('/reports/sales-summary', queryParameters: params);
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTopProducts({int limit = 10, String? from, String? to, DateTime? startDate, DateTime? endDate}) async {
    final params = <String, dynamic>{'limit': limit};
    if (startDate != null) {
      params['from'] = startDate.toIso8601String().split('T')[0];
    } else if (from != null) {
      params['from'] = from;
    }
    if (endDate != null) {
      params['to'] = endDate.toIso8601String().split('T')[0];
    } else if (to != null) {
      params['to'] = to;
    }
    final res = await _api.dio.get('/reports/top-products', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getInventoryValuation() async {
    final res = await _api.dio.get('/reports/inventory-valuation');
    return res.data as List<dynamic>;
  }

  Future<List<dynamic>> getSalesTrend({int days = 30, DateTime? startDate, DateTime? endDate}) async {
    final params = <String, dynamic>{'days': days};
    if (startDate != null) params['startDate'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) params['endDate'] = endDate.toIso8601String().split('T')[0];
    final res = await _api.dio.get('/reports/sales-trend', queryParameters: params);
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
