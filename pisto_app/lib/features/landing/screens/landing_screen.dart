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
              SliverToBoxAdapter(child: _StatsBar(isWide: isWide)),
              SliverToBoxAdapter(child: _FeaturesSection(isWide: isWide)),
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
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 20, vertical: 12),
      decoration: BoxDecoration(
        color: isScrolled ? cs.surface.withValues(alpha: 0.95) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isScrolled ? cs.outlineVariant.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.landmark, size: 18, color: cs.onPrimary),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('Pisto', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary), maxLines: 1, overflow: TextOverflow.ellipsis)),
            OutlinedButton(
              onPressed: () => context.go('/login'),
              child: Text(t.login),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => context.go('/register'),
              child: Text(t.signUp),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isWide;

  const _HeroSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final content = Column(
      crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            t.managementForSMEs,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideY(begin: -0.2),
        const SizedBox(height: 20),
        Text(
          t.controlYourBusiness,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          textAlign: isWide ? TextAlign.start : TextAlign.center,
        ).animate().fadeIn(duration: const Duration(milliseconds: 500), delay: const Duration(milliseconds: 100)).slideY(begin: 0.1),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            t.everythingNeeded,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: isWide ? TextAlign.start : TextAlign.center,
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 500), delay: const Duration(milliseconds: 200)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => context.go('/register'),
              icon: const Icon(LucideIcons.arrowRight, size: 18),
              label: Text(t.startFree),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(LucideIcons.play, size: 18),
              label: Text(t.viewDemo),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            ),
          ],
        ).animate().fadeIn(duration: const Duration(milliseconds: 500), delay: const Duration(milliseconds: 300)).slideY(begin: 0.2),
      ],
    );

    final mockup = Container(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 360),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        color: cs.surfaceContainerLow,
        boxShadow: [
          BoxShadow(color: cs.shadow.withValues(alpha: 0.08), blurRadius: 40, offset: const Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  ...List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: [cs.error, cs.tertiary, cs.secondary][i].withValues(alpha: 0.6),
                      ),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text('pistoapp.com/dashboard', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: cs.onSurfaceVariant)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.dashboard, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MockKpi(cs: cs, theme: theme, label: t.sales, value: '\$12,450', color: cs.primary),
                        const SizedBox(width: 8),
                        _MockKpi(cs: cs, theme: theme, label: t.accountsReceivable, value: '\$3,200', color: cs.tertiary),
                        const SizedBox(width: 8),
                        _MockKpi(cs: cs, theme: theme, label: t.lowStock, value: '5', color: cs.error),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sales Trend', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 10)),
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
    ).animate().fadeIn(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 200)).slideX(begin: 0.1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: isWide ? 64 : 40),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: content),
                const SizedBox(width: 48),
                Expanded(child: mockup),
              ],
            )
          : Column(
              children: [
                content,
                const SizedBox(height: 40),
                mockup,
              ],
            ),
    );
  }
}

class _MockKpi extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  final String label;
  final String value;
  final Color color;

  const _MockKpi({required this.cs, required this.theme, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 9, color: cs.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
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
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final points = [0.7, 0.5, 0.6, 0.3, 0.45, 0.2, 0.35, 0.15, 0.25, 0.1];
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatsBar extends StatelessWidget {
  final bool isWide;

  const _StatsBar({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final stats = [
      ('500+', t.empresasActivas),
      ('50,000+', t.facturasProcesadas),
      ('99.9%', t.uptimeGarantedizado),
      ('24/7', t.soporteTecnico),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: 32),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border.symmetric(
          horizontal: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: Wrap(
        spacing: 32,
        runSpacing: 20,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < stats.length; i++)
            SizedBox(
              width: isWide ? null : (MediaQuery.of(context).size.width - 80) / 2,
              child: Column(
                children: [
                  Text(stats[i].$1, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.primary)),
                  const SizedBox(height: 4),
                  Text(stats[i].$2, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 400), delay: Duration(milliseconds: 100 * i)),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final bool isWide;

  const _FeaturesSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final features = [
      _Feature(LucideIcons.package, t.inventario, t.inventarioDesc, cs.primary),
      _Feature(LucideIcons.receipt, t.ventas, t.ventasDesc, cs.secondary),
      _Feature(LucideIcons.shoppingCart, t.compras, t.comprasDesc, AppTheme.chartOrange),
      _Feature(LucideIcons.wallet, t.cobranza, t.cobranzaDesc, cs.tertiary),
      _Feature(LucideIcons.barChart3, t.reports, t.reportesDesc, AppTheme.chartPurple),
      _Feature(LucideIcons.download, t.exportacion, t.exportacionDesc, cs.error),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: 64),
      child: Column(
        children: [
          Text(
            t.todoLoQueNecesitas,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
          const SizedBox(height: 8),
          Text(
            t.modulosDisenados,
            style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: const Duration(milliseconds: 400), delay: const Duration(milliseconds: 100)),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 190,
                ),
                itemCount: features.length,
                itemBuilder: (context, i) {
                  final f = features[i];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: f.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(f.icon, size: 22, color: f.color),
                          ),
                          const SizedBox(height: 16),
                          Text(f.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              f.description,
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 400), delay: Duration(milliseconds: 80 * i)).slideY(begin: 0.1);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _Feature(this.icon, this.title, this.description, this.color);
}

class _HowItWorksSection extends StatelessWidget {
  final bool isWide;

  const _HowItWorksSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final steps = [
      ('1', LucideIcons.userPlus, t.creaTuCuenta, t.registrateGratis),
      ('2', LucideIcons.settings, t.configuraTuNegocio, t.agregaProductosClientes),
      ('3', LucideIcons.rocket, t.empiezaAVender, t.facturaCobraCompra),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: 64),
      color: cs.surfaceContainerLow,
      child: Column(
        children: [
          Text(
            t.empiezaEn3Pasos,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final useRow = constraints.maxWidth > 700;
              final items = steps.asMap().entries.map((entry) {
                final (num, icon, title, desc) = entry.value;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, size: 24, color: cs.onPrimary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.step(number: num),
                          style: theme.textTheme.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                        const SizedBox(height: 4),
                        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(desc, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.5), textAlign: TextAlign.center),
                      ],
                    ),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 400), delay: Duration(milliseconds: 150 * entry.key)).slideY(begin: 0.15),
                );
              }).toList();

              if (useRow) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: items);
              return Column(
                children: steps.asMap().entries.map((entry) {
                  final (num, icon, title, desc) = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(14)),
                          child: Icon(icon, size: 22, color: cs.onPrimary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${t.step(number: num)} · $title', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(desc, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 400), delay: Duration(milliseconds: 150 * entry.key));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  final bool isWide;

  const _CtaSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: 64),
      child: Container(
        padding: EdgeInsets.all(isWide ? 48 : 32),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              t.listoParaTomarControl,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.onPrimaryContainer),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              t.uneteEmpresas,
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/register'),
              icon: const Icon(LucideIcons.arrowRight, size: 18),
              label: Text(t.crearCuentaGratis),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18)),
            ),
          ],
        ),
      ).animate().fadeIn(duration: const Duration(milliseconds: 500)).scale(begin: const Offset(0.97, 0.97)),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool isWide;

  const _Footer({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 24, vertical: 32),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(8)),
                child: Icon(LucideIcons.landmark, size: 16, color: cs.onPrimary),
              ),
              const SizedBox(width: 8),
              Text('Pisto', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
              const SizedBox(width: 4),
              Text(t.financialManagementSystem, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            t.allRightsReserved,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
