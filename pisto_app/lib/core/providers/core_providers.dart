import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../config/api_client.dart';
import '../services/auth_service.dart';

part 'core_providers.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient();
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
}
