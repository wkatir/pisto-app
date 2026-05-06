import '../../config/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(String email, String password) async {
    final res = await _apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final authResponse =
        AuthResponse.fromJson(res.data as Map<String, dynamic>);
    await _apiClient.setTokens(
        authResponse.accessToken, authResponse.refreshToken);
    return authResponse;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String businessName,
    String? phone,
  }) async {
    final res = await _apiClient.dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'businessName': businessName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });

    final authResponse =
        AuthResponse.fromJson(res.data as Map<String, dynamic>);
    await _apiClient.setTokens(
        authResponse.accessToken, authResponse.refreshToken);
    return authResponse;
  }

  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  bool hasValidSession() {
    return _apiClient.hasTokens;
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.dio.post('/auth/forgot-password', data: {'email': email});
  }
}
