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
    final cs = theme.colorScheme;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.shoppingCart, size: 28, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Compras', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showSupplierForm(context),
                      icon: const Icon(LucideIcons.building2, size: 18),
                      label: const Text('Proveedor'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showOrderForm(context),
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('Nueva Orden'),
                    ),
                  ],
                ),
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
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.clipboardList, size: 16), const SizedBox(width: 6), Text('Ordenes (${_orders.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.building2, size: 16), const SizedBox(width: 6), Text('Proveedores (${_suppliers.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.creditCard, size: 16), const SizedBox(width: 6), Text('Por Pagar (${_payables.length})')])),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersTab(theme),
                      _buildSuppliersTab(theme),
                      _buildPayablesTab(theme),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Orders Tab ──

  Widget _buildOrdersTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.clipboardX, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No hay ordenes de compra', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _orders.length,
      itemBuilder: (context, i) {
        final o = _orders[i] as Map<String, dynamic>;
        final status = o['status'] ?? 'draft';
        final total = double.tryParse(o['total']?.toString() ?? '0') ?? 0;

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
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.clipboardList, size: 20, color: cs.primary),
            ),
            title: Text(o['orderNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Row(
              children: [
                Flexible(child: Text('${o['orderDate'] ?? ''}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                _OrderStatusChip(status: status),
              ],
            ),
            trailing: Text(_fmt.format(total), style: AppTheme.mono(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end),
            onTap: () => _showOrderDetail(context, o),
          ),
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
                    DetailRow(theme: theme, label: 'Fecha', value: detail['orderDate'] ?? '', labelWidth: 80),
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

  Widget _buildSuppliersTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_suppliers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.building2, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No hay proveedores', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _suppliers.length,
      itemBuilder: (context, i) {
        final s = _suppliers[i] as Map<String, dynamic>;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: cs.secondaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
              child: Icon(LucideIcons.building2, size: 20, color: cs.secondary),
            ),
            title: Text(s['companyName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(s['contactName'] ?? s['email'] ?? '', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${s['paymentTerms'] ?? 30} dias', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(LucideIcons.pencil, size: 18, color: cs.primary),
                  onPressed: () => _showEditSupplierForm(context, s),
                ),
              ],
            ),
          ),
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

  Widget _buildPayablesTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_payables.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleCheck, size: 48, color: cs.secondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('No hay cuentas por pagar', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _payables.length,
      itemBuilder: (context, i) {
        final item = _payables[i] as Map<String, dynamic>;
        final ap = item['payable'] as Map<String, dynamic>? ?? item;
        final supplierName = item['supplierName'] ?? '';
        final balance = double.tryParse(ap['balance']?.toString() ?? '0') ?? 0;
        final original = double.tryParse(ap['originalAmount']?.toString() ?? '0') ?? 0;

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
                color: cs.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.creditCard, size: 20, color: cs.error),
            ),
            title: Text(supplierName.isEmpty ? 'Proveedor' : supplierName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Row(
              children: [
                Icon(LucideIcons.calendar, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(child: Text('Vence: ${ap['dueDate'] ?? ''}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            trailing: SizedBox(
              width: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_fmt.format(balance), style: AppTheme.mono(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.negative), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('de ${_fmt.format(original)}', style: AppTheme.mono(fontSize: 12, fontWeight: FontWeight.w400, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            onTap: () => _showPaymentDialog(context, ap),
          ),
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

class _OrderStatusChip extends StatelessWidget {
  final String status;
  const _OrderStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, label) = switch (status) {
      'draft' => (cs.onSurfaceVariant, 'Borrador'),
      'approved' => (cs.primary, 'Aprobada'),
      'partial' => (cs.tertiary, 'Parcial'),
      'received' => (cs.secondary, 'Recibida'),
      'cancelled' => (cs.error, 'Cancelada'),
      _ => (cs.onSurfaceVariant, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: AppTheme.tintBg(context, color), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
