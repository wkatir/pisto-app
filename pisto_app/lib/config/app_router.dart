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
      pageBuilder: (context, state) => const NoTransitionPage(child: LandingScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => const NoTransitionPage(child: RegisterScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) => const NoTransitionPage(child: ForgotPasswordScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellLayout(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/inventory',
          pageBuilder: (context, state) => const NoTransitionPage(child: InventoryScreen()),
        ),
        GoRoute(
          path: '/sales',
          pageBuilder: (context, state) => const NoTransitionPage(child: SalesScreen()),
        ),
        GoRoute(
          path: '/sales/customers/:id',
          pageBuilder: (context, state) => NoTransitionPage(
            child: CustomerDetailScreen(
              customerId: state.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: '/collections',
          pageBuilder: (context, state) => const NoTransitionPage(child: CollectionsScreen()),
        ),
        GoRoute(
          path: '/purchases',
          pageBuilder: (context, state) => const NoTransitionPage(child: PurchasesScreen()),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => const NoTransitionPage(child: ReportsScreen()),
        ),
        GoRoute(
          path: '/expenses',
          pageBuilder: (context, state) => const NoTransitionPage(child: ExpensesScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
  ],
);
