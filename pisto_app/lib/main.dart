import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'config/constants.dart';
import 'core/providers/core_providers.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/auth_service.dart';
import 'i18n/translations.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocaleSettings.setLocale(AppLocale.es);

  final container = ProviderContainer();

  final apiClient = container.read(apiClientProvider);
  await apiClient.restoreTokens();

  final authService = AuthService(apiClient);
  if (authService.hasValidSession()) {
    authRouterDelegate.setAuthenticated(true);
  }

  apiClient.onSessionExpired = () {
    authRouterDelegate.setAuthenticated(false);
  };

  runApp(UncontrolledProviderScope(
    container: container,
    child: const PistoApp(),
  ));
}

class PistoApp extends ConsumerWidget {
  const PistoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return TranslationProvider(
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        themeAnimationDuration: Duration.zero,
        locale: LocaleSettings.currentLocale.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: appRouter,
      ),
    );
  }
}
