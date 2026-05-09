import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _orders = [];
  List<dynamic> _suppliers = [];
  List<dynamic> _payables = [];
  bool _loading = true;

  final _fmt = currencyFmt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final svc = ref.read(purchasesServiceProvider);
      final results = await Future.wait([
        svc.listOrders(),
        svc.listSuppliers(),
        svc.listPayables(),
      ]);
      setState(() {
        _orders = ((results[0] as Map<String, dynamic>)['data'] as List<dynamic>?) ?? [];
        _suppliers = (results[1] as List<dynamic>?) ?? [];
        _payables = ((results[2] as Map<String, dynamic>)['data'] as List<dynamic>?) ?? [];
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

    final totalPayable = _payables.fold<double>(0, (sum, p) {
      final ap = (p as Map<String, dynamic>)['payable'] as Map<String, dynamic>? ?? p;
      return sum + (double.tryParse(ap['balance']?.toString() ?? '0') ?? 0);
    });

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: PageHeader(
              eyebrow: 'OPERACIÓN',
              title: 'Tus compras',
              meta: '${_orders.length} orden${_orders.length == 1 ? '' : 'es'} · ${_suppliers.length} proveedor${_suppliers.length == 1 ? '' : 'es'}'
                  '${totalPayable > 0 ? ' · debés ${_fmt.format(totalPayable)}' : ''}',
              metaIsMono: true,
              actions: [
                OutlinedButton.icon(
                  onPressed: () => _showSupplierForm(context),
                  icon: const Icon(LucideIcons.building2, size: 14),
                  label: const Text('Nuevo proveedor'),
                ),
                FilledButton.icon(
                  onPressed: () => _showOrderForm(context),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Nueva orden'),
                ),
              ],
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
                Tab(text: 'Órdenes (${_orders.length})'),
                Tab(text: 'Proveedores (${_suppliers.length})'),
                Tab(text: 'Por pagar (${_payables.length})'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersTab(theme, isWide),
                      _buildSuppliersTab(theme, isWide),
                      _buildPayablesTab(theme, isWide),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Orders Tab ──

  Widget _buildOrdersTab(ThemeData theme, bool isWide) {
    if (_orders.isEmpty) {
      return EmptyState(
        icon: LucideIcons.clipboardList,
        title: 'Sin órdenes de compra',
        description: 'Creá una orden a un proveedor para registrar lo que vas a recibir y mantener tu inventario al día.',
        actionLabel: 'Nueva orden',
        actionIcon: LucideIcons.plus,
        onAction: () => _showOrderForm(context),
      );
    }

    final padX = isWide ? 32.0 : 20.0;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      itemCount: _orders.length,
      itemBuilder: (context, i) {
        final o = _orders[i] as Map<String, dynamic>;
        final status = o['status'] as String? ?? 'draft';
        final total = double.tryParse(o['total']?.toString() ?? '0') ?? 0;
        final supplierName = o['supplierName']?.toString() ?? '';

        return FinancialListRow(
          leading: RowLeadingIcon(
            icon: LucideIcons.clipboardList,
            color: theme.colorScheme.primary,
          ),
          title: o['orderNumber']?.toString() ?? 'Sin número',
          subtitleParts: [
            formatDateShortEs(o['orderDate']?.toString()),
            if (supplierName.isNotEmpty) supplierName,
          ],
          chips: [
            StatusChip(status: status, type: StatusType.order),
          ],
          trailingValue: _fmt.format(total),
          onTap: () => _showOrderDetail(context, o),
        );
      },
    );
  }

  // ── Order Detail ──

  void _showOrderDetail(BuildContext context, Map<String, dynamic> order) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final status = order['status'] ?? 'draft';
    final orderId = order['id'] as String;
    final total = double.tryParse(order['total']?.toString() ?? '0') ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.clipboardList, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(order['orderNumber'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 400),
          child: SingleChildScrollView(
            child: FutureBuilder<Map<String, dynamic>>(
              future: ref.read(purchasesServiceProvider).getOrder(orderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Text('Error al cargar detalle', style: TextStyle(color: cs.error));
                }
                final detail = snapshot.data ?? order;
                final lines = detail['lines'] as List<dynamic>? ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DetailRow(theme: theme, label: 'Fecha', value: formatDateDisplay(detail['orderDate']?.toString()), labelWidth: 80),
                    DetailRow(theme: theme, label: 'Estado', value: status, labelWidth: 80),
                    DetailRow(theme: theme, label: 'Proveedor', value: detail['supplierName'] ?? '', labelWidth: 80),
                    DetailRow(theme: theme, label: 'Total', value: _fmt.format(total), labelWidth: 80),
                    if (lines.isNotEmpty) ...[
                      const Divider(height: 24),
                      Text('Lineas', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...lines.map((l) {
                        final line = l as Map<String, dynamic>;
                        final lineTotal = double.tryParse(line['total']?.toString() ?? '0') ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(line['productName'] ?? '', style: theme.textTheme.bodySmall)),
                              Text('x${line['quantity'] ?? 1}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                              const SizedBox(width: 12),
                              Text(_fmt.format(lineTotal), style: AppTheme.mono(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        actions: [
          if (status == 'approved' || status == 'partial')
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showReceiveGoodsForm(context, order);
              },
              icon: const Icon(LucideIcons.packageCheck, size: 16),
              label: const Text('Recibir Mercaderia'),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  // ── Receive Goods ──

  void _showReceiveGoodsForm(BuildContext context, Map<String, dynamic> order) {
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.packageCheck, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Recibir Mercaderia'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Orden: ${order['orderNumber'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notas de recepcion', border: OutlineInputBorder()), maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(purchasesServiceProvider).receiveGoods(order['id'] as String, {
                  if (notesCtrl.text.isNotEmpty) 'notes': notesCtrl.text,
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Confirmar Recepcion'),
          ),
        ],
      ),
    );
  }

  // ── Create Order ──

  void _showOrderForm(BuildContext context) {
    String? selectedSupplier;
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.clipboardList, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Nueva Orden de Compra'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                isExpanded: true,
                    initialValue: selectedSupplier,
                    decoration: const InputDecoration(labelText: 'Proveedor', border: OutlineInputBorder()),
                    items: _suppliers.map((s) => DropdownMenuItem(value: s['id'] as String, child: Text(s['companyName'] ?? '', overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setDialogState(() => selectedSupplier = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder()), maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (selectedSupplier == null) return;
                try {
                  await ref.read(purchasesServiceProvider).createOrder({
                    'supplierId': selectedSupplier,
                    if (notesCtrl.text.isNotEmpty) 'notes': notesCtrl.text,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Suppliers Tab ──

  Widget _buildSuppliersTab(ThemeData theme, bool isWide) {
    if (_suppliers.isEmpty) {
      return EmptyState(
        icon: LucideIcons.building2,
        title: 'Sin proveedores',
        description: 'Agregá tus proveedores para llevar el control de las órdenes y los pagos pendientes con cada uno.',
        actionLabel: 'Nuevo proveedor',
        actionIcon: LucideIcons.plus,
        onAction: () => _showSupplierForm(context),
      );
    }

    final padX = isWide ? 32.0 : 20.0;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      itemCount: _suppliers.length,
      itemBuilder: (context, i) {
        final s = _suppliers[i] as Map<String, dynamic>;
        final name = s['companyName']?.toString() ?? '';
        final contact = (s['contactName']?.toString().isNotEmpty == true)
            ? s['contactName'] as String
            : (s['email']?.toString() ?? '');
        final terms = s['paymentTerms']?.toString() ?? '30';

        return FinancialListRow(
          leading: RowAvatar(text: name.isEmpty ? '?' : name, color: AppTheme.info),
          title: name.isEmpty ? 'Sin nombre' : name,
          subtitleParts: [
            if (contact.isNotEmpty) contact,
          ],
          chips: [
            IntentChip(
              label: '$terms días',
              intent: ChipIntent.neutral,
              icon: LucideIcons.clock,
              small: true,
            ),
          ],
          onTap: () => _showEditSupplierForm(context, s),
        );
      },
    );
  }

  // ── Edit Supplier ──

  void _showEditSupplierForm(BuildContext context, Map<String, dynamic> supplier) {
    final nameCtrl = TextEditingController(text: supplier['companyName'] ?? '');
    final contactCtrl = TextEditingController(text: supplier['contactName'] ?? '');
    final emailCtrl = TextEditingController(text: supplier['email'] ?? '');
    final phoneCtrl = TextEditingController(text: supplier['phone'] ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.building2, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Editar Proveedor'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre Empresa', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Contacto', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefono', border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(purchasesServiceProvider).updateSupplier(supplier['id'] as String, {
                  'companyName': nameCtrl.text,
                  if (contactCtrl.text.isNotEmpty) 'contactName': contactCtrl.text,
                  if (emailCtrl.text.isNotEmpty) 'email': emailCtrl.text,
                  if (phoneCtrl.text.isNotEmpty) 'phone': phoneCtrl.text,
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ── Payables Tab ──

  Widget _buildPayablesTab(ThemeData theme, bool isWide) {
    if (_payables.isEmpty) {
      return EmptyState(
        icon: LucideIcons.circleCheck,
        title: 'No debés nada',
        description: 'No hay cuentas por pagar a proveedores. Cuando recibas mercadería a crédito aparecerá acá.',
      );
    }

    final padX = isWide ? 32.0 : 20.0;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      itemCount: _payables.length,
      itemBuilder: (context, i) {
        final item = _payables[i] as Map<String, dynamic>;
        final ap = item['payable'] as Map<String, dynamic>? ?? item;
        final supplierName = (item['supplierName'] ?? '') as String;
        final balance = double.tryParse(ap['balance']?.toString() ?? '0') ?? 0;
        final original = double.tryParse(ap['originalAmount']?.toString() ?? '0') ?? 0;
        final dueDate = ap['dueDate']?.toString() ?? '';
        final overdue = dueDate.isNotEmpty &&
            (DateTime.tryParse(dueDate)?.isBefore(DateTime.now()) ?? false);

        return FinancialListRow(
          leading: RowAvatar(
            text: supplierName.isEmpty ? '?' : supplierName,
            color: overdue ? AppTheme.danger : AppTheme.warning,
          ),
          title: supplierName.isEmpty ? 'Proveedor' : supplierName,
          subtitleParts: [
            if (dueDate.isNotEmpty) 'Vence ${formatDateShortEs(dueDate)}',
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
          onTap: () => _showPaymentDialog(context, ap),
        );
      },
    );
  }

  // ── Supplier Form ──

  void _showSupplierForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.building2, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            const Text('Nuevo Proveedor'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre Empresa', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Contacto', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefono', border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(purchasesServiceProvider).createSupplier({
                  'companyName': nameCtrl.text,
                  if (contactCtrl.text.isNotEmpty) 'contactName': contactCtrl.text,
                  if (emailCtrl.text.isNotEmpty) 'email': emailCtrl.text,
                  if (phoneCtrl.text.isNotEmpty) 'phone': phoneCtrl.text,
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // ── Payment Dialog ──

  void _showPaymentDialog(BuildContext context, Map<String, dynamic> ap) {
    final amountCtrl = TextEditingController(text: ap['balance']?.toString() ?? '');
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.banknote, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            const Text('Registrar Pago'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.wallet, size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Flexible(child: Text('Saldo: ${_fmt.format(double.tryParse(ap['balance']?.toString() ?? '0') ?? 0)}',
                        style: AppTheme.mono(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                await ref.read(purchasesServiceProvider).createSupplierPayment(
                  ap['id'] as String,
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

