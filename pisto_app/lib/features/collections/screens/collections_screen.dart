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
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;

    final totalPending = _receivables.fold<double>(0, (sum, r) {
      final ar = (r as Map<String, dynamic>)['receivable'] as Map<String, dynamic>? ?? r;
      return sum + (double.tryParse(ar['balance']?.toString() ?? '0') ?? 0);
    });

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: PageHeader(
              eyebrow: 'OPERACIÓN',
              title: 'Te deben',
              meta: '${_receivables.length} cuenta${_receivables.length == 1 ? '' : 's'} pendiente${_receivables.length == 1 ? '' : 's'}'
                  '${totalPending > 0 ? ' · ${_fmt.format(totalPending)} por cobrar' : ''}',
              metaIsMono: true,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Cuentas por cobrar (${_receivables.length})'),
                const Tab(text: 'Antigüedad'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const _CollectionsListSkeleton()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReceivablesTab(theme, isWide),
                      _buildAgingTab(theme, isWide),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Receivables Tab ──

  Widget _buildReceivablesTab(ThemeData theme, bool isWide) {
    if (_receivables.isEmpty) {
      return EmptyState(
        icon: LucideIcons.circleCheck,
        title: 'Todo cobrado',
        description: 'No hay cuentas pendientes. Cuando emitas una factura a crédito aparecerá acá hasta que se pague.',
      );
    }

    final padX = isWide ? 32.0 : 20.0;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      itemCount: _receivables.length,
      itemBuilder: (context, i) {
        final item = _receivables[i] as Map<String, dynamic>;
        final ar = item['receivable'] as Map<String, dynamic>? ?? item;
        final customerName = (item['customerName'] ?? '') as String;
        final saleNumber = (item['saleNumber'] ?? '') as String;
        final balance = double.tryParse(ar['balance']?.toString() ?? '0') ?? 0;
        final original = double.tryParse(ar['originalAmount']?.toString() ?? '0') ?? 0;
        final customerId = item['customerId']?.toString() ?? ar['customerId']?.toString();
        final phone = item['customerPhone']?.toString() ?? ar['customerPhone']?.toString();
        final dueDateRaw = ar['dueDate']?.toString();
        final dueDate = dueDateRaw != null ? DateTime.tryParse(dueDateRaw) : null;
        final overdue = dueDate != null && dueDate.isBefore(DateTime.now());

        return FinancialListRow(
          leading: RowAvatar(
            text: customerName.isEmpty ? '?' : customerName,
            color: overdue ? AppTheme.danger : AppTheme.warning,
          ),
          title: customerName.isEmpty ? 'Sin cliente' : customerName,
          subtitleParts: [
            if (saleNumber.isNotEmpty) saleNumber,
            if (dueDate != null) 'Vence ${formatDateShortEs(dueDateRaw)}',
          ],
          chips: [
            if (overdue)
              IntentChip(label: 'Vencida', intent: ChipIntent.danger, small: true)
            else
              IntentChip(label: 'Pendiente', intent: ChipIntent.warning, small: true),
          ],
          trailingValue: _fmt.format(balance),
          trailingColor: overdue ? AppTheme.danger : AppTheme.warning,
          trailingSubtitle: original > balance ? 'de ${_fmt.format(original)}' : null,
          onTap: () => _showReceivableDetail(
            context,
            ar,
            customerName,
            customerId,
            phone: phone,
            dueDate: dueDate,
          ),
        );
      },
    );
  }

  // ── Receivable Detail with Payment History ──

  void _showReceivableDetail(
    BuildContext context,
    Map<String, dynamic> ar,
    String customerName,
    String? customerId, {
    String? phone,
    DateTime? dueDate,
  }) {
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
                DetailRow(theme: theme, label: 'Vencimiento', value: formatDateDisplay(ar['dueDate']?.toString()), labelWidth: 120),
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
                              Expanded(child: Text(formatDateDisplay(payment['paymentDate']?.toString()), style: theme.textTheme.bodySmall)),
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
          if (balance > 0) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _sendWhatsApp(
                  context,
                  phone,
                  customerName.isEmpty ? 'Cliente' : customerName,
                  'Mi Negocio',
                  balance,
                  dueDate,
                );
              },
              icon: const Icon(LucideIcons.messageCircle, size: 16, color: AppTheme.whatsappBrand),
              label: const Text('WhatsApp'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.whatsappBrand,
                side: BorderSide(color: AppTheme.whatsappBrand.withValues(alpha: 0.5)),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showPaymentDialog(context, ar);
              },
              icon: const Icon(LucideIcons.banknote, size: 16),
              label: const Text('Registrar abono'),
            ),
          ],
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
                                    Text('Vence ${formatDateShortEs(entry['dueDate']?.toString())}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11)),
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

  Widget _buildAgingTab(ThemeData theme, bool isWide) {
    final cs = theme.colorScheme;
    final padX = isWide ? 32.0 : 20.0;

    if (_aging.isEmpty) {
      return EmptyState(
        icon: LucideIcons.clock,
        title: 'Sin datos de antigüedad',
        description: 'Cuando tengas cuentas pendientes, acá vas a ver cuánto debe cada cliente y desde cuándo.',
      );
    }

    // Mapeo a intent semántico por rango — más vencido = más severo.
    Color colorForRange(String range) => switch (range) {
          'current' => AppTheme.success,
          '1-30' => AppTheme.info,
          '31-60' => AppTheme.warning,
          '61-90' => AppTheme.accent,
          '90+' => AppTheme.danger,
          _ => cs.onSurfaceVariant,
        };

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      itemCount: _aging.length,
      itemBuilder: (context, i) {
        final row = _aging[i] as Map<String, dynamic>;
        final range = row['range']?.toString() ?? '';
        final color = colorForRange(range);
        final total = double.tryParse(row['total']?.toString() ?? '0') ?? 0;
        final count = row['count'] ?? 0;

        return FinancialListRow(
          leading: RowLeadingIcon(icon: LucideIcons.clock, color: color),
          title: _agingLabel(range),
          subtitleParts: ['$count cuenta${count == 1 ? '' : 's'}'],
          trailingValue: _fmt.format(total),
          trailingColor: color,
        );
      },
    );
  }

  String _agingLabel(String range) {
    return switch (range) {
      'current' => 'Vigente',
      '1-30' => '1 a 30 días',
      '31-60' => '31 a 60 días',
      '61-90' => '61 a 90 días',
      '90+' => 'Más de 90 días',
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
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(ApiClient.parseError(e))));
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
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
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
          border: Border.all(color: AppTheme.borderSubtle(context)),
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
