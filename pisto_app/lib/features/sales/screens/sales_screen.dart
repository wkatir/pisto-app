import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
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

  // ── Bulk selection (TAREA 2.6) ──
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

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
        _invoices = ((results[0])['data'] as List<dynamic>?) ?? [];
        _customers = ((results[1])['data'] as List<dynamic>?) ?? [];
        _creditNotes = ((results[2])['data'] as List<dynamic>?) ?? [];
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

    final totalInvoices = _invoices.length;
    final totalRevenue = _invoices.fold<double>(0, (sum, inv) {
      return sum + (double.tryParse((inv as Map<String, dynamic>)['total']?.toString() ?? '0') ?? 0);
    });
    final pendingInvoices = _invoices.where((inv) => (inv as Map<String, dynamic>)['paymentStatus'] == 'credit').length;

    return Scaffold(
      floatingActionButton: _selectionMode && _selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _bulkMarkPaid,
              icon: const Icon(LucideIcons.circleCheck),
              label: Text('Marcar ${_selectedIds.length} como pagadas'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: PageHeader(
              eyebrow: 'OPERACIÓN',
              title: 'Tus ventas',
              meta: '$totalInvoices factura${totalInvoices == 1 ? '' : 's'} · ${_fmt.format(totalRevenue)} facturado${pendingInvoices > 0 ? ' · $pendingInvoices a crédito' : ''}',
              metaIsMono: true,
              actions: [
                if (_selectionMode)
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _selectionMode = false;
                      _selectedIds.clear();
                    }),
                    icon: const Icon(LucideIcons.x, size: 14),
                    label: const Text('Cancelar selección'),
                  ),
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, PageRouteBuilder(
                      pageBuilder: (context, _, _) => const CreateSaleScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ));
                    _loadData();
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Nueva venta'),
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
                Tab(text: 'Facturas (${_invoices.length})'),
                Tab(text: 'Clientes (${_customers.length})'),
                Tab(text: 'Notas crédito (${_creditNotes.length})'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const _SalesListSkeleton()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInvoicesTab(theme, isWide),
                      _buildCustomersTab(theme, isWide),
                      _buildCreditNotesTab(theme, isWide),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Invoices Tab ──

  Widget _buildInvoicesTab(ThemeData theme, bool isWide) {
    if (_invoices.isEmpty) {
      return EmptyState(
        icon: LucideIcons.fileText,
        title: 'Aún no facturaste',
        description: 'Creá tu primera venta y empezá a cobrar. Cada factura aparece acá con su estado.',
        actionLabel: 'Nueva venta',
        actionIcon: LucideIcons.plus,
        onAction: () async {
          await Navigator.push(context, PageRouteBuilder(
            pageBuilder: (context, _, _) => const CreateSaleScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
          _loadData();
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 16, isWide ? 32 : 20, 32),
      itemCount: _invoices.length,
      itemBuilder: (context, i) {
        final inv = _invoices[i] as Map<String, dynamic>;
        final status = inv['status'] as String? ?? 'completed';
        final paymentStatus = inv['paymentStatus'] as String? ?? 'paid';
        final total = double.tryParse(inv['total']?.toString() ?? '0') ?? 0;
        final invoiceId = inv['id'] as String? ?? '';
        final isSelected = _selectedIds.contains(invoiceId);
        final cancelled = status == 'cancelled';

        return FinancialListRow(
          leading: _selectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selectedIds.add(invoiceId);
                    } else {
                      _selectedIds.remove(invoiceId);
                      if (_selectedIds.isEmpty) _selectionMode = false;
                    }
                  }),
                )
              : RowLeadingIcon(
                  icon: cancelled ? LucideIcons.fileX : LucideIcons.fileText,
                  color: cancelled ? AppTheme.danger : theme.colorScheme.primary,
                ),
          title: inv['saleNumber']?.toString() ?? 'Sin número',
          subtitleParts: [
            formatDateShortEs(inv['saleDate']?.toString()),
            if (inv['customerName'] != null && (inv['customerName'] as String).isNotEmpty)
              inv['customerName'] as String,
          ],
          chips: [
            PaymentChip(status: paymentStatus),
            if (cancelled) IntentChip(label: 'Anulada', intent: ChipIntent.danger, small: true),
          ],
          trailingValue: _fmt.format(total),
          trailingColor: cancelled ? AppTheme.danger : null,
          trailingSubtitle: paymentStatus == 'credit' ? 'a crédito' : null,
          selected: isSelected,
          onLongPress: () => setState(() {
            _selectionMode = true;
            _selectedIds.add(invoiceId);
          }),
          onTap: _selectionMode
              ? () => setState(() {
                  if (isSelected) {
                    _selectedIds.remove(invoiceId);
                    if (_selectedIds.isEmpty) _selectionMode = false;
                  } else {
                    _selectedIds.add(invoiceId);
                  }
                })
              : () => _showInvoiceDetail(context, inv),
        );
      },
    );
  }

  // ── PDF Download ──

  void _downloadInvoicePdf(BuildContext context, String invoiceId) {
    final baseUrl = kIsWeb ? AppConstants.apiBaseUrlWeb : AppConstants.apiBaseUrl;
    final pdfUrl = '$baseUrl/exports/invoices/$invoiceId/pdf';
    AppToast.show(
      context,
      message: 'PDF listo',
      type: ToastType.success,
      actionLabel: 'Copiar URL',
      onAction: () => Clipboard.setData(ClipboardData(text: pdfUrl)),
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
                    DetailRow(theme: theme, label: 'Fecha', value: formatDateDisplay(detail['saleDate']?.toString()), labelWidth: 80),
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
              label: const Text('Nota crédito'),
            ),
          ],
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _downloadInvoicePdf(context, invoiceId);
            },
            icon: const Icon(LucideIcons.fileDown, size: 16),
            label: const Text('PDF'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  // ── Cancel Sale ──

  void _confirmCancelSale(BuildContext context, Map<String, dynamic> invoice) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Anular venta',
      description: '¿Anular la factura "${invoice['saleNumber']}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Anular',
      icon: LucideIcons.ban,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(salesServiceProvider).cancelSale(invoice['id'] as String);
      if (mounted) AppToast.success(context, 'Factura anulada correctamente');
      _loadData();
    } catch (e) {
      if (mounted) AppToast.error(context, ApiClient.parseError(e));
    }
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
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(ApiClient.parseError(e))));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // ── Bulk Mark Paid ──

  void _bulkMarkPaid() async {
    final count = _selectedIds.length;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Marcar como pagadas',
      description: '¿Marcar $count factura${count == 1 ? '' : 's'} como pagadas?',
      confirmLabel: 'Confirmar',
      icon: LucideIcons.circleCheck,
      destructive: false,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
    if (mounted) {
      AppToast.success(context, '$count factura${count == 1 ? '' : 's'} marcada${count == 1 ? '' : 's'} como pagadas');
    }
    _loadData();
  }

  // ── Customers Tab ──

  Widget _buildCustomersTab(ThemeData theme, bool isWide) {
    final cs = theme.colorScheme;

    if (_customers.isEmpty) {
      return EmptyState(
        icon: LucideIcons.users,
        title: 'Aún no tenés clientes',
        description: 'Agregá tu primer cliente para empezar a facturar a su nombre y llevar el seguimiento de sus pagos.',
        actionLabel: 'Nuevo cliente',
        actionIcon: LucideIcons.userPlus,
        onAction: () async {
          await Navigator.push(context, PageRouteBuilder(
            pageBuilder: (context, _, _) => const CustomerFormScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
          _loadData();
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 16, isWide ? 32 : 20, 8),
          child: Row(
            children: [
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push(context, PageRouteBuilder(
                    pageBuilder: (context, _, _) => const CustomerFormScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ));
                  _loadData();
                },
                icon: const Icon(LucideIcons.userPlus, size: 14),
                label: const Text('Nuevo cliente'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 0, isWide ? 32 : 20, 32),
            itemCount: _customers.length,
            itemBuilder: (context, i) {
              final c = _customers[i] as Map<String, dynamic>;
              final isCompany = c['customerType'] == 'company';
              final name = (isCompany
                      ? c['companyName']?.toString()
                      : '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim()) ??
                  '';
              final contact = (c['email']?.toString().isNotEmpty == true)
                  ? c['email'] as String
                  : (c['phone']?.toString() ?? '');

              return FinancialListRow(
                leading: RowLeadingIcon(
                  icon: isCompany ? LucideIcons.building2 : LucideIcons.user,
                  color: cs.primary,
                ),
                title: name.isEmpty ? 'Sin nombre' : name,
                subtitleParts: [
                  if (contact.isNotEmpty) contact,
                  if (isCompany) 'Empresa',
                ],
                onTap: () => _showEditCustomerForm(context, c),
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
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(ApiClient.parseError(e))));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ── Credit Notes Tab ──

  Widget _buildCreditNotesTab(ThemeData theme, bool isWide) {
    if (_creditNotes.isEmpty) {
      return EmptyState(
        icon: LucideIcons.fileMinus,
        title: 'Sin notas de crédito',
        description: 'Cuando emitas una nota de crédito sobre una factura, aparecerá acá con su monto descontado.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 16, isWide ? 32 : 20, 32),
      itemCount: _creditNotes.length,
      itemBuilder: (context, i) {
        final cn = _creditNotes[i] as Map<String, dynamic>;
        final amount = double.tryParse(cn['amount']?.toString() ?? '0') ?? 0;
        final number = cn['creditNoteNumber']?.toString() ??
            'NC-${cn['id']?.toString().substring(0, 8) ?? ''}';
        final saleNumber = cn['saleNumber']?.toString() ?? '';
        final date = formatDateShortEs(cn['createdAt']?.toString());

        return FinancialListRow(
          leading: RowLeadingIcon(
            icon: LucideIcons.fileMinus,
            color: AppTheme.danger,
          ),
          title: number,
          subtitleParts: [
            if (saleNumber.isNotEmpty) 'Factura $saleNumber',
            if (date.isNotEmpty) date,
          ],
          trailingValue: '−${_fmt.format(amount)}',
          trailingColor: AppTheme.danger,
        );
      },
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _SalesSkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SalesSkeletonBox({
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

class _SalesListSkeleton extends StatelessWidget {
  const _SalesListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 8,
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
            _SalesSkeletonBox(width: 40, height: 40, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SalesSkeletonBox(width: 120 + (i % 3) * 20.0, height: 14),
                  const SizedBox(height: 6),
                  _SalesSkeletonBox(width: 80 + (i % 2) * 30.0, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _SalesSkeletonBox(width: 72, height: 15),
                const SizedBox(height: 6),
                _SalesSkeletonBox(width: 52, height: 18, radius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
