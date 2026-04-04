import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../config/api_client.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/core_providers.dart';
import '../../../config/app_router.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AsyncValue<UserModel?> build() {
    return const AsyncData(null);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(email, password);
      state = AsyncData(response.user);
      authChangeNotifier.setAuthenticated(true);
    } catch (e) {
      state = AsyncError(ApiClient.parseError(e), StackTrace.current);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String businessName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        businessName: businessName,
        phone: phone,
      );
      state = AsyncData(response.user);
      authChangeNotifier.setAuthenticated(true);
    } catch (e) {
      state = AsyncError(ApiClient.parseError(e), StackTrace.current);
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AsyncData(null);
    authChangeNotifier.setAuthenticated(false);
  }
}
