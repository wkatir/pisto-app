class AppConstants {
  AppConstants._();

  static const String appName = 'Pisto App';

  // Overridden in production with:
  //   flutter build web --dart-define=API_BASE_URL_WEB=https://your-api.railway.app/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );
  static const String apiBaseUrlWeb = String.fromEnvironment(
    'API_BASE_URL_WEB',
    defaultValue: 'http://127.0.0.1:3000/api/v1',
  );

  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
}
