import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/core_providers.dart';

part 'profile_providers.g.dart';

/// Authenticated user's data (`GET /auth/me`).
@riverpod
Future<Map<String, dynamic>> profileMe(Ref ref) {
  return ref.watch(authServiceProvider).getMe();
}

@riverpod
class ProfileMutations extends _$ProfileMutations {
  @override
  void build() {}

  Future<Map<String, dynamic>> update({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? avatarUrl,
  }) async {
    final updated = await ref.read(authServiceProvider).updateProfile(
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          email: email,
          avatarUrl: avatarUrl,
        );
    ref.invalidate(profileMeProvider);
    return updated;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return ref.read(authServiceProvider).changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
  }
}
