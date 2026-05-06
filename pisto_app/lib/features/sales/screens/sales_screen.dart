import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import 'create_sale_screen.dart';
import 'customer_form_screen.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _invoices = [];
  List<dynamic> _customers = [];
  List<dynamic> _creditNotes = [];
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
      final svc = ref.read(salesServiceProvider);
      final results = await Future.wait([
        svc.listInvoices(),
        svc.listCustomers(),
        svc.listCreditNotes(),
      ]);
      setState(() {
        _invoices = (results[0])['data'] as List<dynamic>;
        _customers = (results[1])['data'] as List<dynamic>;
        _creditNotes = (results[2])['data'] as List<dynamic>;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.receipt, size: 28, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Ventas', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSaleScreen()));
                        _loadData();
                      },
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('Nueva Venta'),
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
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.fileText, size: 16), const SizedBox(width: 6), Text('Facturas (${_invoices.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.users, size: 16), const SizedBox(width: 6), Text('Clientes (${_customers.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.fileX, size: 16), const SizedBox(width: 6), Text('Notas Credito (${_creditNotes.length})')])),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInvoicesTab(theme),
                      _buildCustomersTab(theme),
                      _buildCreditNotesTab(theme),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Invoices Tab ──

  Widget _buildInvoicesTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileX, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No hay facturas', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _invoices.length,
      itemBuilder: (context, i) {
        final inv = _invoices[i] as Map<String, dynamic>;
        final status = inv['status'] ?? 'completed';
        final paymentStatus = inv['paymentStatus'] ?? 'paid';
        final total = double.tryParse(inv['total']?.toString() ?? '0') ?? 0;

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
                color: status == 'cancelled'
                    ? cs.errorContainer.withValues(alpha: 0.5)
                    : cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                status == 'cancelled' ? LucideIcons.fileX : LucideIcons.fileText,
                size: 20,
                color: status == 'cancelled' ? cs.error : cs.primary,
              ),
            ),
            title: Text(inv['saleNumber'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Row(
              children: [
                Flexible(child: Text('${inv['saleDate'] ?? ''}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                _PaymentChip(status: paymentStatus),
              ],
            ),
            trailing: Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_fmt.format(total), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  _StatusChip(status: status),
                ],
              ),
            ),
            onTap: () => _showInvoiceDetail(context, inv),
          ),
        );
      },
    );
  }

  // ── Invoice Detail ──

  void _showInvoiceDetail(BuildContext context, Map<String, dynamic> invoice) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final total = double.tryParse(invoice['total']?.toString() ?? '0') ?? 0;
    final status = invoice['status'] ?? 'completed';
    final invoiceId = invoice['id'] as String;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.fileText, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(invoice['saleNumber'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 350),
          child: SingleChildScrollView(
            child: FutureBuilder<Map<String, dynamic>>(
              future: ref.read(salesServiceProvider).getInvoice(invoiceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Text('Error al cargar detalle', style: TextStyle(color: cs.error));
                }
                final detail = snapshot.data ?? invoice;
                final lines = detail['lines'] as List<dynamic>? ?? [];
                final customerName = detail['customerName'] ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DetailRow(theme: theme, label: 'Fecha', value: detail['saleDate'] ?? '', labelWidth: 80),
                    DetailRow(theme: theme, label: 'Estado', value: status, labelWidth: 80),
                    DetailRow(theme: theme, label: 'Pago', value: detail['paymentStatus'] ?? '', labelWidth: 80),
                    if (customerName.isNotEmpty) DetailRow(theme: theme, label: 'Cliente', value: customerName, labelWidth: 80),
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
                              Text(_fmt.format(lineTotal), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
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
          if (status == 'completed') ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmCancelSale(context, invoice);
              },
              icon: Icon(LucideIcons.ban, size: 16, color: cs.error),
              label: Text('Anular', style: TextStyle(color: cs.error)),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showCreditNoteForm(context, invoice);
              },
              icon: const Icon(LucideIcons.fileMinus, size: 16),
              label: const Text('Nota Credito'),
            ),
          ],
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  // ── Cancel Sale ──

  void _confirmCancelSale(BuildContext context, Map<String, dynamic> invoice) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, size: 22, color: cs.error),
            const SizedBox(width: 8),
            const Text('Anular Venta'),
          ],
        ),
        content: Text('¿Anular la factura "${invoice['saleNumber']}"? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              try {
                await ref.read(salesServiceProvider).cancelSale(invoice['id'] as String);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Anular'),
          ),
        ],
      ),
    );
  }

  // ── Credit Note Form ──

  void _showCreditNoteForm(BuildContext context, Map<String, dynamic> invoice) {
    final reasonCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: invoice['total']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.fileMinus, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Nota de Credito'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Factura: ${invoice['saleNumber'] ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Monto', border: OutlineInputBorder(), prefixText: '\$ '),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Razon', border: OutlineInputBorder()), maxLines: 2),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(salesServiceProvider).createCreditNote(invoice['id'] as String, {
                  'amount': amountCtrl.text,
                  if (reasonCtrl.text.isNotEmpty) 'reason': reasonCtrl.text,
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

  // ── Customers Tab ──

  Widget _buildCustomersTab(ThemeData theme) {
    final cs = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerFormScreen()));
                  _loadData();
                },
                icon: const Icon(LucideIcons.userPlus, size: 18),
                label: const Text('Cliente'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _customers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.users, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('No hay clientes', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _customers.length,
                  itemBuilder: (context, i) {
                    final c = _customers[i] as Map<String, dynamic>;
                    final isCompany = c['customerType'] == 'company';
                    final name = c['companyName'] ?? '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim();

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
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(isCompany ? LucideIcons.building2 : LucideIcons.user, size: 20, color: cs.secondary),
                        ),
                        title: Text(name.isEmpty ? 'Sin nombre' : name, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(c['email'] ?? c['phone'] ?? '', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: Icon(LucideIcons.pencil, size: 18, color: cs.primary),
                          onPressed: () => _showEditCustomerForm(context, c),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Edit Customer ──

  void _showEditCustomerForm(BuildContext context, Map<String, dynamic> customer) {
    final firstNameCtrl = TextEditingController(text: customer['firstName'] ?? '');
    final lastNameCtrl = TextEditingController(text: customer['lastName'] ?? '');
    final companyCtrl = TextEditingController(text: customer['companyName'] ?? '');
    final emailCtrl = TextEditingController(text: customer['email'] ?? '');
    final phoneCtrl = TextEditingController(text: customer['phone'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.userCog, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Editar Cliente'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (customer['customerType'] == 'company')
                  TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Nombre Empresa', border: OutlineInputBorder()))
                else ...[
                  TextField(controller: firstNameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: lastNameCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder())),
                ],
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
                await ref.read(salesServiceProvider).updateCustomer(customer['id'] as String, {
                  if (firstNameCtrl.text.isNotEmpty) 'firstName': firstNameCtrl.text,
                  if (lastNameCtrl.text.isNotEmpty) 'lastName': lastNameCtrl.text,
                  if (companyCtrl.text.isNotEmpty) 'companyName': companyCtrl.text,
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

  // ── Credit Notes Tab ──

  Widget _buildCreditNotesTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_creditNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileMinus, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No hay notas de credito', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _creditNotes.length,
      itemBuilder: (context, i) {
        final cn = _creditNotes[i] as Map<String, dynamic>;
        final amount = double.tryParse(cn['amount']?.toString() ?? '0') ?? 0;

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
              decoration: BoxDecoration(color: cs.errorContainer.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(8)),
              child: Icon(LucideIcons.fileMinus, size: 20, color: cs.error),
            ),
            title: Text(cn['creditNoteNumber'] ?? 'NC-${cn['id']?.toString().substring(0, 8) ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              'Factura: ${cn['saleNumber'] ?? ''} · ${cn['createdAt']?.toString().substring(0, 10) ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: SizedBox(
              width: 110,
              child: Text(
                '-${_fmt.format(amount)}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.error),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, label) = switch (status) {
      'completed' => (cs.primary, 'Completada'),
      'cancelled' => (cs.error, 'Cancelada'),
      _ => (cs.tertiary, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String status;
  const _PaymentChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, label) = switch (status) {
      'paid' => (cs.secondary, 'Pagada'),
      'credit' => (cs.tertiary, 'Credito'),
      _ => (cs.onSurfaceVariant, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
