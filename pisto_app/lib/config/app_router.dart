import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/landing/screens/landing_screen.dart';
import '../features/sales/screens/sales_screen.dart';
import '../features/collections/screens/collections_screen.dart';
import '../features/purchases/screens/purchases_screen.dart';
import '../features/reports/screens/reports_screen.dart';
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
    final isPublic = path == '/' || path == '/login' || path == '/register';

    if (!loggedIn && !isPublic) return '/login';
    if (loggedIn && isPublic) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellLayout(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/sales',
          builder: (context, state) => const SalesScreen(),
        ),
        GoRoute(
          path: '/collections',
          builder: (context, state) => const CollectionsScreen(),
        ),
        GoRoute(
          path: '/purchases',
          builder: (context, state) => const PurchasesScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
      ],
    ),
  ],
);
