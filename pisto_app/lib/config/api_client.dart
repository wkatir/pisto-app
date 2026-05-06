import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class ApiClient {
  late final Dio dio;
  VoidCallback? onSessionExpired;

  static const _storage = FlutterSecureStorage();
  String? _accessToken;
  String? _refreshTokenValue;
  bool _isRefreshing = false;

  ApiClient() {
    final baseUrl =
        kIsWeb ? AppConstants.apiBaseUrlWeb : AppConstants.apiBaseUrl;

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            _refreshTokenValue != null &&
            !_isRefreshing) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            error.requestOptions.headers['Authorization'] =
                'Bearer $_accessToken';
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
          onSessionExpired?.call();
        }
        handler.next(error);
      },
    ));
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshTokenValue = refreshToken;
    await _storage.write(
        key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(
        key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshTokenValue = null;
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  bool get hasTokens => _accessToken != null;

  Future<bool> restoreTokens() async {
    _accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    _refreshTokenValue =
        await _storage.read(key: AppConstants.refreshTokenKey);
    return _accessToken != null;
  }

  Future<bool> _tryRefresh() async {
    _isRefreshing = true;
    try {
      final baseUrl =
          kIsWeb ? AppConstants.apiBaseUrlWeb : AppConstants.apiBaseUrl;

      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
      final res = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshTokenValue},
      );

      final newAccess = res.data['accessToken'] as String;
      final newRefresh = res.data['refreshToken'] as String;
      await setTokens(newAccess, newRefresh);
      return true;
    } catch (e, st) {
      debugPrint('Token refresh failed: $e\n$st');
      await clearTokens();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  static String parseError(Object error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final data = error.response!.data as Map;
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
      }

      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'Tiempo de espera agotado. Verifica tu conexión.',
        DioExceptionType.connectionError =>
          'No se pudo conectar al servidor. Verifica que esté corriendo.',
        DioExceptionType.badResponse =>
          'Error del servidor (${error.response?.statusCode})',
        _ => 'Error de red. Intenta de nuevo.',
      };
    }
    return error.toString();
  }
}
