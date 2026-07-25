import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core_providers.dart';
import '../services/reports_service.dart';
import '../services/exports_service.dart';
import '../services/settings_service.dart';
import '../services/uploads_service.dart';
import '../services/ai_service.dart';

final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService(ref.watch(apiClientProvider));
});

final exportsServiceProvider = Provider<ExportsService>((ref) {
  return ExportsService(ref.watch(apiClientProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(apiClientProvider));
});

final uploadsServiceProvider = Provider<UploadsService>((ref) {
  return UploadsService(ref.watch(apiClientProvider));
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref.watch(apiClientProvider));
});
