import '../../config/api_client.dart';

// ── Models ──────────────────────────────────────────────────────────────────

class AiChatResponse {
  final String response;
  final String? conversationId;

  AiChatResponse({required this.response, this.conversationId});

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      response: json['response'] as String,
      conversationId: json['conversationId'] as String?,
    );
  }
}

class ScanItem {
  final String? description;
  final double? quantity;
  final double? unitPrice;
  final double? total;

  ScanItem({this.description, this.quantity, this.unitPrice, this.total});

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    return ScanItem(
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

class ScanResult {
  final String? vendor;
  final String? date;
  final List<ScanItem> items;
  final double? total;
  final double? tax;
  final String? currency;

  ScanResult({
    this.vendor,
    this.date,
    this.items = const [],
    this.total,
    this.tax,
    this.currency,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      vendor: json['vendor'] as String?,
      date: json['date'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ScanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }
}

class ForecastDay {
  final String date;
  final double projectedIncome;
  final double projectedExpenses;
  final double netCashFlow;

  ForecastDay({
    required this.date,
    required this.projectedIncome,
    required this.projectedExpenses,
    required this.netCashFlow,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'] as String,
      projectedIncome: (json['projectedIncome'] as num?)?.toDouble() ?? 0,
      projectedExpenses: (json['projectedExpenses'] as num?)?.toDouble() ?? 0,
      netCashFlow: (json['netCashFlow'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ForecastSummary {
  final double totalProjectedIncome;
  final double totalProjectedExpenses;
  final double netProjection;

  ForecastSummary({
    required this.totalProjectedIncome,
    required this.totalProjectedExpenses,
    required this.netProjection,
  });

  factory ForecastSummary.fromJson(Map<String, dynamic> json) {
    return ForecastSummary(
      totalProjectedIncome: (json['totalProjectedIncome'] as num?)?.toDouble() ?? 0,
      totalProjectedExpenses: (json['totalProjectedExpenses'] as num?)?.toDouble() ?? 0,
      netProjection: (json['netProjection'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ForecastResult {
  final List<ForecastDay> forecast;
  final ForecastSummary summary;
  final List<String> insights;
  final String risk;

  ForecastResult({
    required this.forecast,
    required this.summary,
    required this.insights,
    required this.risk,
  });

  factory ForecastResult.fromJson(Map<String, dynamic> json) {
    return ForecastResult(
      forecast: (json['forecast'] as List<dynamic>)
          .map((e) => ForecastDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary:
          ForecastSummary.fromJson(json['summary'] as Map<String, dynamic>),
      insights:
          (json['insights'] as List<dynamic>).map((e) => e as String).toList(),
      risk: json['risk'] as String,
    );
  }
}

class Anomaly {
  final String type;
  final String description;
  final String? severity;
  final String? date;
  final double? value;

  Anomaly({
    required this.type,
    required this.description,
    this.severity,
    this.date,
    this.value,
  });

  factory Anomaly.fromJson(Map<String, dynamic> json) {
    return Anomaly(
      type: json['type'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String?,
      date: json['date'] as String?,
      value: (json['value'] as num?)?.toDouble(),
    );
  }
}

class AnomaliesResult {
  final List<Anomaly> anomalies;
  final String summary;

  AnomaliesResult({required this.anomalies, required this.summary});

  factory AnomaliesResult.fromJson(Map<String, dynamic> json) {
    return AnomaliesResult(
      anomalies: (json['anomalies'] as List<dynamic>)
          .map((e) => Anomaly.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String,
    );
  }
}

// ── Service ─────────────────────────────────────────────────────────────────

class AiService {
  final ApiClient _api;
  AiService(this._api);

  /// Envia mensaje al chat AI y recibe respuesta con contexto de conversacion.
  Future<AiChatResponse> chat(String message,
      {String? conversationId}) async {
    final response = await _api.dio.post('/ai/chat', data: {
      'message': message,
      // ignore: use_null_aware_elements
      if (conversationId != null) 'conversationId': conversationId,
    });
    return AiChatResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Envia imagen en base64 al backend para escaneo OCR + AI.
  Future<ScanResult> scanReceipt(String base64Image, String mimeType) async {
    final response = await _api.dio.post('/ai/scan-receipt', data: {
      'image': base64Image,
      'mimeType': mimeType,
    });
    return ScanResult.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// Obtiene pronostico financiero generado por AI.
  Future<ForecastResult> getForecast({int days = 30}) async {
    final response = await _api.dio
        .get('/ai/forecast', queryParameters: {'days': days});
    return ForecastResult.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// Detecta anomalias en datos financieros.
  Future<AnomaliesResult> getAnomalies() async {
    final response = await _api.dio.get('/ai/anomalies');
    return AnomaliesResult.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
