import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/api_client.dart';

/// Descarga archivos generados por el backend (`/exports/*`) y se los entrega
/// al usuario. `SharePlus` resuelve la entrega por plataforma: en web cae a
/// una descarga de blob cuando `navigator.share` no soporta archivos; en
/// Android/iOS abre la hoja de compartir nativa.
class ExportsService {
  final ApiClient _api;
  ExportsService(this._api);

  Future<void> downloadExcel(String report, {Map<String, String>? params}) =>
      _downloadBinary(
        '/exports/$report/excel',
        params,
        '$report.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

  Future<void> downloadPdf(String report, {Map<String, String>? params}) =>
      _downloadBinary('/exports/$report/pdf', params, '$report.pdf', 'application/pdf');

  Future<void> downloadCsv(String report, {Map<String, String>? params}) async {
    final res = await _api.dio
        .get<String>('/exports/$report/csv', queryParameters: params);
    await _deliver(utf8.encode(res.data!), '$report.csv', 'text/csv');
  }

  Future<void> downloadInvoicePdf(String invoiceId) => _downloadBinary(
        '/exports/invoices/$invoiceId/pdf',
        null,
        'factura-$invoiceId.pdf',
        'application/pdf',
      );

  Future<void> _downloadBinary(
    String path,
    Map<String, String>? params,
    String filename,
    String mimeType,
  ) async {
    final res = await _api.dio.get<List<int>>(
      path,
      queryParameters: params,
      options: Options(responseType: ResponseType.bytes),
    );
    await _deliver(res.data!, filename, mimeType);
  }

  Future<void> _deliver(List<int> bytes, String filename, String mimeType) {
    return SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(Uint8List.fromList(bytes), mimeType: mimeType, name: filename),
        ],
        fileNameOverrides: [filename],
      ),
    );
  }
}
