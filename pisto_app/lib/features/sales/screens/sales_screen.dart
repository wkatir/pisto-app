import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/models/paginated.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/forms/forms.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/credit_note.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../providers/sales_providers.dart';
import 'create_sale_screen.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _activeTab = 0;

  final _invoiceAcc = _PagedAccumulator<Invoice>();
  final _customerAcc = _PagedAccumulator<Customer>();
  final _creditNoteAcc = _PagedAccumulator<CreditNote>();
  String _customerSearch = '';

  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  bool _dialogOpen = false;

  final _fmt = currencyFmt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _activeTab) {
        setState(() => _activeTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Serializes the screen's dialogs: a double click (or a semantic click on
  /// web, which pierces the modal barrier) can't stack two.
  Future<void> _guardDialog(Future<void> Function() open) async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    try {
      await open();
    } finally {
      _dialogOpen = false;
    }
  }

  /// Applies a freshly resolved `AsyncData` to its accumulator.
  void _consume<T>(AsyncValue<Paginated<T>> next, _PagedAccumulator<T> acc) {
    next.whenData((p) {
      if (acc.merge(p)) setState(() {});
    });
  }

  Future<void> _openCreateSale() async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, _) => const CreateSaleScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    setState(_invoiceAcc.reset);
    ref.invalidate(invoicesListProvider);
  }

  Future<void> _openCreateCustomer() async {
    final created = await SidePanelForm.show(
      context,
      title: 'Nuevo cliente',
      fields: _customerFields(existing: null),
      successMessage: 'Cliente creado',
      onSubmit: (values) => ref
          .read(customerMutationsProvider.notifier)
          .create(
            customerType: (values['customerType'] as String?) ?? 'person',
            firstName: values['firstName'] as String?,
            lastName: values['lastName'] as String?,
            companyName: values['companyName'] as String?,
            taxId: values['taxId'] as String?,
            email: values['email'] as String?,
            phone: values['phone'] as String?,
            address: values['address'] as String?,
          ),
    );
    if (created && mounted) setState(_customerAcc.reset);
  }

  List<Widget> _customerFields({required Customer? existing}) => [
    _CustomerTypeFields(existing: existing),
    Row(
      children: [
        Expanded(
          child: PTextField(
            name: 'email',
            label: 'Email',
            initialValue: existing?.email,
            keyboardType: TextInputType.emailAddress,
            validator: PValidators.email,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PTextField(
            name: 'phone',
            label: 'Teléfono',
            initialValue: existing?.phone,
            keyboardType: TextInputType.phone,
            validator: PValidators.phone,
          ),
        ),
      ],
    ),
    if (existing == null) const PTextField(name: 'taxId', label: 'NIT / DUI'),
    if (existing == null)
      const PTextField(name: 'address', label: 'Dirección', maxLines: 2),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;
    final hPad = isWide ? 32.0 : 20.0;

    final invoicesAsync = ref.watch(
      invoicesListProvider(page: _invoiceAcc.requestPage),
    );
    ref.listen(
      invoicesListProvider(page: _invoiceAcc.requestPage),
      (_, next) => _consume(next, _invoiceAcc),
    );

    final customersAsync = ref.watch(
      customersListProvider(
        page: _customerAcc.requestPage,
        search: _customerSearch,
      ),
    );
    ref.listen(
      customersListProvider(
        page: _customerAcc.requestPage,
        search: _customerSearch,
      ),
      (_, next) => _consume(next, _customerAcc),
    );

    final creditNotesAsync = ref.watch(
      creditNotesListProvider(page: _creditNoteAcc.requestPage),
    );
    ref.listen(
      creditNotesListProvider(page: _creditNoteAcc.requestPage),
      (_, next) => _consume(next, _creditNoteAcc),
    );

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
            padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 0),
            child: PageHeader(
              title: 'Tus ventas',
              metrics: _invoiceMetrics(),
              actions: [
                if (_activeTab == 0)
                  _selectionMode
                      ? OutlinedButton.icon(
                          onPressed: () => setState(() {
                            _selectionMode = false;
                            _selectedIds.clear();
                          }),
                          icon: const Icon(LucideIcons.x, size: 14),
                          label: const Text('Cancelar selección'),
                        )
                      : OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _selectionMode = true),
                          icon: const Icon(LucideIcons.listChecks, size: 14),
                          label: const Text('Seleccionar'),
                        ),
                FilledButton.icon(
                  onPressed: _openCreateSale,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Nueva venta'),
                ),
              ],
            ),
          ),
          if (_activeTab == 0) ...[
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: _invoiceRevenueFigure(),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: PTabs(
              tabs: [
                PTabItem('Facturas', count: _invoiceAcc.meta?.total),
                PTabItem('Clientes', count: _customerAcc.meta?.total),
                PTabItem('Notas crédito', count: _creditNoteAcc.meta?.total),
              ],
              index: _activeTab,
              onChanged: (i) => _tabController.animateTo(i),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: KeyedSubtree(
                key: ValueKey(_activeTab),
                child: switch (_activeTab) {
                  0 => _buildInvoicesTab(theme, cs, hPad, invoicesAsync),
                  1 => _buildCustomersTab(theme, cs, hPad, customersAsync),
                  _ => _buildCreditNotesTab(theme, cs, hPad, creditNotesAsync),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _invoiceMetrics() {
    final view = _invoiceAcc.view;
    if (view == null) return const [];
    return [MetricChip(label: 'Facturas', value: '${view.meta.total}')];
  }

  /// The sum only covers invoices already loaded (pagination via "Cargar más"),
  /// not the historical total, hence the label doesn't promise more than it shows.
  Widget _invoiceRevenueFigure() {
    final view = _invoiceAcc.view;
    if (view == null) return const SizedBox.shrink();
    final revenue = view.data.fold<double>(0, (s, i) => s + i.totalValue);
    return BigFigure(
      label: 'Facturado',
      value: currencyFmt.format(revenue),
      size: BigFigureSize.m,
    );
  }

  // ── Invoices tab ───────────────────────────────────────────────────────────

  List<DataListColumn<Invoice>> _invoiceColumns(
    ThemeData theme,
    ColorScheme cs,
  ) => [
    DataListColumn<Invoice>(
      label: 'Nº',
      flex: 2,
      cell: (context, inv) {
        final selected = _selectedIds.contains(inv.id);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectionMode) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: selected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selectedIds.add(inv.id);
                    } else {
                      _selectedIds.remove(inv.id);
                      if (_selectedIds.isEmpty) _selectionMode = false;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                inv.saleNumber,
                style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    ),
    DataListColumn<Invoice>(
      label: 'Cliente',
      flex: 3,
      cell: (context, inv) => Text(
        inv.customerName ?? 'Consumidor final',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    DataListColumn<Invoice>(
      label: 'Fecha',
      flex: 2,
      cell: (context, inv) => Text(
        formatDateShortEs(inv.saleDate),
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
    ),
    DataListColumn<Invoice>(
      label: 'Estado',
      flex: 2,
      cell: (context, inv) => Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          PaymentChip(status: inv.paymentStatus),
          if (inv.cancelled)
            IntentChip(
              label: 'Anulada',
              intent: ChipIntent.danger,
              small: true,
            ),
        ],
      ),
    ),
    DataListColumn<Invoice>(
      label: 'Total',
      flex: 2,
      isMoney: true,
      cell: (context, inv) => MoneyValue(
        formatted: _fmt.format(inv.totalValue),
        size: MoneySize.small,
        color: inv.cancelled ? AppTheme.danger : null,
      ),
    ),
  ];

  void _handleInvoiceTap(Invoice inv) {
    if (_selectionMode) {
      setState(() {
        if (_selectedIds.contains(inv.id)) {
          _selectedIds.remove(inv.id);
          if (_selectedIds.isEmpty) _selectionMode = false;
        } else {
          _selectedIds.add(inv.id);
        }
      });
      return;
    }
    _guardDialog(() => _showInvoiceDetail(context, inv));
  }

  Widget _buildInvoicesTab(
    ThemeData theme,
    ColorScheme cs,
    double hPad,
    AsyncValue<Paginated<Invoice>> async,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: _PagedTab<Invoice>(
          async: async,
          acc: _invoiceAcc,
          columns: _invoiceColumns(theme, cs),
          emptyState: EmptyState(
            image: 'assets/illustrations/empty_sales.png',
            title: 'Aún no facturaste',
            description:
                'Creá tu primera venta y empezá a cobrar. Cada factura aparece acá con su estado.',
            actionLabel: 'Nueva venta',
            actionIcon: LucideIcons.plus,
            onAction: _openCreateSale,
          ),
          onTap: _handleInvoiceTap,
          onLoadMore: () => setState(_invoiceAcc.loadMore),
          onRetry: () => ref.invalidate(invoicesListProvider),
        ),
      ),
    );
  }

  // ── PDF download ───────────────────────────────────────────────────────────

  void _downloadInvoicePdf(BuildContext context, String invoiceId) {
    AppToast.guard(
      context,
      () => ref.read(exportsServiceProvider).downloadInvoicePdf(invoiceId),
    );
  }

  // ── Invoice detail ─────────────────────────────────────────────────────────
  // Detalle tipo documento: ya alineado a los tokens de InfoCard (cs.*,
  // AppTheme.mono, PistoTokens.radiusCard); se mantiene tal cual.

  Future<void> _showInvoiceDetail(BuildContext context, Invoice invoice) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PistoTokens.radiusCard),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.customerName ?? 'Consumidor final',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${invoice.saleNumber} · ${formatDateDisplay(invoice.saleDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IntentChip(
                          label: invoice.paymentStatusLabel,
                          intent: switch (invoice.paymentStatus) {
                            'paid' => ChipIntent.success,
                            'credit' => ChipIntent.warning,
                            'overdue' => ChipIntent.danger,
                            _ => ChipIntent.neutral,
                          },
                          small: true,
                        ),
                        if (invoice.cancelled) ...[
                          const SizedBox(height: 4),
                          IntentChip(
                            label: invoice.statusLabel,
                            intent: ChipIntent.danger,
                            small: true,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final detailAsync = ref.watch(
                          invoiceDetailWithNamesProvider(invoice.id),
                        );
                        return AsyncValueWidget(
                          value: detailAsync,
                          onRetry: () => ref.invalidate(
                            invoiceDetailWithNamesProvider(invoice.id),
                          ),
                          data: (view) => _buildInvoiceDocument(
                            theme,
                            view.invoice,
                            view.productNames,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    if (invoice.status == 'completed') ...[
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmCancelSale(invoice);
                        },
                        icon: Icon(LucideIcons.ban, size: 16, color: cs.error),
                        label: Text(
                          'Anular',
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCreditNoteForm(invoice);
                        },
                        icon: const Icon(LucideIcons.fileMinus, size: 16),
                        label: const Text('Nota crédito'),
                      ),
                    ],
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _downloadInvoicePdf(context, invoice.id);
                      },
                      icon: const Icon(LucideIcons.fileDown, size: 16),
                      label: const Text('PDF'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Document-style body: compact line table + subtotal/VAT/total.
  Widget _buildInvoiceDocument(
    ThemeData theme,
    Invoice detail,
    Map<String, String> productNames,
  ) {
    final cs = theme.colorScheme;
    final lines = detail.lines ?? const <InvoiceItem>[];
    final taxAmount = double.parse(detail.taxAmount);
    final discountAmount = double.parse(detail.discountAmount);
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
    );

    Widget totalRow(
      String label,
      String value, {
      bool emphasized = false,
      Color? color,
    }) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(label, style: metaStyle),
            SizedBox(
              width: 110,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: AppTheme.mono(
                  fontSize: emphasized ? 16 : 12,
                  fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
                  color: color ?? cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Producto',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 90,
              child: Text(
                taxAmount > 0 ? 'Total c/IVA' : 'Total',
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productNames[line.productId] ?? 'Producto eliminado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${line.quantityValue.toStringAsFixed(line.quantityValue % 1 == 0 ? 0 : 2)}'
                        ' × ${_fmt.format(double.parse(line.unitPrice))}',
                        style: metaStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: Text(
                    _fmt.format(line.lineTotalValue),
                    textAlign: TextAlign.end,
                    style: AppTheme.mono(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 16),
        totalRow('Subtotal', _fmt.format(double.parse(detail.subtotal))),
        if (discountAmount > 0)
          totalRow('Descuento', '−${_fmt.format(discountAmount)}'),
        if (taxAmount > 0) totalRow('IVA', _fmt.format(taxAmount)),
        totalRow('Total', _fmt.format(detail.totalValue), emphasized: true),
      ],
    );
  }

  // ── Cancel sale ────────────────────────────────────────────────────────────

  void _confirmCancelSale(Invoice invoice) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Anular venta',
      description:
          '¿Anular la factura "${invoice.saleNumber}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Anular',
      icon: LucideIcons.ban,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final ok = await AppToast.guard(
      context,
      () => ref.read(saleMutationsProvider.notifier).cancel(invoice.id),
      successMessage: 'Factura anulada correctamente',
    );
    if (ok && mounted) setState(_invoiceAcc.reset);
  }

  // ── Credit note ────────────────────────────────────────────────────────────

  void _showCreditNoteForm(Invoice invoice) async {
    final theme = Theme.of(context);
    // The API requires the sale lines; they only come with the detail.
    final detail = await ref.read(invoiceDetailProvider(invoice.id).future);
    if (!mounted) return;

    final ok = await PFormDialog.show(
      context,
      title: 'Nota de crédito',
      header: Text(
        'Factura ${invoice.saleNumber} · ${_fmt.format(invoice.totalValue)}. '
        'La nota devuelve todas las líneas de la venta al inventario.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
      fields: const [
        PTextField(
          name: 'reason',
          label: 'Razón',
          required: true,
          maxLines: 2,
          autofocus: true,
        ),
      ],
      submitLabel: 'Crear',
      successMessage: 'Nota de crédito creada',
      onSubmit: (values) => ref
          .read(saleMutationsProvider.notifier)
          .createCreditNote(
            invoice.id,
            reason: values['reason'] as String,
            lines: detail.lines!,
          ),
    );
    if (ok && mounted) {
      setState(() {
        _invoiceAcc.reset();
        _creditNoteAcc.reset();
      });
    }
  }

  // ── Bulk mark paid ─────────────────────────────────────────────────────────

  void _bulkMarkPaid() async {
    final count = _selectedIds.length;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Marcar como pagadas',
      description:
          '¿Marcar $count factura${count == 1 ? '' : 's'} como pagadas?',
      confirmLabel: 'Confirmar',
      icon: LucideIcons.circleCheck,
      destructive: false,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
      _invoiceAcc.reset();
    });
    AppToast.success(
      context,
      '$count factura${count == 1 ? '' : 's'} marcada${count == 1 ? '' : 's'} como pagadas',
    );
    ref.invalidate(invoicesListProvider);
  }

  // ── Customers tab ──────────────────────────────────────────────────────────

  List<DataListColumn<Customer>> _customerColumns(
    ThemeData theme,
    ColorScheme cs,
  ) => [
    DataListColumn<Customer>(
      label: 'Nombre',
      flex: 3,
      cell: (context, c) => Text(
        c.displayName.isEmpty ? 'Sin nombre' : c.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    DataListColumn<Customer>(
      label: 'Contacto',
      flex: 3,
      cell: (context, c) => Text(
        c.contact.isEmpty ? '—' : c.contact,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    DataListColumn<Customer>(
      label: 'Crédito',
      flex: 2,
      isMoney: true,
      cell: (context, c) => MoneyValue(
        formatted: c.creditLimitValue > 0
            ? _fmt.format(c.creditLimitValue)
            : '—',
        size: MoneySize.small,
      ),
    ),
    DataListColumn<Customer>(
      label: 'Términos',
      flex: 2,
      cell: (context, c) => Text(
        c.creditDays > 0 ? '${c.creditDays} días' : 'Contado',
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
    ),
  ];

  Widget _buildCustomersTab(
    ThemeData theme,
    ColorScheme cs,
    double hPad,
    AsyncValue<Paginated<Customer>> async,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
          child: Row(
            children: [
              Expanded(
                child: SearchField(
                  hint: 'Buscar clientes...',
                  onChanged: (v) => setState(() {
                    _customerSearch = v;
                    _customerAcc.reset();
                  }),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _openCreateCustomer,
                icon: const Icon(LucideIcons.userPlus, size: 14),
                label: const Text('Nuevo cliente'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
            child: InfoCard(
              padding: EdgeInsets.zero,
              child: _PagedTab<Customer>(
                async: async,
                acc: _customerAcc,
                columns: _customerColumns(theme, cs),
                emptyState: _customerSearch.isEmpty
                    ? EmptyState(
                        icon: LucideIcons.users,
                        title: 'Aún no tenés clientes',
                        description:
                            'Agregá tu primer cliente para empezar a facturar a su nombre y llevar el seguimiento de sus pagos.',
                        actionLabel: 'Nuevo cliente',
                        actionIcon: LucideIcons.userPlus,
                        onAction: _openCreateCustomer,
                      )
                    : EmptyState(
                        icon: LucideIcons.users,
                        title: 'Sin resultados',
                        description:
                            'No encontramos clientes que coincidan con "$_customerSearch".',
                      ),
                onTap: (c) => _guardDialog(() => _showEditCustomerForm(c)),
                onLoadMore: () => setState(_customerAcc.loadMore),
                onRetry: () => ref.invalidate(customersListProvider),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Edit customer ──────────────────────────────────────────────────────────

  Future<void> _showEditCustomerForm(Customer customer) async {
    final updated = await SidePanelForm.show(
      context,
      title: 'Editar cliente',
      fields: _customerFields(existing: customer),
      successMessage: 'Cliente actualizado',
      onSubmit: (values) => ref
          .read(customerMutationsProvider.notifier)
          .update(
            customer.id,
            firstName: values['firstName'] as String?,
            lastName: values['lastName'] as String?,
            companyName: values['companyName'] as String?,
            email: values['email'] as String?,
            phone: values['phone'] as String?,
          ),
    );
    if (updated && mounted) setState(_customerAcc.reset);
  }

  // ── Credit notes tab ───────────────────────────────────────────────────────

  List<DataListColumn<CreditNote>> _creditNoteColumns(
    ThemeData theme,
    ColorScheme cs,
  ) => [
    DataListColumn<CreditNote>(
      label: 'Nº',
      flex: 2,
      cell: (context, cn) => Text(
        cn.noteNumber,
        style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),
    DataListColumn<CreditNote>(
      label: 'Razón',
      flex: 3,
      cell: (context, cn) => Text(
        cn.reason.isEmpty ? '—' : cn.reason,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    DataListColumn<CreditNote>(
      label: 'Fecha',
      flex: 2,
      cell: (context, cn) => Text(
        formatDateShortEs(cn.createdAt.toIso8601String()),
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
    ),
    DataListColumn<CreditNote>(
      label: 'Estado',
      flex: 2,
      cell: (context, cn) => IntentChip(
        label: cn.statusLabel,
        intent: cn.status == 'cancelled'
            ? ChipIntent.danger
            : ChipIntent.neutral,
        small: true,
      ),
    ),
    DataListColumn<CreditNote>(
      label: 'Total',
      flex: 2,
      isMoney: true,
      cell: (context, cn) => MoneyValue(
        formatted: '−${_fmt.format(cn.totalValue)}',
        size: MoneySize.small,
        color: context.tokens.dangerText,
      ),
    ),
  ];

  Widget _buildCreditNotesTab(
    ThemeData theme,
    ColorScheme cs,
    double hPad,
    AsyncValue<Paginated<CreditNote>> async,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: _PagedTab<CreditNote>(
          async: async,
          acc: _creditNoteAcc,
          columns: _creditNoteColumns(theme, cs),
          emptyState: const EmptyState.compact(
            title: 'Sin notas de crédito',
            description:
                'Cuando emitas una nota de crédito sobre una factura, aparecerá acá con su monto descontado.',
          ),
          onLoadMore: () => setState(_creditNoteAcc.loadMore),
          onRetry: () => ref.invalidate(creditNotesListProvider),
        ),
      ),
    );
  }
}

// ── Customer form: reactive type + name ─────────────────────────────────────

/// Type selector (person/company) + corresponding name fields.
/// While editing, the type stays fixed (an existing customer can't be migrated).
class _CustomerTypeFields extends StatefulWidget {
  final Customer? existing;
  const _CustomerTypeFields({required this.existing});

  @override
  State<_CustomerTypeFields> createState() => _CustomerTypeFieldsState();
}

class _CustomerTypeFieldsState extends State<_CustomerTypeFields> {
  late String _type = widget.existing?.customerType ?? 'person';

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.existing == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isCreate) ...[
          PSelectField<String>(
            name: 'customerType',
            label: 'Tipo',
            initialValue: _type,
            options: const [
              PSelectOption('person', 'Persona'),
              PSelectOption('company', 'Empresa'),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'person'),
          ),
          const SizedBox(height: 16),
        ],
        if (_type == 'company')
          PTextField(
            name: 'companyName',
            label: 'Nombre empresa',
            initialValue: widget.existing?.companyName,
            required: true,
          )
        else
          Row(
            children: [
              Expanded(
                child: PTextField(
                  name: 'firstName',
                  label: 'Nombre',
                  initialValue: widget.existing?.firstName,
                  required: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PTextField(
                  name: 'lastName',
                  label: 'Apellido',
                  initialValue: widget.existing?.lastName,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ── Accumulated pagination ──────────────────────────────────────────────────
// The listing providers are page-indexed (they return only the requested
// page, they don't accumulate). This helper keeps the "Cargar más" state on
// the screen without touching the providers: each new page stacks on top of
// the previous one and gets passed to `DataList` as if it were a single `Paginated`.

class _PagedAccumulator<T> {
  int requestPage = 1;
  int? _mergedPage;
  List<T> items = [];
  PageMeta? meta;
  bool loadingMore = false;

  void reset() {
    requestPage = 1;
    _mergedPage = null;
    items = [];
    meta = null;
    loadingMore = false;
  }

  void loadMore() {
    loadingMore = true;
    requestPage++;
  }

  /// Applies a resolved page; returns `true` if the state changed (avoids
  /// reprocessing the same `AsyncData` on unrelated rebuilds).
  bool merge(Paginated<T> page) {
    if (_mergedPage == page.meta.page) return false;
    _mergedPage = page.meta.page;
    items = page.meta.page <= 1 ? List.of(page.data) : [...items, ...page.data];
    meta = page.meta;
    loadingMore = false;
    return true;
  }

  Paginated<T>? get view =>
      meta == null ? null : Paginated(data: items, meta: meta!);
}

/// Paginated list tab: with no accumulated data yet it delegates to
/// [AsyncValueWidget] (loading/error); once the first page is in hand,
/// `DataList` handles its own skeleton/empty/footer.
class _PagedTab<T> extends StatelessWidget {
  final AsyncValue<Paginated<T>> async;
  final _PagedAccumulator<T> acc;
  final List<DataListColumn<T>> columns;
  final Widget emptyState;
  final void Function(T item)? onTap;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  const _PagedTab({
    required this.async,
    required this.acc,
    required this.columns,
    required this.emptyState,
    this.onTap,
    required this.onLoadMore,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (acc.items.isNotEmpty) {
      return DataList<T>(
        columns: columns,
        data: acc.view,
        emptyState: emptyState,
        onTap: onTap,
        onLoadMore: onLoadMore,
        loadingMore: acc.loadingMore,
      );
    }
    return AsyncValueWidget<Paginated<T>>(
      value: async,
      onRetry: onRetry,
      loading: DataList<T>(
        columns: columns,
        data: null,
        loading: true,
        emptyState: emptyState,
      ),
      data: (_) => DataList<T>(
        columns: columns,
        data: acc.view,
        emptyState: emptyState,
        onTap: onTap,
        onLoadMore: onLoadMore,
        loadingMore: acc.loadingMore,
      ),
    );
  }
}
