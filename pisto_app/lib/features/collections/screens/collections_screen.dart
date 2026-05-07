import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _receivables = [];
  List<dynamic> _aging = [];
  bool _loading = true;

  final _fmt = currencyFmt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final svc = ref.read(collectionsServiceProvider);
      final results = await Future.wait([
        svc.listReceivables(),
        svc.getAgingReport(),
      ]);
      setState(() {
        _receivables = ((results[0] as Map<String, dynamic>)['data'] as List<dynamic>?) ?? [];
        _aging = (results[1] as List<dynamic>?) ?? [];
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.parseError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Icon(LucideIcons.wallet, size: 28, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(child: Text('Cobranza', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.fileText, size: 16), const SizedBox(width: 6), Text('Cuentas por Cobrar (${_receivables.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.clock, size: 16), const SizedBox(width: 6), const Text('Antiguedad')])),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const _CollectionsListSkeleton()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReceivablesTab(theme),
                      _buildAgingTab(theme),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Receivables Tab ──

  Widget _buildReceivablesTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_receivables.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleCheck, size: 48, color: cs.secondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('No hay cuentas pendientes', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _receivables.length,
      itemBuilder: (context, i) {
        final item = _receivables[i] as Map<String, dynamic>;
        final ar = item['receivable'] as Map<String, dynamic>? ?? item;
        final customerName = item['customerName'] ?? '';
        final saleNumber = item['saleNumber'] ?? '';
        final balance = double.tryParse(ar['balance']?.toString() ?? '0') ?? 0;
        final original = double.tryParse(ar['originalAmount']?.toString() ?? '0') ?? 0;
        final customerId = item['customerId']?.toString() ?? ar['customerId']?.toString();
        final phone = item['customerPhone']?.toString() ?? ar['customerPhone']?.toString();
        final dueDateRaw = ar['dueDate']?.toString();
        final dueDate = dueDateRaw != null ? DateTime.tryParse(dueDateRaw) : null;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 4, top: 6, bottom: 6),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.clock, size: 20, color: cs.tertiary),
            ),
            title: Text(customerName.isEmpty ? 'Sin cliente' : customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Row(
              children: [
                Icon(LucideIcons.fileText, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(child: Text(saleNumber, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Icon(LucideIcons.calendar, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(child: Text('${ar['dueDate'] ?? ''}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_fmt.format(balance), style: AppTheme.mono(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.negative), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('de ${_fmt.format(original)}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.messageCircle, size: 20, color: AppTheme.whatsappBrand),
                  tooltip: 'Enviar cobro por WhatsApp',
                  onPressed: () => _sendWhatsApp(context, phone, customerName.isEmpty ? 'Sin cliente' : customerName, 'Mi Negocio', balance, dueDate),
                ),
              ],
            ),
            onTap: () => _showReceivableDetail(context, ar, customerName, customerId),
          ),
        );
      },
    );
  }

  // ── Receivable Detail with Payment History ──

  void _showReceivableDetail(BuildContext context, Map<String, dynamic> ar, String customerName, String? customerId) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final balance = double.tryParse(ar['balance']?.toString() ?? '0') ?? 0;
    final original = double.tryParse(ar['originalAmount']?.toString() ?? '0') ?? 0;
    final receivableId = ar['id'] as String;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.clock, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(customerName.isEmpty ? 'Cuenta por Cobrar' : customerName, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _MonoDetailRow(theme: theme, label: 'Monto Original', amount: original, labelWidth: 120),
                _MonoDetailRow(theme: theme, label: 'Saldo', amount: balance, isNegative: true, labelWidth: 120),
                DetailRow(theme: theme, label: 'Vencimiento', value: ar['dueDate'] ?? '', labelWidth: 120),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(LucideIcons.history, size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Historial de Pagos', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<dynamic>>(
                  future: ref.read(collectionsServiceProvider).getReceivablePayments(receivableId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError) {
                      return Text('Error al cargar pagos', style: TextStyle(color: cs.error));
                    }
                    final payments = snapshot.data ?? [];
                    if (payments.isEmpty) {
                      return Text('Sin pagos registrados', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant));
                    }
                    return Column(
                      children: payments.map((p) {
                        final payment = p as Map<String, dynamic>;
                        final amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(LucideIcons.banknote, size: 14, color: cs.secondary),
                              const SizedBox(width: 6),
                              Expanded(child: Text(payment['paymentDate']?.toString().substring(0, 10) ?? '', style: theme.textTheme.bodySmall)),
                              Text(_fmt.format(amount), style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w600, color: cs.secondary)),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                if (customerId != null) ...[
                  const Divider(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCustomerStatement(context, customerId, customerName);
                      },
                      icon: const Icon(LucideIcons.fileChartColumn, size: 16),
                      label: const Text('Ver Estado de Cuenta'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          if (balance > 0)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showPaymentDialog(context, ar);
              },
              icon: const Icon(LucideIcons.banknote, size: 16),
              label: const Text('Registrar Abono'),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  // ── Customer Statement ──

  void _showCustomerStatement(BuildContext context, String customerId, String customerName) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.fileChartColumn, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('Estado de Cuenta', maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 450),
          child: FutureBuilder<Map<String, dynamic>>(
            future: ref.read(collectionsServiceProvider).getCustomerStatement(customerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar estado de cuenta', style: TextStyle(color: cs.error)));
              }
              final statement = snapshot.data ?? {};
              final totalBalance = double.tryParse(statement['totalBalance']?.toString() ?? '0') ?? 0;
              final entries = statement['entries'] as List<dynamic>? ?? statement['receivables'] as List<dynamic>? ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(customerName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.wallet, size: 20, color: cs.error),
                          const SizedBox(width: 8),
                          Text('Saldo Total:', style: theme.textTheme.bodyMedium),
                          const Spacer(),
                          Text(_fmt.format(totalBalance), style: AppTheme.mono(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.negative)),
                        ],
                      ),
                    ),
                    if (entries.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Detalle', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...entries.map((e) {
                        final entry = e as Map<String, dynamic>;
                        final entryBalance = double.tryParse(entry['balance']?.toString() ?? '0') ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry['saleNumber'] ?? '', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                                    Text('Vence: ${entry['dueDate'] ?? ''}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text(_fmt.format(entryBalance), style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.negative)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  // ── Aging Tab ──

  Widget _buildAgingTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_aging.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.clock, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('Sin datos de antiguedad', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    final agingColors = [cs.secondary, cs.primary, cs.tertiary, AppTheme.chartAmber, cs.error];

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _aging.length,
      itemBuilder: (context, i) {
        final row = _aging[i] as Map<String, dynamic>;
        final color = agingColors[i % agingColors.length];
        final total = double.tryParse(row['total']?.toString() ?? '0') ?? 0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_agingLabel(row['range']?.toString() ?? ''), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text('${row['count'] ?? 0} cuentas', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(_fmt.format(total), style: AppTheme.mono(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _agingLabel(String range) {
    return switch (range) {
      'current' => 'Vigente',
      '1-30' => '1-30 dias',
      '31-60' => '31-60 dias',
      '61-90' => '61-90 dias',
      '90+' => '90+ dias',
      _ => range,
    };
  }

  // ── WhatsApp Cobro ──

  void _sendWhatsApp(BuildContext context, String? phone, String customerName, String businessName, double amount, DateTime? dueDate) {
    if (phone == null || phone.isEmpty) {
      final phoneCtrl = TextEditingController();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Número de WhatsApp'),
          content: TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Teléfono (ej: +50312345678)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (phoneCtrl.text.isNotEmpty) {
                  _sendWhatsApp(context, phoneCtrl.text, customerName, businessName, amount, dueDate);
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      );
      return;
    }

    final dueDateStr = dueDate != null
        ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
        : 'pendiente';
    final amountStr = '\$${amount.toStringAsFixed(2)}';
    final message = Uri.encodeComponent(
      'Hola $customerName, le saludamos de $businessName.\n'
      'Le recordamos que tiene un saldo pendiente de $amountStr con fecha de vencimiento $dueDateStr.\n'
      'Puede contactarnos para coordinar su pago.\n¡Gracias!',
    );

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('WhatsApp: $url'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  // ── Payment Dialog ──

  void _showPaymentDialog(BuildContext context, Map<String, dynamic> ar) {
    final amountCtrl = TextEditingController(text: ar['balance']?.toString() ?? '');
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.banknote, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            const Text('Registrar Abono'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.wallet, size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Flexible(child: Text('Saldo: ${_fmt.format(double.tryParse(ar['balance']?.toString() ?? '0') ?? 0)}',
                        style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Monto', border: OutlineInputBorder(), prefixText: '\$ '),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(collectionsServiceProvider).createPayment(
                  ar['id'] as String,
                  {'paymentMethodId': 1, 'amount': amountCtrl.text},
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }
}

// ── Private helper widget ──────────────────────────────────────────────────

class _MonoDetailRow extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final double amount;
  final double labelWidth;
  final bool isNegative;

  const _MonoDetailRow({
    required this.theme,
    required this.label,
    required this.amount,
    this.labelWidth = 120,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(
              currencyFmt.format(amount),
              style: AppTheme.mono(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isNegative ? AppTheme.negative : null,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _CollectionsSkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _CollectionsSkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 700.ms, curve: Curves.easeIn)
        .fadeOut(delay: 700.ms, duration: 700.ms, curve: Curves.easeOut);
  }
}

class _CollectionsListSkeleton extends StatelessWidget {
  const _CollectionsListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 7,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            _CollectionsSkeletonBox(width: 40, height: 40, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CollectionsSkeletonBox(width: 120 + (i % 3) * 20.0, height: 14),
                  const SizedBox(height: 6),
                  _CollectionsSkeletonBox(width: 80 + (i % 2) * 30.0, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _CollectionsSkeletonBox(width: 72, height: 14),
                SizedBox(height: 4),
                _CollectionsSkeletonBox(width: 52, height: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
