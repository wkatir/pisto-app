class AppConstants {
  AppConstants._();

  static const String appName = 'Pisto App';

  // En producción se sobreescribe con:
  //   flutter build web --dart-define=API_BASE_URL_WEB=https://tu-api.railway.app/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );
  static const String apiBaseUrlWeb = String.fromEnvironment(
    'API_BASE_URL_WEB',
    defaultValue: 'http://127.0.0.1:3000/api/v1',
  );

  /// Origen del servidor (sin /api/v1) — usado para construir URLs absolutas
  /// de archivos subidos en /uploads/* que se sirven fuera del basePath.
  static const String apiOrigin = String.fromEnvironment(
    'API_ORIGIN',
    defaultValue: 'http://10.0.2.2:3000',
  );
  static const String apiOriginWeb = String.fromEnvironment(
    'API_ORIGIN_WEB',
    defaultValue: 'http://127.0.0.1:3000',
  );

  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
}
