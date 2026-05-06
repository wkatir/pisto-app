import '../../config/api_client.dart';

class SettingsService {
  final ApiClient _api;
  SettingsService(this._api);

  Future<Map<String, dynamic>?> getBusiness() async {
    final resp = await _api.dio.get('/settings/business');
    return resp.data['data'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> updateBusiness(Map<String, dynamic> data) async {
    final resp = await _api.dio.put('/settings/business', data: data);
    return resp.data['data'] as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> listTaxes() async {
    final resp = await _api.dio.get('/settings/taxes');
    final list = (resp.data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createTax(String name, String rate) async {
    final resp = await _api.dio.post('/settings/taxes', data: {'name': name, 'rate': rate});
    return (resp.data['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<void> toggleTax(String id, bool isActive) async {
    await _api.dio.put('/settings/taxes/$id/toggle', data: {'isActive': isActive});
  }

  Future<List<Map<String, dynamic>>> listPaymentMethods() async {
    final resp = await _api.dio.get('/settings/payment-methods');
    final list = (resp.data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createPaymentMethod(String name) async {
    final resp = await _api.dio.post('/settings/payment-methods', data: {'name': name});
    return (resp.data['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<void> togglePaymentMethod(String id, bool isActive) async {
    await _api.dio.put('/settings/payment-methods/$id/toggle', data: {'isActive': isActive});
  }
}
