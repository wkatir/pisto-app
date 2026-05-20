import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/landing/screens/landing_screen.dart';
import '../features/sales/screens/sales_screen.dart';
import '../features/sales/screens/customer_detail_screen.dart';
import '../features/collections/screens/collections_screen.dart';
import '../features/purchases/screens/purchases_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/expenses/screens/expenses_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/ai/screens/ai_chat_screen.dart';
import '../features/ai/screens/scan_receipt_screen.dart';
import '../features/ai/screens/ai_forecast_screen.dart';
import '../shared/layouts/shell_layout.dart';

class AuthRouterDelegate extends ChangeNotifier {
  bool _authenticated = false;
  bool get authenticated => _authenticated;

  void setAuthenticated(bool value) {
    _authenticated = value;
    notifyListeners();
  }
}

final authRouterDelegate = AuthRouterDelegate();

/// Página con crossfade sutil (150ms). Reemplaza NoTransitionPage para que la
/// navegación se sienta fluida sin animaciones llamativas.
class _FadePage<T> extends CustomTransitionPage<T> {
  _FadePage({required super.child, super.key})
      : super(
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 100),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: authRouterDelegate,
  redirect: (context, state) {
    final loggedIn = authRouterDelegate.authenticated;
    final path = state.matchedLocation;
    final isPublic = path == '/' || path == '/login' || path == '/register' || path == '/forgot-password';

    if (!loggedIn && !isPublic) return '/login';
    if (loggedIn && isPublic) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _FadePage(child: const LandingScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _FadePage(child: const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _FadePage(child: const RegisterScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) => _FadePage(child: const ForgotPasswordScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellLayout(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => _FadePage(child: const DashboardScreen()),
        ),
        GoRoute(
          path: '/inventory',
          pageBuilder: (context, state) => _FadePage(child: const InventoryScreen()),
        ),
        GoRoute(
          path: '/sales',
          pageBuilder: (context, state) => _FadePage(child: const SalesScreen()),
        ),
        GoRoute(
          path: '/sales/customers/:id',
          pageBuilder: (context, state) => _FadePage(
            child: CustomerDetailScreen(
              customerId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: '/collections',
          pageBuilder: (context, state) => _FadePage(child: const CollectionsScreen()),
        ),
        GoRoute(
          path: '/purchases',
          pageBuilder: (context, state) => _FadePage(child: const PurchasesScreen()),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => _FadePage(child: const ReportsScreen()),
        ),
        GoRoute(
          path: '/expenses',
          pageBuilder: (context, state) => _FadePage(child: const ExpensesScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _FadePage(child: const ProfileScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _FadePage(child: const SettingsScreen()),
        ),
        GoRoute(
          path: '/ai-chat',
          pageBuilder: (context, state) => _FadePage(child: const AiChatScreen()),
        ),
        GoRoute(
          path: '/ai-scan',
          pageBuilder: (context, state) => _FadePage(child: const ScanReceiptScreen()),
        ),
        GoRoute(
          path: '/ai-forecast',
          pageBuilder: (context, state) => _FadePage(child: const AiForecastScreen()),
        ),
      ],
    ),
  ],
);
