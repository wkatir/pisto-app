import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../i18n/translations.g.dart';
import '../../config/app_theme.dart';

class ShellLayout extends ConsumerWidget {
  final Widget child;
  const ShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final size = MediaQuery.sizeOf(context);
    final useMobileNav = size.width < Breakpoints.compact;
    final isExtended = size.width >= Breakpoints.sidebarExtended;

    final destinations = [
      _NavDest(LucideIcons.layoutDashboard, t.dashboard, '/dashboard'),
      _NavDest(LucideIcons.package, t.inventory, '/inventory'),
      _NavDest(LucideIcons.receipt, t.sales, '/sales'),
      _NavDest(LucideIcons.wallet, t.collections, '/collections'),
      _NavDest(LucideIcons.shoppingCart, t.purchases, '/purchases'),
      _NavDest(LucideIcons.walletMinimal, t.expenses, '/expenses'),
      _NavDest(LucideIcons.chartColumn, t.reports, '/reports'),
    ];

    final path = GoRouterState.of(context).uri.path;
    final selectedIdx = destinations.indexWhere((d) => d.path == path).clamp(0, destinations.length - 1);

    if (useMobileNav) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIdx,
          onDestinationSelected: (i) => context.go(destinations[i].path),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: destinations
              .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.label))
              .toList(),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            destinations: destinations,
            selectedIdx: selectedIdx,
            isExtended: isExtended,
            ref: ref,
            t: t,
          ),
          Container(width: 1, color: const Color(0xFF1F1F1F)),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Sidebar completo (reemplaza NavigationRail) ───────────────────────────────

class _Sidebar extends ConsumerWidget {
  final List<_NavDest> destinations;
  final int selectedIdx;
  final bool isExtended;
  final WidgetRef ref;
  final Translations t;

  const _Sidebar({
    required this.destinations,
    required this.selectedIdx,
    required this.isExtended,
    required this.ref,
    required this.t,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = isExtended ? 224.0 : 72.0;

    return Container(
      width: width,
      color: const Color(0xFF0D0D0D),
      child: Column(
        children: [
          // Logo
          _SidebarLogo(isExtended: isExtended),
          const SizedBox(height: 8),
          // Nav items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isExtended ? 12 : 8, vertical: 4),
              children: destinations.asMap().entries.map((e) {
                return _NavItem(
                  dest: e.value,
                  selected: e.key == selectedIdx,
                  isExtended: isExtended,
                  onTap: () => context.go(e.value.path),
                );
              }).toList(),
            ),
          ),
          // Footer
          _SidebarFooter(isExtended: isExtended, t: t),
        ],
      ),
    );
  }
}

class _SidebarLogo extends StatelessWidget {
  final bool isExtended;
  const _SidebarLogo({required this.isExtended});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isExtended ? 16 : 0, 20, isExtended ? 16 : 0, 4),
      child: isExtended
          ? Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.turquoise,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.landmark, size: 16, color: Colors.black),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Pisto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            )
          : Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.turquoise,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(LucideIcons.landmark, size: 18, color: Colors.black),
              ),
            ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavDest dest;
  final bool selected;
  final bool isExtended;
  final VoidCallback onTap;

  const _NavItem({
    required this.dest,
    required this.selected,
    required this.isExtended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? Colors.black : AppTheme.sidebarMuted;
    final labelColor = selected ? AppTheme.turquoise : AppTheme.sidebarMuted;
    final bg = selected ? AppTheme.turquoise : Colors.transparent;
    final hoverBg = selected ? AppTheme.turquoise : AppTheme.sidebarHover;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: hoverBg,
          splashColor: AppTheme.turquoise.withValues(alpha: 0.2),
          child: Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: isExtended ? 12 : 0),
            child: isExtended
                ? Row(
                    children: [
                      Icon(dest.icon, size: 18, color: iconColor),
                      const SizedBox(width: 10),
                      Text(
                        dest.label,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(dest.icon, size: 20, color: selected ? Colors.black : AppTheme.sidebarMuted),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends ConsumerWidget {
  final bool isExtended;
  final Translations t;
  const _SidebarFooter({required this.isExtended, required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final themeIcon = switch (mode) {
      ThemeMode.system => LucideIcons.monitor,
      ThemeMode.light => LucideIcons.sun,
      ThemeMode.dark => LucideIcons.moon,
    };
    final themeLabel = switch (mode) {
      ThemeMode.system => t.systemTheme,
      ThemeMode.light => t.lightTheme,
      ThemeMode.dark => t.darkTheme,
    };
    final langLabel = locale.languageCode == 'es' ? 'ES' : 'EN';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: const Color(0xFF1F1F1F)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isExtended ? 12 : 8,
            vertical: 8,
          ),
          child: isExtended
              ? Column(
                  children: [
                    _FooterTile(
                      icon: themeIcon,
                      label: '${t.theme}: $themeLabel',
                      onTap: () => ref.read(themeModeProvider.notifier).cycle(),
                    ),
                    _FooterTile(
                      icon: LucideIcons.globe,
                      label: '${t.language}: $langLabel',
                      onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                    ),
                    _FooterTile(
                      icon: LucideIcons.settings,
                      label: t.settings,
                      onTap: () => context.go('/settings'),
                    ),
                    _FooterTile(
                      icon: LucideIcons.logOut,
                      label: t.logout,
                      color: const Color(0xFFEF4444),
                      onTap: () {
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                    ),
                  ],
                )
              : Column(
                  children: [
                    _IconBtn(icon: themeIcon, tooltip: '${t.theme}: $themeLabel', onTap: () => ref.read(themeModeProvider.notifier).cycle()),
                    _IconBtn(icon: LucideIcons.globe, tooltip: '${t.language}: $langLabel', onTap: () => ref.read(localeProvider.notifier).toggleLocale()),
                    _IconBtn(icon: LucideIcons.settings, tooltip: t.settings, onTap: () => context.go('/settings')),
                    _IconBtn(icon: LucideIcons.logOut, tooltip: t.logout, color: const Color(0xFFEF4444), onTap: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    }),
                  ],
                ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _FooterTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _FooterTile({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFAAAAAA);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: const Color(0xFF1A1A1A),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 14, color: c),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color? color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.tooltip, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: const Color(0xFF1A1A1A),
          child: SizedBox(
            width: 40,
            height: 36,
            child: Icon(icon, size: 17, color: color ?? const Color(0xFFAAAAAA)),
          ),
        ),
      ),
    );
  }
}

class _NavDest {
  final IconData icon;
  final String label;
  final String path;
  const _NavDest(this.icon, this.label, this.path);
}
