import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState
    extends ConsumerState<CustomerDetailScreen> {
  Map<String, dynamic>? _customer;
  Map<String, dynamic>? _statement;
  List<Map<String, dynamic>> _invoices = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final salesService = ref.read(salesServiceProvider);
      final collectionsService = ref.read(collectionsServiceProvider);

      final results = await Future.wait([
        salesService.getCustomer(widget.customerId),
        collectionsService.getCustomerStatement(widget.customerId),
        salesService.listInvoices(customerId: widget.customerId),
      ]);

      setState(() {
        _customer = results[0] as Map<String, dynamic>?;
        _statement = results[1] as Map<String, dynamic>?;
        final invoiceData = results[2] as Map<String, dynamic>?;
        _invoices = (invoiceData?['data'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de cliente')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de cliente')),
        body: Center(child: Text(_error ?? 'No encontrado')),
      );
    }

    final firstName = _customer!['firstName'] as String? ?? '';
    final lastName = _customer!['lastName'] as String? ?? '';
    final customerName = '$firstName $lastName'.trim();
    final companyName = _customer!['companyName'] as String?;
    final displayName =
        companyName?.isNotEmpty == true ? companyName! : customerName;

    final totalPending =
        double.tryParse(_statement?['totalPending']?.toString() ?? '0') ?? 0;
    final creditLimit =
        double.tryParse(_customer!['creditLimit']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          displayName,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Nueva venta'),
              onPressed: () =>
                  context.go('/sales/create?customerId=${widget.customerId}'),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Tarjeta de resumen financiero ──────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance pendiente',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${totalPending.toStringAsFixed(2)}',
                    style: AppTheme.mono(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: totalPending > 0
                          ? AppTheme.negative
                          : AppTheme.positive,
                    ),
                  ),
                  if (creditLimit > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Límite de crédito: ',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(),
                        ),
                        Text(
                          '\$${creditLimit.toStringAsFixed(2)}',
                          style: AppTheme.mono(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  if (_customer!['phone'] != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(LucideIcons.phone,
                            size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          _customer!['phone'] as String,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                  if (_customer!['email'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.mail,
                            size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          _customer!['email'] as String,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Lista de facturas ──────────────────────────────────────
            Text(
              'Últimas facturas',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_invoices.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Center(
                  child: Text(
                    'Sin facturas aún',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(),
                  ),
                ),
              )
            else
              ...(_invoices.take(20).map((inv) {
                final amount =
                    double.tryParse(inv['total']?.toString() ?? '0') ?? 0;
                final status = inv['paymentStatus'] as String? ?? '';
                final saleNumber = inv['saleNumber'] as String? ??
                    inv['id'] as String? ??
                    '';
                final dateStr = formatDateShortEs(inv['createdAt']?.toString());
                final isPaid = status == 'paid';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saleNumber,
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${amount.toStringAsFixed(2)}',
                            style: AppTheme.mono(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.tintBg(
                                context,
                                isPaid ? AppTheme.success : AppTheme.warning,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPaid ? 'Pagado' : 'Pendiente',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isPaid
                                    ? AppTheme.positive
                                    : AppTheme.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }
}
