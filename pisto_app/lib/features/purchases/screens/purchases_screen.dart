import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/models/paginated.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/forms/forms.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/payable.dart';
import '../models/purchase_order.dart';
import '../models/supplier.dart';
import '../models/goods_receipt.dart';
import '../providers/purchases_providers.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  int _tabIndex = 0;

  final _orderAcc = _PagedAccumulator<PurchaseOrder>();
  final _payableAcc = _PagedAccumulator<PayableRow>();

  final _fmt = currencyFmt;

  /// Applies a freshly resolved `AsyncData` to its accumulator.
  void _consume<T>(AsyncValue<Paginated<T>> next, _PagedAccumulator<T> acc) {
    next.whenData((p) {
      if (acc.merge(p)) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;

    final ordersAsync =
        ref.watch(purchaseOrdersListProvider(page: _orderAcc.requestPage));
    ref.listen(purchaseOrdersListProvider(page: _orderAcc.requestPage),
        (_, next) => _consume(next, _orderAcc));
    final suppliersAsync = ref.watch(suppliersListProvider);
    final payablesAsync =
        ref.watch(payablesListProvider(page: _payableAcc.requestPage));
    ref.listen(payablesListProvider(page: _payableAcc.requestPage),
        (_, next) => _consume(next, _payableAcc));

    final ordersTotal = _orderAcc.meta?.total ?? 0;
    final suppliersTotal = suppliersAsync.value?.length ?? 0;
    final payablesTotal = _payableAcc.meta?.total ?? 0;
    final totalPayable = _payableAcc.items.fold<double>(
        0, (sum, row) => sum + row.payable.balanceValue);
    final payablesScoped = payablesTotal > _payableAcc.items.length;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: PageHeader(
              title: 'Tus compras',
              metrics: [
                MetricChip(label: 'Órdenes', value: '$ordersTotal'),
                MetricChip(label: 'Proveedores', value: '$suppliersTotal'),
              ],
              actions: [
                OutlinedButton.icon(
                  onPressed: _showSupplierForm,
                  icon: const Icon(LucideIcons.building2, size: 14),
                  label: const Text('Nuevo proveedor'),
                ),
                FilledButton.icon(
                  onPressed: _showOrderForm,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Nueva orden'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: BigFigure(
              label: 'Debés a proveedores',
              value: _fmt.format(totalPayable),
              valueColor: totalPayable > 0 ? context.tokens.warningText : null,
              caption: payablesScoped ? 'de las cargadas' : null,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: PTabs(
              tabs: [
                PTabItem('Órdenes', count: ordersTotal),
                PTabItem('Proveedores', count: suppliersTotal),
                PTabItem('Por pagar', count: payablesTotal),
              ],
              index: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: KeyedSubtree(
                key: ValueKey(_tabIndex),
                child: switch (_tabIndex) {
                  0 => _buildOrdersTab(theme, isWide, ordersAsync,
                      suppliersAsync.value ?? const []),
                  1 => AsyncValueWidget(
                      value: suppliersAsync,
                      loading: _suppliersSkeleton(),
                      onRetry: () => ref.invalidate(suppliersListProvider),
                      data: (suppliers) => _buildSuppliersTab(
                          theme, isWide, suppliers, _payableAcc.view),
                    ),
                  _ => _buildPayablesTab(theme, isWide, payablesAsync),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Orders tab ─────────────────────────────────────────────────────────────

  List<DataListColumn<PurchaseOrder>> _orderColumns(
          Map<String, String> supplierNames) =>
      [
        DataListColumn(
          label: 'Nº',
          flex: 2,
          cell: (context, o) => Text(
            o.orderNumber,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataListColumn(
          label: 'Proveedor',
          flex: 3,
          cell: (context, o) => Text(
            supplierNames[o.supplierId] ?? '—',
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataListColumn(
          label: 'Fecha',
          flex: 2,
          cell: (context, o) => Text(
            formatDateShortEs(o.orderDate),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        DataListColumn(
          label: 'Estado',
          flex: 2,
          cell: (context, o) =>
              StatusChip(status: o.status, type: StatusType.order),
        ),
        DataListColumn(
          label: 'Total',
          flex: 2,
          isMoney: true,
          cell: (context, o) => Text(
            _fmt.format(o.totalValue),
            style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ];

  Widget _buildOrdersTab(ThemeData theme, bool isWide,
      AsyncValue<Paginated<PurchaseOrder>> async, List<Supplier> suppliers) {
    final supplierNames = {for (final s in suppliers) s.id: s.companyName};
    final padX = isWide ? 32.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: _PagedTab<PurchaseOrder>(
          async: async,
          acc: _orderAcc,
          columns: _orderColumns(supplierNames),
          emptyState: EmptyState(
            icon: LucideIcons.clipboardList,
            title: 'Sin órdenes de compra',
            description:
                'Creá una orden a un proveedor para registrar lo que vas a recibir y mantener tu inventario al día.',
            actionLabel: 'Nueva orden',
            actionIcon: LucideIcons.plus,
            onAction: _showOrderForm,
          ),
          onTap: (o) => _showOrderDetail(o, supplierNames[o.supplierId] ?? ''),
          onLoadMore: () => setState(_orderAcc.loadMore),
          onRetry: () => ref.invalidate(purchaseOrdersListProvider),
        ),
      ),
    );
  }

  // ── Order detail ───────────────────────────────────────────────────────────

  /// Document-style body: compact line table + subtotal/VAT/total,
  /// same pattern as the sales invoice detail.
  Widget _buildOrderDocument(ThemeData theme, PurchaseOrder detail) {
    final cs = theme.colorScheme;
    final lines = detail.lines ?? const <PurchaseOrderItem>[];
    final taxAmount = double.parse(detail.taxAmount);
    final metaStyle =
        theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);

    Widget totalRow(String label, String value, {bool emphasized = false}) {
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
        if (lines.isEmpty)
          Text('Sin líneas',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant))
        else ...[
          Row(
            children: [
              Expanded(
                  child: Text('Producto',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant))),
              SizedBox(
                width: 90,
                child: Text(
                  'Total',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
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
                          '${line.quantityOrderedValue.toStringAsFixed(line.quantityOrderedValue % 1 == 0 ? 0 : 2)}'
                          ' × ${_fmt.format(line.unitCostValue)}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        if (line.quantityReceivedValue > 0)
                          Text(
                            'recibido ${line.quantityReceivedValue.toStringAsFixed(0)}',
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
                      style: AppTheme.mono(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const Divider(height: 16),
        totalRow('Subtotal', _fmt.format(double.parse(detail.subtotal))),
        if (taxAmount > 0) totalRow('IVA', _fmt.format(taxAmount)),
        totalRow('Total', _fmt.format(detail.totalValue), emphasized: true),
      ],
    );
  }

  void _showOrderDetail(PurchaseOrder order, String supplierName) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PistoTokens.radiusCard)),
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
                            supplierName.isEmpty ? 'Proveedor' : supplierName,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${order.orderNumber} · ${formatDateDisplay(order.orderDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusChip(status: order.status, type: StatusType.order),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final detailAsync =
                            ref.watch(purchaseOrderDetailProvider(order.id));
                        return AsyncValueWidget(
                          value: detailAsync,
                          onRetry: () =>
                              ref.invalidate(purchaseOrderDetailProvider(order.id)),
                          data: (detail) => _buildOrderDocument(theme, detail),
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
                    if (order.canReceive)
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showReceiveGoodsForm(order);
                        },
                        icon: const Icon(LucideIcons.packageCheck, size: 16),
                        label: const Text('Recibir mercadería'),
                      ),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cerrar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Receive goods ──────────────────────────────────────────────────────────

  void _showReceiveGoodsForm(PurchaseOrder order) async {
    final theme = Theme.of(context);
    // The API requires the pending lines; they only come with the detail.
    final detail =
        await ref.read(purchaseOrderDetailProvider(order.id).future);
    if (!mounted) return;

    final pending = [
      for (final l in detail.lines ?? <PurchaseOrderItem>[])
        if (l.quantityPending > 0) l,
    ];
    if (pending.isEmpty) {
      AppToast.error(
          context, 'La orden no tiene líneas pendientes de recibir');
      return;
    }

    await PFormDialog.show(
      context,
      title: 'Recibir mercadería',
      header: Text(
        'Orden ${order.orderNumber} · se recibirá todo lo pendiente '
        '(${pending.length} línea${pending.length == 1 ? '' : 's'}) y entrará al inventario.',
        style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant, height: 1.4),
      ),
      fields: const [
        PTextField(name: 'notes', label: 'Notas de recepción', maxLines: 3),
      ],
      submitLabel: 'Confirmar recepción',
      successMessage: 'Mercadería recibida',
      onSubmit: (values) =>
          ref.read(purchasesMutationsProvider.notifier).receiveGoods(
        order.id,
        notes: values['notes'] as String?,
        lines: [
          for (final l in pending)
            ReceiptLineInput(
              purchaseOrderLineId: l.id,
              productId: l.productId,
              quantityReceived: l.quantityPending,
            ),
        ],
      ),
    );
  }

  // ── Create order ───────────────────────────────────────────────────────────

  void _showOrderForm() async {
    final formData = await ref.read(purchaseFormDataProvider.future);
    if (!mounted) return;

    if (formData.suppliers.isEmpty) {
      AppToast.error(context, 'Creá un proveedor antes de hacer una orden');
      return;
    }

    await PFormDialog.show(
      context,
      title: 'Nueva orden de compra',
      fields: [
        PSelectField<String>(
          name: 'supplierId',
          label: 'Proveedor',
          required: true,
          options: [
            for (final s in formData.suppliers)
              PSelectOption(s.id, s.companyName),
          ],
        ),
        if (formData.warehouses.length > 1)
          PSelectField<String>(
            name: 'warehouseId',
            label: 'Bodega',
            initialValue: formData.warehouses.first.id,
            options: [
              for (final w in formData.warehouses) PSelectOption(w.id, w.name),
            ],
          ),
        // The API accepts orders with no lines, but with no lines the receipt
        // is impossible (receive requires lines >= 1); we require at least one product.
        PSelectField<String>(
          name: 'productId',
          label: 'Producto',
          required: true,
          options: [
            for (final p in formData.products) PSelectOption(p.id, p.name),
          ],
        ),
        PTextField(
          name: 'quantity',
          label: 'Cantidad',
          required: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.isEmpty) return null;
            final n = double.tryParse(v);
            return (n == null || n <= 0) ? 'Cantidad inválida' : null;
          },
        ),
        const PMoneyField(
          name: 'unitCost',
          label: 'Costo unitario',
          required: true,
          positive: true,
        ),
        const PTextField(name: 'notes', label: 'Notas', maxLines: 2),
      ],
      submitLabel: 'Crear',
      successMessage: 'Orden creada',
      onSubmit: (values) =>
          ref.read(purchasesMutationsProvider.notifier).createOrder(
        supplierId: values['supplierId'] as String,
        warehouseId: values['warehouseId'] as String?,
        notes: values['notes'] as String?,
        lines: [
          PurchaseLineInput(
            productId: values['productId'] as String,
            quantity: double.parse(values['quantity'] as String),
            unitCost: double.parse(values['unitCost'] as String),
          ),
        ],
      ),
    );
  }

  // ── Suppliers tab ──────────────────────────────────────────────────────────

  List<DataListColumn<Supplier>> _supplierColumns(
          Map<String, double> balanceBySupplier) =>
      [
        DataListColumn(
          label: 'Nombre',
          flex: 3,
          cell: (context, s) => Text(
            s.companyName,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataListColumn(
          label: 'Contacto',
          flex: 3,
          cell: (context, s) => Text(
            s.contact.isEmpty ? '—' : s.contact,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataListColumn(
          label: 'Saldo',
          flex: 2,
          isMoney: true,
          cell: (context, s) {
            final balance = balanceBySupplier[s.id] ?? 0;
            return Text(
              _fmt.format(balance),
              style: AppTheme.mono(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: balance > 0 ? context.tokens.warning : null,
              ),
            );
          },
        ),
      ];

  Widget _suppliersSkeleton() => DataList<Supplier>(
        columns: _supplierColumns(const {}),
        data: null,
        loading: true,
        emptyState: const SizedBox.shrink(),
      );

  Widget _buildSuppliersTab(ThemeData theme, bool isWide,
      List<Supplier> suppliers, Paginated<PayableRow>? payablesPage) {
    final padX = isWide ? 32.0 : 20.0;

    // Approximated with the already-loaded "por pagar" page: avoids another call.
    final balanceBySupplier = <String, double>{};
    for (final row in payablesPage?.data ?? const <PayableRow>[]) {
      if (row.payable.isPaid) continue;
      balanceBySupplier.update(
        row.payable.supplierId,
        (v) => v + row.payable.balanceValue,
        ifAbsent: () => row.payable.balanceValue,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: DataList<Supplier>(
        columns: _supplierColumns(balanceBySupplier),
        data: Paginated(
          data: suppliers,
          meta: PageMeta(
            page: 1,
            limit: suppliers.length,
            total: suppliers.length,
            totalPages: 1,
          ),
        ),
        emptyState: EmptyState(
          icon: LucideIcons.building2,
          title: 'Sin proveedores',
          description:
              'Agregá tus proveedores para llevar el control de las órdenes y los pagos pendientes con cada uno.',
          actionLabel: 'Nuevo proveedor',
          actionIcon: LucideIcons.plus,
          onAction: _showSupplierForm,
        ),
          onTap: _showEditSupplierForm,
        ),
      ),
    );
  }

  // ── Supplier forms ─────────────────────────────────────────────────────────

  List<Widget> _supplierFields(Supplier? supplier) => [
        PTextField(
          name: 'companyName',
          label: 'Nombre empresa',
          initialValue: supplier?.companyName,
          required: true,
          autofocus: supplier == null,
        ),
        PTextField(
          name: 'contactName',
          label: 'Contacto',
          initialValue: supplier?.contactName,
        ),
        PTextField(
          name: 'email',
          label: 'Email',
          initialValue: supplier?.email,
          keyboardType: TextInputType.emailAddress,
          validator: PValidators.email,
        ),
        PTextField(
          name: 'phone',
          label: 'Teléfono',
          initialValue: supplier?.phone,
          keyboardType: TextInputType.phone,
          validator: PValidators.phone,
        ),
      ];

  void _showSupplierForm() {
    PFormDialog.show(
      context,
      title: 'Nuevo proveedor',
      fields: _supplierFields(null),
      submitLabel: 'Crear',
      successMessage: 'Proveedor creado',
      onSubmit: (values) =>
          ref.read(purchasesMutationsProvider.notifier).createSupplier(
                companyName: values['companyName'] as String,
                contactName: values['contactName'] as String?,
                email: values['email'] as String?,
                phone: values['phone'] as String?,
              ),
    );
  }

  void _showEditSupplierForm(Supplier supplier) {
    PFormDialog.show(
      context,
      title: 'Editar proveedor',
      fields: _supplierFields(supplier),
      successMessage: 'Proveedor actualizado',
      onSubmit: (values) =>
          ref.read(purchasesMutationsProvider.notifier).updateSupplier(
                supplier.id,
                companyName: values['companyName'] as String?,
                contactName: values['contactName'] as String?,
                email: values['email'] as String?,
                phone: values['phone'] as String?,
              ),
    );
  }

  // ── Payables tab ───────────────────────────────────────────────────────────

  List<DataListColumn<PayableRow>> _payableColumns() => [
        DataListColumn(
          label: 'Proveedor',
          flex: 3,
          cell: (context, row) {
            final name = row.supplierName ?? '';
            return Text(
              name.isEmpty ? 'Proveedor' : name,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        DataListColumn(
          label: 'Vence',
          flex: 2,
          cell: (context, row) => Text(
            formatDateShortEs(row.payable.dueDate),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        DataListColumn(
          label: 'Estado',
          flex: 2,
          cell: (context, row) {
            final ap = row.payable;
            if (ap.isPaid) {
              return const IntentChip(
                  label: 'Pagada', intent: ChipIntent.success, small: true);
            }
            if (ap.isOverdue) {
              return const IntentChip(
                  label: 'Vencida', intent: ChipIntent.danger, small: true);
            }
            return const IntentChip(
                label: 'Pendiente', intent: ChipIntent.warning, small: true);
          },
        ),
        DataListColumn(
          label: 'Saldo',
          flex: 2,
          isMoney: true,
          cell: (context, row) {
            final ap = row.payable;
            final color = ap.isPaid
                ? null
                : (ap.isOverdue ? context.tokens.danger : context.tokens.warning);
            return Text(
              _fmt.format(ap.balanceValue),
              style: AppTheme.mono(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color),
            );
          },
        ),
      ];

  Widget _buildPayablesTab(
      ThemeData theme, bool isWide, AsyncValue<Paginated<PayableRow>> async) {
    final padX = isWide ? 32.0 : 20.0;
    final danger = theme.extension<PistoTokens>()!.danger;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: _PagedTab<PayableRow>(
          async: async,
          acc: _payableAcc,
          columns: _payableColumns(),
          emptyState: const EmptyState(
            icon: LucideIcons.circleCheck,
            title: 'No debés nada',
            description:
                'No hay cuentas por pagar a proveedores. Cuando recibas mercadería a crédito aparecerá acá.',
          ),
          rowAccentColor: (row) => row.payable.isOverdue ? danger : null,
          onTap: (row) {
            if (row.payable.isPaid) return;
            _showPaymentDialog(row.payable);
          },
          onLoadMore: () => setState(_payableAcc.loadMore),
          onRetry: () => ref.invalidate(payablesListProvider),
        ),
      ),
    );
  }

  // ── Payment ────────────────────────────────────────────────────────────────

  void _showPaymentDialog(Payable payable) async {
    final theme = Theme.of(context);
    final formData = await ref.read(purchaseFormDataProvider.future);
    if (!mounted) return;

    await PFormDialog.show(
      context,
      title: 'Registrar pago',
      header: Text(
        'Saldo: ${_fmt.format(payable.balanceValue)}',
        style: AppTheme.mono(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      fields: [
        PSelectField<String>(
          name: 'paymentMethodId',
          label: 'Método de pago',
          required: true,
          initialValue: formData.paymentMethods.isNotEmpty
              ? formData.paymentMethods.first.id
              : null,
          options: [
            for (final m in formData.paymentMethods)
              PSelectOption(m.id, m.name),
          ],
        ),
        PMoneyField(
          name: 'amount',
          label: 'Monto',
          initialValue: payable.balance,
          required: true,
          positive: true,
        ),
      ],
      submitLabel: 'Pagar',
      successMessage: 'Pago registrado',
      onSubmit: (values) =>
          ref.read(purchasesMutationsProvider.notifier).createPayment(
                payable.id,
                paymentMethodId: values['paymentMethodId'] as String,
                amount: values['amount'] as String,
              ),
    );
  }
}

// ── Accumulated pagination ──────────────────────────────────────────────────
// The listing providers are page-indexed (they return only the requested
// page, they don't accumulate). This helper keeps the "Cargar más" state on
// the screen without touching the providers: each new page stacks on top of
// the previous one and gets passed to `DataList` as if it were a single `Paginated`.
// Same pattern as `sales_screen.dart`: a product can't be paginated two
// different ways.

class _PagedAccumulator<T> {
  int requestPage = 1;
  int? _mergedPage;
  List<T> items = [];
  PageMeta? meta;
  bool loadingMore = false;

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

  Paginated<T>? get view => meta == null ? null : Paginated(data: items, meta: meta!);
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
  final Color? Function(T item)? rowAccentColor;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  const _PagedTab({
    required this.async,
    required this.acc,
    required this.columns,
    required this.emptyState,
    this.onTap,
    this.rowAccentColor,
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
        rowAccentColor: rowAccentColor,
        onLoadMore: onLoadMore,
        loadingMore: acc.loadingMore,
      );
    }
    return AsyncValueWidget<Paginated<T>>(
      value: async,
      onRetry: onRetry,
      loading: DataList<T>(columns: columns, data: null, loading: true, emptyState: emptyState),
      data: (_) => DataList<T>(
        columns: columns,
        data: acc.view,
        emptyState: emptyState,
        onTap: onTap,
        rowAccentColor: rowAccentColor,
        onLoadMore: onLoadMore,
        loadingMore: acc.loadingMore,
      ),
    );
  }
}
