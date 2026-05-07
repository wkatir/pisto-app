import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';

class AuthSplitLayout extends StatelessWidget {
  final Widget form;

  const AuthSplitLayout({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 720;

    return Theme(
      data: AppTheme.light,
      child: !isWide
          ? Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MobileLogo(),
                          const SizedBox(height: 32),
                          form,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Scaffold(
              backgroundColor: Colors.white,
              body: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _BrandPanel(),
                  ),
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: form,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MobileLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(LucideIcons.landmark, size: 24, color: cs.onPrimary),
        ),
        const SizedBox(height: 10),
        Text(
          'Pisto',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final features = [
      (LucideIcons.package, 'Inventario en tiempo real', 'Control de stock, alertas y movimientos'),
      (LucideIcons.receipt, 'Facturación rápida', 'Emite facturas y cobra en segundos'),
      (LucideIcons.chartColumn, 'Reportes financieros', 'KPIs, tendencias y márgenes de utilidad'),
      (LucideIcons.wallet, 'Cobranza inteligente', 'Antigüedad de cartera y seguimiento de pagos'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
      ),
      child: LayoutBuilder(
        builder: (context, viewport) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight - 112),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(LucideIcons.landmark, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Pisto',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Tu negocio,\nbajo control.',
                      style: AppTheme.serif(
                        fontSize: 44,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Facturá, cobrá y controlá tu inventario\ndesde un solo lugar — sin Excel ni desorden.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ...features.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(f.$1, size: 17, color: Colors.white),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.$2,
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      f.$3,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"Reducimos la cartera vencida en 40% el primer mes."',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'María Alvarado · Directora Financiera, AgroMax',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
