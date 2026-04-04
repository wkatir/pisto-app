import 'package:dio/dio.dart';
import '../../config/api_client.dart';

class ExportsService {
  final ApiClient _api;
  ExportsService(this._api);

  Future<List<int>> exportExcel(String report, {Map<String, String>? params}) async {
    final res = await _api.dio.get(
      '/exports/$report/excel',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data as List<int>;
  }

  Future<List<int>> exportPdf(String report, {Map<String, String>? params}) async {
    final res = await _api.dio.get(
      '/exports/$report/pdf',
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data as List<int>;
  }

  Future<String> exportCsv(String report, {Map<String, String>? params}) async {
    final res = await _api.dio.get(
      '/exports/$report/csv',
      queryParameters: params,
    );
    return res.data as String;
  }
}
