import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../i18n/translations.g.dart';

class ShellLayout extends ConsumerWidget {
  final Widget child;

  const ShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final size = MediaQuery.sizeOf(context);
    final useMobileNav = size.width < 600;

    final destinations = [
      _NavDest(LucideIcons.layoutDashboard, t.dashboard, '/dashboard'),
      _NavDest(LucideIcons.package, t.inventory, '/inventory'),
      _NavDest(LucideIcons.receipt, t.sales, '/sales'),
      _NavDest(LucideIcons.wallet, t.collections, '/collections'),
      _NavDest(LucideIcons.shoppingCart, t.purchases, '/purchases'),
      _NavDest(LucideIcons.barChart3, t.reports, '/reports'),
    ];

    final selected = _selectedIndex(context, destinations);

    void onDestination(BuildContext context, int index) {
      context.go(destinations[index].path);
    }

    if (useMobileNav) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected,
          onDestinationSelected: (i) => onDestination(context, i),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.icon),
                    label: d.label,
                  ))
              .toList(),
        ),
      );
    }

    final isExtended = size.width >= 1200;

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: isExtended ? 220 : 72,
            child: NavigationRail(
              selectedIndex: selected,
              onDestinationSelected: (i) => onDestination(context, i),
              extended: isExtended,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: _RailHeader(isExtended: isExtended),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _RailFooter(isExtended: isExtended),
                ),
              ),
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context, List<_NavDest> destinations) {
    final path = GoRouterState.of(context).uri.path;
    final idx = destinations.indexWhere((d) => d.path == path);
    return idx >= 0 ? idx : 0;
  }
}

class _RailHeader extends StatelessWidget {
  final bool isExtended;
  const _RailHeader({required this.isExtended});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExtended ? 16 : 0,
        vertical: 12,
      ),
      child: isExtended
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LucideIcons.landmark, size: 20, color: cs.onPrimary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Pisto',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(LucideIcons.landmark, size: 20, color: cs.onPrimary),
            ),
    );
  }
}

class _RailFooter extends ConsumerWidget {
  final bool isExtended;
  const _RailFooter({required this.isExtended});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final ThemeMode mode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final (themeIcon, themeTooltip) = switch (mode) {
      ThemeMode.system => (LucideIcons.monitor, t.systemTheme),
      ThemeMode.light => (LucideIcons.sun, t.lightTheme),
      ThemeMode.dark => (LucideIcons.moon, t.darkTheme),
    };

    final langLabel = locale.languageCode == 'es' ? 'ES' : 'EN';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isExtended)
          ListTile(
            dense: true,
            leading: Icon(themeIcon, size: 20),
            title: Text('${t.theme}: $themeTooltip', style: const TextStyle(fontSize: 13)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: () => ref.read(themeModeProvider.notifier).cycle(),
          )
        else
          IconButton(
            icon: Icon(themeIcon, size: 20),
            tooltip: '${t.theme}: $themeTooltip',
            onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
          ),
        if (isExtended)
          ListTile(
            dense: true,
            leading: const Icon(LucideIcons.globe, size: 20),
            title: Text('${t.language}: $langLabel', style: const TextStyle(fontSize: 13)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
          )
        else
          IconButton(
            icon: const Icon(LucideIcons.globe, size: 20),
            tooltip: '${t.language}: $langLabel',
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
          ),
        const SizedBox(height: 4),
        if (isExtended)
          ListTile(
            dense: true,
            leading: Icon(LucideIcons.logOut, size: 20, color: cs.error),
            title: Text(t.logout, style: TextStyle(color: cs.error, fontSize: 13)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          )
        else
          IconButton(
            icon: Icon(LucideIcons.logOut, size: 20, color: cs.error),
            tooltip: t.logout,
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _NavDest {
  final IconData icon;
  final String label;
  final String path;
  const _NavDest(this.icon, this.label, this.path);
}
