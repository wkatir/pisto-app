import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/notifications/widgets/notification_bell.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../i18n/translations.g.dart';
import '../../config/app_theme.dart';
import '../widgets/image_picker_field.dart';
import '../widgets/focus_ring.dart';

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
      _NavDest(LucideIcons.chartColumn, t.reports, '/reports', _NavSection.main),
      _NavDest(LucideIcons.sparkles, 'Chat IA', '/ai-chat', _NavSection.assistant),
      _NavDest(LucideIcons.scan, 'Escanear recibo', '/ai-scan', _NavSection.assistant),
      _NavDest(LucideIcons.trendingUp, 'Pronóstico', '/ai-forecast', _NavSection.assistant),
    ];

    final path = GoRouterState.of(context).uri.path;
    final selectedIdx = destinations.indexWhere((d) => d.path == path).clamp(0, destinations.length - 1);

    if (useMobileNav) {
      // Mobile nav: 4 operations + Assistant; the rest lives behind the avatar.
      final mobileDests = [
        ...destinations.take(4),
        const _NavDest(LucideIcons.sparkles, 'Asistente', '/ai-chat', _NavSection.assistant),
      ];
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
    final cs = Theme.of(context).colorScheme;
    final width = isExtended ? 240.0 : 72.0;
    final user = ref.watch(authProvider).value;

    // Groups destinations by section while preserving the global index.
    final mainItems = <(int, _NavDest)>[];
    final assistantItems = <(int, _NavDest)>[];
    for (var i = 0; i < destinations.length; i++) {
      final d = destinations[i];
      switch (d.section) {
        case _NavSection.main:
          mainItems.add((i, d));
        case _NavSection.assistant:
          assistantItems.add((i, d));
      }
    }

    return Container(
      width: width,
      color: cs.surface,
      child: Column(
        children: [
          _SidebarHeader(isExtended: isExtended, user: user),
          // The assistant is pinned at the top: AI must never sit below the
          // fold or require scrolling on short laptop screens.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExtended ? 12 : 8),
            child: Column(
              children: [
                if (isExtended) _SectionLabel(text: 'ASISTENTE'),
                ...assistantItems.map(
                  (e) => _NavItem(
                    dest: e.$2,
                    selected: e.$1 == selectedIdx,
                    isExtended: isExtended,
                    onTap: () => context.go(e.$2.path),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            // Scroll with mouse wheel/drag on web: the default behavior
            // excludes mouse from dragDevices; on 1366×768 laptops the
            // INSIGHTS items were unreachable. Scrollbar visible on overflow.
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: true,
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: ListView(
                primary: false,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: isExtended ? 12 : 8, vertical: 2),
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
                ],
              ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final logoColor = cs.primary;
    final userName = (user?.firstName as String?) ?? '';
    final userInitial = userName.isEmpty ? '?' : userName[0].toUpperCase();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isExtended ? 16 : 0,
        14,
        isExtended ? 16 : 0,
        8,
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.sidebarLogoText(context),
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
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Hola, $userName',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.sidebarMutedFg(context),
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
                NotificationBell(
                  iconColor: AppTheme.sidebarMutedFg(context),
                  hoverColor: AppTheme.sidebarHoverBg(context),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: logoColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(LucideIcons.landmark, size: 17, color: cs.onPrimary),
                ),
                const SizedBox(height: 8),
                NotificationBell(
                  iconColor: AppTheme.sidebarMutedFg(context),
                  hoverColor: AppTheme.sidebarHoverBg(context),
                ),
              ],
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
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Text(
        text,
        style: AppTheme.quietLabel(context, color: AppTheme.sidebarMutedFg(context)),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dest = widget.dest;
    final selected = widget.selected;
    final isExtended = widget.isExtended;
    final mutedFg = AppTheme.sidebarMutedFg(context);
    final iconColor = selected ? cs.primary : mutedFg;
    final labelColor = selected ? AppTheme.sidebarLogoText(context) : mutedFg;
    final bg = selected ? AppTheme.tintBgStrong(context, cs.primary) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        // Extended: this Material paints the selection pill (full row).
        // Collapsed: the inner Container (icon box) below paints it instead —
        // painting it here too would duplicate the same color twice.
        color: isExtended ? bg : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          onFocusChange: (v) => setState(() => _focused = v),
          borderRadius: BorderRadius.circular(12),
          splashFactory: NoSplash.splashFactory,
          hoverColor: AppTheme.sidebarHoverBg(context),
          child: FocusRing(
            focused: _focused,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 36,
              child: isExtended
                  ? Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(dest.icon, size: 17, color: iconColor),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            dest.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: labelColor,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
                      // The real 48dp tap target is given by the InkWell/Material
                      // wrapping the whole row (SizedBox height 36 + padding);
                      // this 38x32 box is just the icon's visual highlight.
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
                      color: context.tokens.dangerText,
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

class _FooterTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _FooterTile({required this.icon, required this.label, this.color, required this.onTap});

  @override
  State<_FooterTile> createState() => _FooterTileState();
}

class _FooterTileState extends State<_FooterTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.color ?? AppTheme.sidebarMutedFg(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: (v) => setState(() => _focused = v),
        borderRadius: BorderRadius.circular(6),
        splashFactory: NoSplash.splashFactory,
        hoverColor: AppTheme.sidebarHoverBg(context),
        child: FocusRing(
          focused: _focused,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                Icon(widget.icon, size: 14, color: c),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelMedium?.copyWith(
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
      ),
    );
  }
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color? color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.tooltip, this.color, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: widget.onTap,
          onFocusChange: (v) => setState(() => _focused = v),
          borderRadius: BorderRadius.circular(6),
          splashFactory: NoSplash.splashFactory,
          hoverColor: AppTheme.sidebarHoverBg(context),
          child: FocusRing(
            focused: _focused,
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 40,
              height: 36,
              child: Icon(widget.icon, size: 17, color: widget.color ?? AppTheme.sidebarMutedFg(context)),
            ),
          ),
        ),
      ),
    );
  }
}

enum _NavSection { main, assistant }

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = ref.watch(authProvider).value;
    final initials = _initialsFor(user?.firstName, user?.lastName);
    final avatarUrl = user?.avatarUrl;

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
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        const NotificationBell(),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showAccountSheet(context, ref, t),
            child: _AccountAvatar(url: avatarUrl, initials: initials, size: 38),
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

/// Account avatar (photo or initials) — a single widget shared between the
/// mobile appbar and the account sheet header, previously duplicated with
/// different radii (circle 20 vs corner 14 for the same box size).
class _AccountAvatar extends StatelessWidget {
  final String? url;
  final String initials;
  final double size;

  const _AccountAvatar({required this.url, required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(size / 2);

    return NetworkImageThumb(
      url: url,
      size: size,
      borderRadius: radius,
      fallback: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.tintBg(context, cs.primary),
          borderRadius: radius,
          border: Border.all(color: AppTheme.borderSubtle(context)),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

void _showAccountSheet(BuildContext context, WidgetRef ref, Translations t) {
  showModalBottomSheet<void>(
    context: context,
    // No fixed backgroundColor: it resolves from the theme on every build, so
    // the sheet re-themes if the user toggles light/dark while it's open.
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
      child: SingleChildScrollView(
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
                    _AccountAvatar(
                      url: user.avatarUrl,
                      initials: _MobileAppBar._initialsFor(user.firstName, user.lastName),
                      size: 44,
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
            Container(height: 1, color: AppTheme.borderSubtle(context)),
            const SizedBox(height: 8),
            _SheetTile(
              icon: LucideIcons.sparkles,
              label: 'Chat IA',
              onTap: () {
                Navigator.pop(context);
                context.go('/ai-chat');
              },
            ),
            _SheetTile(
              icon: LucideIcons.scan,
              label: 'Escanear recibo',
              onTap: () {
                Navigator.pop(context);
                context.go('/ai-scan');
              },
            ),
            _SheetTile(
              icon: LucideIcons.trendingUp,
              label: 'Pronóstico',
              onTap: () {
                Navigator.pop(context);
                context.go('/ai-forecast');
              },
            ),
            const SizedBox(height: 8),
            Container(height: 1, color: AppTheme.borderSubtle(context)),
            const SizedBox(height: 8),
            _SheetTile(
              icon: LucideIcons.shoppingCart,
              label: t.purchases,
              onTap: () {
                Navigator.pop(context);
                context.go('/purchases');
              },
            ),
            _SheetTile(
              icon: LucideIcons.walletMinimal,
              label: t.expenses,
              onTap: () {
                Navigator.pop(context);
                context.go('/expenses');
              },
            ),
            _SheetTile(
              icon: LucideIcons.chartColumn,
              label: t.reports,
              onTap: () {
                Navigator.pop(context);
                context.go('/reports');
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

class _SheetTile extends StatefulWidget {
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
  State<_SheetTile> createState() => _SheetTileState();
}

class _SheetTileState extends State<_SheetTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final destructive = widget.destructive;
    final color = destructive ? AppTheme.danger : cs.onSurface;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: (v) => setState(() => _focused = v),
        borderRadius: BorderRadius.circular(10),
        splashFactory: NoSplash.splashFactory,
        hoverColor: cs.surfaceContainerHigh,
        child: FocusRing(
          focused: _focused,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            // Vertical 14 + ~20 line height ≈ 48dp tap target, without
            // needing the containing icon box (pattern from _auth_panel.dart).
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Row(
              children: [
                Icon(widget.icon, size: 18, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: color,
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
      ),
    );
  }
}

// ── Custom bottom tab bar (replaces the generic NavigationBar) ──────────────

/// Minimalist Notion/Linear-style bottom tab bar.
///
/// Doesn't use visible labels — just icons with a pill indicator below the
/// active one. Cleaner than Material's NavigationBar, which screams "Flutter app".
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

class _BottomTabItem extends StatefulWidget {
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
  State<_BottomTabItem> createState() => _BottomTabItemState();
}

class _BottomTabItemState extends State<_BottomTabItem> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final selected = widget.selected;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: (v) => setState(() => _focused = v),
        splashFactory: NoSplash.splashFactory,
        hoverColor: cs.surfaceContainerHigh,
        child: FocusRing(
          focused: _focused,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.tintBg(context, cs.primary) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, size: 22, color: color),
              ),
              const SizedBox(height: 2),
              // Label always visible: previously only the active tab showed
              // it, which made the icon jump vertically when switching tabs.
              Text(
                widget.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
