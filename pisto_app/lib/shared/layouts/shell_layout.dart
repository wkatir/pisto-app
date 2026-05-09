import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../i18n/translations.g.dart';
import '../../config/app_theme.dart';
import '../widgets/image_picker_field.dart';

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
      _NavDest(LucideIcons.layoutDashboard, t.dashboard, '/dashboard', _NavSection.main),
      _NavDest(LucideIcons.receipt, t.sales, '/sales', _NavSection.main),
      _NavDest(LucideIcons.wallet, t.collections, '/collections', _NavSection.main),
      _NavDest(LucideIcons.package, t.inventory, '/inventory', _NavSection.main),
      _NavDest(LucideIcons.shoppingCart, t.purchases, '/purchases', _NavSection.main),
      _NavDest(LucideIcons.walletMinimal, t.expenses, '/expenses', _NavSection.main),
      _NavDest(LucideIcons.chartColumn, t.reports, '/reports', _NavSection.insights),
    ];

    final path = GoRouterState.of(context).uri.path;
    final selectedIdx = destinations.indexWhere((d) => d.path == path).clamp(0, destinations.length - 1);

    if (useMobileNav) {
      // Mobile nav muestra solo los 5 más usados; el resto vive detrás del avatar.
      final mobileDests = destinations.take(5).toList();
      final mobileSelected = mobileDests.indexWhere((d) => d.path == path).clamp(0, mobileDests.length - 1);
      return Scaffold(
        appBar: _MobileAppBar(t: t),
        body: child,
        bottomNavigationBar: _BottomTabBar(
          destinations: mobileDests,
          selectedIndex: mobileSelected,
          onTap: (i) => context.go(mobileDests[i].path),
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
          Container(width: 1, color: AppTheme.sidebarDivider(context)),
          Expanded(child: child),
        ],
      ),
    );
  }
}

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
    final width = isExtended ? 240.0 : 72.0;
    final user = ref.watch(authProvider).value;

    // Agrupa destinos por sección preservando el índice global.
    final mainItems = <(int, _NavDest)>[];
    final insightsItems = <(int, _NavDest)>[];
    for (var i = 0; i < destinations.length; i++) {
      final d = destinations[i];
      if (d.section == _NavSection.main) {
        mainItems.add((i, d));
      } else {
        insightsItems.add((i, d));
      }
    }

    return Container(
      width: width,
      color: AppTheme.sidebarBg(context),
      child: Column(
        children: [
          _SidebarHeader(isExtended: isExtended, user: user),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isExtended ? 12 : 8, vertical: 4),
              children: [
                if (isExtended) _SectionLabel(text: 'OPERACIÓN'),
                ...mainItems.map(
                  (e) => _NavItem(
                    dest: e.$2,
                    selected: e.$1 == selectedIdx,
                    isExtended: isExtended,
                    onTap: () => context.go(e.$2.path),
                  ),
                ),
                if (insightsItems.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  if (isExtended) _SectionLabel(text: 'INSIGHTS'),
                  ...insightsItems.map(
                    (e) => _NavItem(
                      dest: e.$2,
                      selected: e.$1 == selectedIdx,
                      isExtended: isExtended,
                      onTap: () => context.go(e.$2.path),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _SidebarFooter(isExtended: isExtended, t: t),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool isExtended;
  final dynamic user;
  const _SidebarHeader({required this.isExtended, this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final logoColor = cs.primary;
    final userName = (user?.firstName as String?) ?? '';
    final userInitial = userName.isEmpty ? '?' : userName[0].toUpperCase();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isExtended ? 16 : 0,
        20,
        isExtended ? 16 : 0,
        12,
      ),
      child: isExtended
          ? Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: logoColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.landmark, size: 16, color: cs.onPrimary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pisto',
                        style: TextStyle(
                          color: AppTheme.sidebarLogoText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (userName.isNotEmpty)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 9,
                              backgroundColor: cs.primaryContainer,
                              child: Text(
                                userInitial,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Hola, $userName',
                                style: TextStyle(
                                  color: AppTheme.sidebarMutedFg(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: logoColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(LucideIcons.landmark, size: 17, color: cs.onPrimary),
              ),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.sidebarMutedFg(context),
          letterSpacing: 1.2,
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
    final cs = Theme.of(context).colorScheme;
    final mutedFg = AppTheme.sidebarMutedFg(context);
    final iconColor = selected ? cs.primary : mutedFg;
    final labelColor = selected ? AppTheme.sidebarLogoText(context) : mutedFg;
    final bg = selected ? AppTheme.tintBgStrong(context, cs.primary) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppTheme.sidebarHoverBg(context),
          child: SizedBox(
            height: 38,
            child: isExtended
                ? Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(dest.icon, size: 17, color: iconColor),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          dest.label,
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  )
                : Center(
                    child: Container(
                      width: 38,
                      height: 32,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(dest.icon, size: 19, color: iconColor),
                    ),
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
        Container(height: 1, color: AppTheme.sidebarDivider(context)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isExtended ? 12 : 8,
            vertical: 8,
          ),
          child: isExtended
              ? Column(
                  children: [
                    _FooterTile(
                      icon: LucideIcons.userRound,
                      label: 'Mi perfil',
                      onTap: () => context.go('/profile'),
                    ),
                    _FooterTile(
                      icon: LucideIcons.settings,
                      label: t.settings,
                      onTap: () => context.go('/settings'),
                    ),
                    _FooterTile(
                      icon: themeIcon,
                      label: themeLabel,
                      onTap: () => ref.read(themeModeProvider.notifier).cycle(),
                    ),
                    _FooterTile(
                      icon: LucideIcons.globe,
                      label: 'Idioma · $langLabel',
                      onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                    ),
                    _FooterTile(
                      icon: LucideIcons.logOut,
                      label: t.logout,
                      color: AppTheme.danger,
                      onTap: () {
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                    ),
                  ],
                )
              : Column(
                  children: [
                    _IconBtn(icon: LucideIcons.userRound, tooltip: 'Mi perfil', onTap: () => context.go('/profile')),
                    _IconBtn(icon: LucideIcons.settings, tooltip: t.settings, onTap: () => context.go('/settings')),
                    _IconBtn(icon: themeIcon, tooltip: themeLabel, onTap: () => ref.read(themeModeProvider.notifier).cycle()),
                    _IconBtn(icon: LucideIcons.globe, tooltip: '${t.language}: $langLabel', onTap: () => ref.read(localeProvider.notifier).toggleLocale()),
                    _IconBtn(icon: LucideIcons.logOut, tooltip: t.logout, color: AppTheme.danger, onTap: () {
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
    final c = color ?? AppTheme.sidebarMutedFg(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppTheme.sidebarHoverBg(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 14, color: c),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: c,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
          hoverColor: AppTheme.sidebarHoverBg(context),
          child: SizedBox(
            width: 40,
            height: 36,
            child: Icon(icon, size: 17, color: color ?? AppTheme.sidebarMutedFg(context)),
          ),
        ),
      ),
    );
  }
}

enum _NavSection { main, insights }

class _NavDest {
  final IconData icon;
  final String label;
  final String path;
  final _NavSection section;
  const _NavDest(this.icon, this.label, this.path, this.section);
}

// ── Mobile app bar + account sheet ────────────────────────────────────────────

class _MobileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Translations t;
  const _MobileAppBar({required this.t});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).value;
    final initials = _initialsFor(user?.firstName, user?.lastName);
    final avatarUrl = user?.avatarUrl;

    final initialsBox = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, cs.primary),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      surfaceTintColor: cs.surface,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(LucideIcons.landmark, size: 14, color: cs.onPrimary),
          ),
          const SizedBox(width: 10),
          Text(
            'Pisto',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showAccountSheet(context, ref, t),
            child: NetworkImageThumb(
              url: avatarUrl,
              size: 38,
              borderRadius: BorderRadius.circular(20),
              fallback: initialsBox,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.sidebarDivider(context)),
      ),
    );
  }

  static String _initialsFor(String? first, String? last) {
    final f = (first ?? '').trim();
    final l = (last ?? '').trim();
    final fi = f.isEmpty ? '' : f[0].toUpperCase();
    final li = l.isEmpty ? '' : l[0].toUpperCase();
    final out = '$fi$li';
    return out.isEmpty ? '?' : out;
  }
}

void _showAccountSheet(BuildContext context, WidgetRef ref, Translations t) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => _AccountSheetContent(t: t),
  );
}

class _AccountSheetContent extends ConsumerWidget {
  final Translations t;
  const _AccountSheetContent({required this.t});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = ref.watch(authProvider).value;
    final mode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final fullName = user == null ? '' : '${user.firstName} ${user.lastName}'.trim();

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
    final langLabel = locale.languageCode == 'es' ? 'Español' : 'English';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con nombre + email
            if (user != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle(context)),
                ),
                child: Row(
                  children: [
                    NetworkImageThumb(
                      url: user.avatarUrl,
                      size: 44,
                      borderRadius: BorderRadius.circular(14),
                      fallback: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.tintBg(context, cs.primary),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _MobileAppBar._initialsFor(user.firstName, user.lastName),
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fullName.isEmpty ? user.email : fullName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _SheetTile(
              icon: LucideIcons.userRound,
              label: 'Mi perfil',
              onTap: () {
                Navigator.pop(context);
                context.go('/profile');
              },
            ),
            _SheetTile(
              icon: LucideIcons.settings,
              label: t.settings,
              onTap: () {
                Navigator.pop(context);
                context.go('/settings');
              },
            ),
            const SizedBox(height: 8),
            _SheetTile(
              icon: themeIcon,
              label: '${t.theme} · $themeLabel',
              onTap: () => ref.read(themeModeProvider.notifier).cycle(),
              dismissOnTap: false,
            ),
            _SheetTile(
              icon: LucideIcons.globe,
              label: '${t.language} · $langLabel',
              onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
              dismissOnTap: false,
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppTheme.borderSubtle(context)),
            const SizedBox(height: 12),
            _SheetTile(
              icon: LucideIcons.logOut,
              label: t.logout,
              destructive: true,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final bool dismissOnTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.dismissOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = destructive ? AppTheme.danger : cs.onSurface;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          if (dismissOnTap) {
            // El onTap ya hace pop si corresponde.
          }
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: destructive
                      ? AppTheme.tintBg(context, AppTheme.danger)
                      : AppTheme.tintBg(context, cs.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 16, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom bottom tab bar (reemplaza NavigationBar genérico) ─────────────────

/// Bottom tab bar minimalista estilo Notion/Linear.
///
/// No usa labels visibles — solo íconos con un indicador pill debajo del
/// activo. Más limpio que NavigationBar de Material que grita "Flutter app".
class _BottomTabBar extends StatelessWidget {
  final List<_NavDest> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomTabBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: AppTheme.borderSubtle(context)),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: 64,
        child: Row(
          children: List.generate(destinations.length, (i) {
            final dest = destinations[i];
            final isSelected = i == selectedIndex;
            return Expanded(
              child: _BottomTabItem(
                icon: dest.icon,
                label: dest.label,
                selected: isSelected,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _BottomTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomTabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.tintBg(context, cs.primary) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            if (selected) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
