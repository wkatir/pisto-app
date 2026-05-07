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

  Future<Map<String, dynamic>> getMe() async {
    final res = await _apiClient.dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;
    final res = await _apiClient.dio.patch('/auth/me', data: body);
    return res.data as Map<String, dynamic>;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.dio.post('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
