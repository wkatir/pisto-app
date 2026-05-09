import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../i18n/translations.g.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    return Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: isWide ? 72 : 64)),
                SliverToBoxAdapter(child: _HeroSection(isWide: isWide)),
                SliverToBoxAdapter(child: _MetricsBar(isWide: isWide)),
                SliverToBoxAdapter(child: _FeaturesSection(isWide: isWide)),
                SliverToBoxAdapter(child: _TestimonialsSection(isWide: isWide)),
                SliverToBoxAdapter(child: _HowItWorksSection(isWide: isWide)),
                SliverToBoxAdapter(child: _CtaSection(isWide: isWide)),
                SliverToBoxAdapter(child: _Footer(isWide: isWide)),
              ],
            ),
            _TopBar(isWide: isWide, isScrolled: _scrollOffset > 20),
          ],
        ),
    );
  }
}

// ── TopBar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool isWide;
  final bool isScrolled;

  const _TopBar({required this.isWide, required this.isScrolled});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 20, vertical: 14),
      decoration: BoxDecoration(
        color: isScrolled
            ? cs.surface.withValues(alpha: 0.92)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isScrolled
                ? Theme.of(context).colorScheme.outlineVariant
                : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.landmark, size: 16, color: cs.onPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pisto',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isWide) ...[
              TextButton(
                onPressed: () {},
                child: Text(
                  t.features,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  t.pricing,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                t.login,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => context.go('/register'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(t.signUp),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final bool isWide;

  const _HeroSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Hecho para PYMES de Centroamérica',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);

    final headline = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Text(
        t.controlYourBusiness,
        style: AppTheme.serif(
          fontSize: isWide ? 56 : 40,
          fontWeight: FontWeight.w600,
          height: 1.05,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: -1.5,
        ),
        textAlign: isWide ? TextAlign.start : TextAlign.center,
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 80.ms);

    final subtext = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Text(
        t.everythingNeeded,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.65,
        ),
        textAlign: isWide ? TextAlign.start : TextAlign.center,
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 160.ms);

    final ctas = Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: () => context.go('/register'),
          icon: const Icon(LucideIcons.arrowRight, size: 16),
          label: Text(t.startFree),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          child: Text(t.viewDemo),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 240.ms);

    // Bullets honestos en lugar de avatares falsos
    final bullets = ['Sin tarjeta de crédito', 'Configurás en 5 minutos', 'Soporte en español'];
    final socialProof = Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
      children: bullets.map((b) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.check, size: 14, color: AppTheme.success),
              const SizedBox(width: 5),
              Text(
                b,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )).toList(),
    ).animate().fadeIn(duration: 400.ms, delay: 320.ms);

    final content = Column(
      crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(height: 24),
        headline,
        const SizedBox(height: 20),
        subtext,
        const SizedBox(height: 32),
        ctas,
        const SizedBox(height: 20),
        socialProof,
      ],
    );

    final mockup = _DashboardMockup(cs: cs, theme: theme)
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 64 : 24,
        vertical: isWide ? 80 : 48,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: content),
                const SizedBox(width: 64),
                Expanded(flex: 6, child: mockup),
              ],
            )
          : Column(
              children: [
                content,
                const SizedBox(height: 48),
                mockup,
              ],
            ),
    );
  }
}

class _DashboardMockup extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;

  const _DashboardMockup({required this.cs, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 400),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Browser bar
            _MockBrowserBar(),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Text(
                          'Dashboard',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Este mes',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onPrimary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // KPI cards row
                    Row(
                      children: [
                        _MockKpiCard(
                          label: 'Ventas',
                          value: '\$24,500',
                          trend: '+12%',
                          positive: true,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 8),
                        _MockKpiCard(
                          label: 'Cobros',
                          value: '\$8,200',
                          trend: '+5%',
                          positive: true,
                          color: AppTheme.positive,
                        ),
                        const SizedBox(width: 8),
                        _MockKpiCard(
                          label: 'Por cobrar',
                          value: '\$3,400',
                          trend: '-2%',
                          positive: false,
                          color: AppTheme.chartAmber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Chart area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Tendencia de ventas',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 10,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Últimos 30 días',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _ChartPainter(color: cs.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockBrowserBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // Dots
          ...List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: [
                  AppTheme.danger,
                  AppTheme.warning,
                  AppTheme.success,
                ][i],
              ),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 22,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              alignment: Alignment.center,
              child: Text(
                'app.pistoapp.com/dashboard',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool positive;
  final Color color;

  const _MockKpiCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.positive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = positive ? AppTheme.positive : AppTheme.negative;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              trend,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: trendColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color color;
  _ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final points = [0.75, 0.6, 0.65, 0.45, 0.5, 0.3, 0.38, 0.2, 0.28, 0.12];
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = size.width * (i - 1) / (points.length - 1);
        final prevY = size.height * points[i - 1];
        final cx = (prevX + x) / 2;
        path.cubicTo(cx, prevY, cx, y, x, y);
        fillPath.cubicTo(cx, prevY, cx, y, x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.color != color;
}

// ── Metrics bar (datos concretos en lugar de logos placeholder) ──────────────

class _MetricsBar extends StatelessWidget {
  final bool isWide;

  const _MetricsBar({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final metrics = [
      ('Inventario', 'En tiempo real'),
      ('Facturas', 'Listas en segundos'),
      ('Cobros', 'Sin perder de vista'),
      ('Reportes', 'Decisiones con datos'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 28),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.symmetric(
          horizontal: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRow = constraints.maxWidth > Breakpoints.gridDense;
          final children = metrics.map((m) {
            return Padding(
              padding: useRow ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: useRow ? CrossAxisAlignment.center : CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    m.$1,
                    style: AppTheme.serif(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.$2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }).toList();

          if (useRow) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: children.map((c) => Expanded(child: c)).toList(),
            );
          }
          return Column(children: children);
        },
      ),
    );
  }
}

// ── Features ─────────────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  final bool isWide;

  const _FeaturesSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final features = [
      _FeatureData(LucideIcons.package, t.inventario, t.inventarioDesc, cs.primary),
      _FeatureData(LucideIcons.receipt, t.ventas, t.ventasDesc, AppTheme.positive),
      _FeatureData(LucideIcons.shoppingCart, t.compras, t.comprasDesc, AppTheme.chartAmber),
      _FeatureData(LucideIcons.wallet, t.cobranza, t.cobranzaDesc, cs.tertiary),
      _FeatureData(LucideIcons.chartColumn, t.reports, t.reportesDesc, AppTheme.chartViolet),
      _FeatureData(LucideIcons.download, t.exportacion, t.exportacionDesc, AppTheme.chartCoral),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 80),
      child: Column(
        children: [
          // Section label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Módulos',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            t.todoLoQueNecesitas,
            style: AppTheme.serif(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.7,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 80.ms),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              t.modulosDisenados,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 140.ms),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final crossCount = w > Breakpoints.gridSparse
                  ? 3
                  : w > Breakpoints.formStack + 20
                      ? 2
                      : 1;
              const gap = 12.0;
              final cardWidth = (w - gap * (crossCount - 1)) / crossCount;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: List.generate(features.length, (i) {
                  final f = features[i];
                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: f.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(f.icon, size: 20, color: f.color),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            f.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            f.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (i * 60).ms),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _FeatureData(this.icon, this.title, this.description, this.color);
}

// ── Testimonios ───────────────────────────────────────────────────────────────

class _TestimonialsSection extends StatelessWidget {
  final bool isWide;

  const _TestimonialsSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    final testimonials = [
      _Testimonial(
        quote: 'Antes usábamos Excel para todo y perdíamos horas. Pisto nos organizó en una semana.',
        name: 'Carlos Mendoza',
        role: 'Gerente General',
        company: 'DistribCA',
        initial: 'C',
        color: cs.primary,
      ),
      _Testimonial(
        quote: 'El módulo de cobros nos ayudó a reducir la cartera vencida en un 40% el primer mes.',
        name: 'María Alvarado',
        role: 'Directora Financiera',
        company: 'AgroMax S.A.',
        initial: 'M',
        color: AppTheme.positive,
      ),
      _Testimonial(
        quote: 'Lo mejor es que se ve profesional. Mis clientes confían más en las facturas que genera.',
        name: 'Luis Torres',
        role: 'Dueño',
        company: 'FreshMart',
        initial: 'L',
        color: AppTheme.chartAmber,
      ),
    ];

    return Container(
      color: cs.surfaceContainer,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 80),
      child: Column(
        children: [
          Text(
            'Casos reales de quienes ya usan Pisto',
            style: AppTheme.serif(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.6,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final useRow = constraints.maxWidth > Breakpoints.gridDense;
              if (useRow) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: testimonials
                      .asMap()
                      .entries
                      .map((e) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: e.key < testimonials.length - 1 ? 16 : 0,
                              ),
                              child: _TestimonialCard(data: e.value, theme: theme)
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: (e.key * 80).ms),
                            ),
                          ))
                      .toList(),
                );
              }
              return Column(
                children: testimonials
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: EdgeInsets.only(
                            bottom: e.key < testimonials.length - 1 ? 16 : 0,
                          ),
                          child: _TestimonialCard(data: e.value, theme: theme)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: (e.key * 80).ms),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Testimonial {
  final String quote;
  final String name;
  final String role;
  final String company;
  final String initial;
  final Color color;
  const _Testimonial({
    required this.quote,
    required this.name,
    required this.role,
    required this.company,
    required this.initial,
    required this.color,
  });
}

class _TestimonialCard extends StatelessWidget {
  final _Testimonial data;
  final ThemeData theme;

  const _TestimonialCard({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.only(right: 2),
                child: Icon(LucideIcons.star, size: 12, color: AppTheme.warning),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '"${data.quote}"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    data.initial,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${data.role} · ${data.company}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── How It Works ─────────────────────────────────────────────────────────────

class _HowItWorksSection extends StatelessWidget {
  final bool isWide;

  const _HowItWorksSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final steps = [
      (LucideIcons.userPlus, t.creaTuCuenta, t.registrateGratis),
      (LucideIcons.settings, t.configuraTuNegocio, t.agregaProductosClientes),
      (LucideIcons.rocket, t.empiezaAVender, t.facturaCobraCompra),
    ];

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 80),
      child: Column(
        children: [
          Text(
            t.empiezaEn3Pasos,
            style: AppTheme.serif(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.6,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final useRow = constraints.maxWidth > Breakpoints.gridDense;

              final items = steps.asMap().entries.map((entry) {
                final i = entry.key;
                final (icon, title, desc) = entry.value;
                return Padding(
                    padding: EdgeInsets.symmetric(horizontal: useRow ? 12 : 0),
                    child: Column(
                      crossAxisAlignment: useRow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: useRow ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, size: 22, color: cs.onPrimary),
                            ),
                            if (!useRow) ...[
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Paso ${i + 1}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (useRow)
                          Text(
                            'Paso ${i + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (useRow) const SizedBox(height: 4),
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: useRow ? TextAlign.center : TextAlign.start,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          desc,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.55,
                          ),
                          textAlign: useRow ? TextAlign.center : TextAlign.start,
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: (i * 80).ms),
                );
              }).toList();

              if (useRow) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((w) => Expanded(child: w)).toList(),
                );
              }
              return Column(
                children: items
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: EdgeInsets.only(bottom: e.key < items.length - 1 ? 32 : 0),
                          child: e.value,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── CTA ──────────────────────────────────────────────────────────────────────

class _CtaSection extends StatelessWidget {
  final bool isWide;

  const _CtaSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 64),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 64 : 32,
          vertical: isWide ? 56 : 40,
        ),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              t.listoParaTomarControl,
              style: AppTheme.serif(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: cs.onPrimary,
                letterSpacing: -0.7,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(
                t.uneteEmpresas,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onPrimary.withValues(alpha: 0.75),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/register'),
                  icon: const Icon(LucideIcons.arrowRight, size: 16),
                  label: Text(t.crearCuentaGratis),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.onPrimary,
                    foregroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final bool isWide;

  const _Footer({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 40),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        const SizedBox(width: 8),
                        Text(
                          'Pisto',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.financialManagementSystem,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Links
                _FooterColumn('Producto', ['Inventario', 'Ventas', 'Cobros', 'Reportes'], theme),
                const SizedBox(width: 48),
                _FooterColumn('Empresa', ['Acerca de', 'Blog', 'Contacto'], theme),
                const SizedBox(width: 48),
                _FooterColumn('Legal', ['Privacidad', 'Términos', 'Cookies'], theme),
              ],
            )
          : Column(
              children: [
                Row(
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
                    const SizedBox(width: 8),
                    Text(
                      'Pisto',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  t.allRightsReserved,
                  style: theme.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  final ThemeData theme;

  const _FooterColumn(this.title, this.links, this.theme);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                link,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )),
      ],
    );
  }
}
