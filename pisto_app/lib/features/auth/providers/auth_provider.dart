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
      authRouterDelegate.setAuthenticated(true);
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
      authRouterDelegate.setAuthenticated(true);
    } catch (e) {
      state = AsyncError(ApiClient.parseError(e), StackTrace.current);
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AsyncData(null);
    authRouterDelegate.setAuthenticated(false);
  }

  /// Refreshes the [UserModel] from the backend (`GET /auth/me`).
  /// Useful after updating the profile/avatar so sidebar and AppBar
  /// reflect the changes without waiting for the next login.
  Future<void> refresh() async {
    if (state.value == null) return;
    try {
      final authService = ref.read(authServiceProvider);
      final me = await authService.getMe();
      state = AsyncData(UserModel(
        id: me['id']?.toString() ?? state.value!.id,
        email: me['email']?.toString() ?? state.value!.email,
        firstName: me['firstName']?.toString() ?? state.value!.firstName,
        lastName: me['lastName']?.toString() ?? state.value!.lastName,
        avatarUrl: me['avatarUrl'] as String?,
        roles: (me['roles'] as List?)?.cast<String>() ?? state.value!.roles,
      ));
    } catch (_) {
      // Best-effort sync after a profile update that already succeeded —
      // a failed refresh just leaves the sidebar/AppBar stale until the
      // next login, so we keep the previous state instead of surfacing it.
    }
  }
}
