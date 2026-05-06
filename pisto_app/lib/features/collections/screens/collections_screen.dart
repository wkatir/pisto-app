import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        _receivables = (results[0] as Map<String, dynamic>)['data'] as List<dynamic>;
        _aging = results[1] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
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
                ? const Center(child: CircularProgressIndicator())
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
            Icon(LucideIcons.checkCircle, size: 48, color: cs.secondary.withValues(alpha: 0.5)),
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

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            trailing: Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_fmt.format(balance), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.error), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('de ${_fmt.format(original)}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
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
                DetailRow(theme: theme, label: 'Monto Original', value: _fmt.format(original), labelWidth: 120),
                DetailRow(theme: theme, label: 'Saldo', value: _fmt.format(balance), labelWidth: 120),
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
                              Text(_fmt.format(amount), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: cs.secondary)),
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
                      icon: const Icon(LucideIcons.fileBarChart, size: 16),
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
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.fileBarChart, size: 22, color: cs.primary),
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
                          Text(_fmt.format(totalBalance), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.error)),
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
                              Text(_fmt.format(entryBalance), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: cs.error)),
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

    final agingColors = [cs.secondary, cs.primary, cs.tertiary, AppTheme.chartOrange, cs.error];

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
                Text(_fmt.format(total), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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

  // ── Payment Dialog ──

  void _showPaymentDialog(BuildContext context, Map<String, dynamic> ar) {
    final amountCtrl = TextEditingController(text: ar['balance']?.toString() ?? '');
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
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
                        style: TextStyle(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
