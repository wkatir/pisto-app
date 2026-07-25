import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/invoice.dart';
import '../models/lookups.dart';
import '../providers/sales_providers.dart';

class CreateSaleScreen extends ConsumerStatefulWidget {
  final String? initialCustomerId;

  const CreateSaleScreen({super.key, this.initialCustomerId});

  @override
  ConsumerState<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends ConsumerState<CreateSaleScreen> {
  final List<SaleLineInput> _lines = [];
  String? _selectedWarehouseId;
  String? _selectedCustomerId;
  String _paymentStatus = 'paid';
  String? _selectedPaymentMethodId;
  String? _selectedDocumentTypeId;
  bool _submitting = false;
  bool _defaultsApplied = false;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
  }

  double get _total => _lines.fold(0, (sum, l) => sum + l.total);

  void _applyDefaults(SaleFormData data) {
    if (_defaultsApplied) return;
    _defaultsApplied = true;
    if (data.warehouses.isNotEmpty) {
      _selectedWarehouseId = data.warehouses.first.id;
    }
    if (data.paymentMethods.isNotEmpty) {
      _selectedPaymentMethodId = data.paymentMethods.first.id;
    }
    if (data.documentTypes.isNotEmpty) {
      _selectedDocumentTypeId = data.documentTypes.first.id;
    }
  }

  Future<void> _submit(SaleFormData data) async {
    if (_lines.isEmpty || _selectedWarehouseId == null) return;
    if (_selectedDocumentTypeId == null) {
      AppToast.show(context,
          message: 'Selecciona un tipo de documento', type: ToastType.warning);
      return;
    }
    if (_paymentStatus == 'paid' && _selectedPaymentMethodId == null) {
      AppToast.show(context,
          message: 'Selecciona un método de pago', type: ToastType.warning);
      return;
    }

    if (_paymentStatus == 'credit' && _selectedCustomerId != null) {
      final customer = data.customers
          .where((c) => c.id == _selectedCustomerId)
          .firstOrNull;
      // Advisory only: if the statement hasn't loaded yet, the sale still proceeds.
      final statement = ref
          .read(customerStatementProvider(_selectedCustomerId!))
          .value;
      final limit = customer?.creditLimitValue ?? 0;
      if (statement != null && limit > 0) {
        final balance = statement.totalPending;
        if (balance + _total > limit) {
          AppToast.show(
            context,
            message:
                'Advertencia: este cliente tiene ${currencyFmt.format(balance)} pendiente '
                'y un límite de ${currencyFmt.format(limit)}. Esta venta excedería su crédito.',
            type: ToastType.warning,
            duration: const Duration(seconds: 4),
          );
        }
      }
    }

    setState(() => _submitting = true);
    final ok = await AppToast.guard(
      context,
      () => ref.read(saleMutationsProvider.notifier).create(
            customerId: _selectedCustomerId,
            documentTypeId: _selectedDocumentTypeId!,
            warehouseId: _selectedWarehouseId!,
            paymentStatus: _paymentStatus,
            paymentMethodId: _selectedPaymentMethodId,
            lines: _lines,
          ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formDataAsync = ref.watch(saleFormDataProvider);
    if (_selectedCustomerId != null && _paymentStatus == 'credit') {
      // Preloads the statement for the credit-limit warning.
      ref.watch(customerStatementProvider(_selectedCustomerId!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva venta'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _submitting || formDataAsync.value == null
                  ? null
                  : () => _submit(formDataAsync.value!),
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar'),
            ),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: formDataAsync,
        onRetry: () => ref.invalidate(saleFormDataProvider),
        data: (data) {
          _applyDefaults(data);
          return _buildForm(context, data);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, SaleFormData data) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < Breakpoints.formStack;
              final fieldWidth = isNarrow ? constraints.maxWidth : 200.0;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedWarehouseId,
                      decoration: const InputDecoration(labelText: 'Bodega'),
                      items: [
                        for (final w in data.warehouses)
                          DropdownMenuItem(value: w.id, child: Text(w.name)),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedWarehouseId = v),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: _selectedCustomerId,
                      decoration:
                          const InputDecoration(labelText: 'Cliente (opcional)'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Sin cliente')),
                        for (final c in data.customers)
                          DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.displayName.isEmpty
                                  ? 'Sin nombre'
                                  : c.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedCustomerId = v),
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _paymentStatus,
                      decoration: const InputDecoration(labelText: 'Tipo pago'),
                      items: const [
                        DropdownMenuItem(value: 'paid', child: Text('Contado')),
                        DropdownMenuItem(
                            value: 'credit', child: Text('Crédito')),
                      ],
                      onChanged: (v) =>
                          setState(() => _paymentStatus = v ?? 'paid'),
                    ),
                  ),
                  if (data.paymentMethods.isNotEmpty)
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedPaymentMethodId,
                        decoration:
                            const InputDecoration(labelText: 'Método de pago'),
                        items: [
                          for (final pm in data.paymentMethods)
                            DropdownMenuItem(
                                value: pm.id, child: Text(pm.name)),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedPaymentMethodId = v),
                      ),
                    ),
                  if (data.documentTypes.isNotEmpty)
                    SizedBox(
                      width: fieldWidth,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedDocumentTypeId,
                        decoration: const InputDecoration(
                            labelText: 'Tipo de documento'),
                        items: [
                          for (final dt in data.documentTypes)
                            DropdownMenuItem(
                                value: dt.id,
                                child: Text(dt.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedDocumentTypeId = v),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Líneas',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _guardDialog(() => _showProductPicker(data)),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_lines.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text('Agrega productos a la venta',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            )
          else
            for (final (i, line) in _lines.indexed)
              _buildLineCard(context, data, i, line),
          const Divider(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: MoneyValue(
              formatted: currencyFmt.format(_total),
              size: MoneySize.large,
              label: 'Total',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineCard(
      BuildContext context, SaleFormData data, int index, SaleLineInput line) {
    final theme = Theme.of(context);
    // Every line originates from the picker, so the product is guaranteed to be in the catalog.
    final product = data.products.firstWhere((p) => p.id == line.productId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InfoCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    '${currencyFmt.format(line.unitPrice)} x ${line.quantity.toStringAsFixed(2)}'
                    '${line.discountPct > 0 ? ' (−${line.discountPct.toStringAsFixed(0)}%)' : ''}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            MoneyValue(formatted: currencyFmt.format(line.total), size: MoneySize.small),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(LucideIcons.pencil, size: 18),
                onPressed: () => _guardDialog(() => _showLineDialog(data,
                    product: product, existingIndex: index))),
            IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: () => setState(() => _lines.removeAt(index))),
          ],
        ),
      ),
    );
  }

  /// Serializes the line-flow dialogs: a double click (or a semantic
  /// activation on web) can't stack two modals.
  Future<void> _guardDialog(Future<void> Function() open) async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    try {
      await open();
    } finally {
      _dialogOpen = false;
    }
  }

  Future<void> _showProductPicker(SaleFormData data) async {
    if (data.products.isEmpty) {
      AppToast.show(context,
          message: 'No hay productos en inventario. Agregá productos primero.',
          type: ToastType.warning);
      return;
    }
    final selected = await showDialog<ProductRef>(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Text('Seleccionar producto',
                      style: Theme.of(ctx).textTheme.titleLarge),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.products.length,
                    itemBuilder: (context, i) {
                      final p = data.products[i];
                      return ListTile(
                        title: Text(p.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('SKU: ${p.sku ?? 'N/A'}'),
                        trailing: SizedBox(
                          width: 80,
                          child: Text(
                            currencyFmt.format(p.salePriceValue),
                            style: AppTheme.mono(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        onTap: () => Navigator.pop(ctx, p),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    await _showLineDialog(data, product: selected);
  }

  /// Create (no [existingIndex]) or edit a line.
  Future<void> _showLineDialog(SaleFormData data,
      {required ProductRef product, int? existingIndex}) async {
    final existing = existingIndex != null ? _lines[existingIndex] : null;
    final qtyCtrl = TextEditingController(
        text: existing?.quantity.toStringAsFixed(2) ?? '1');
    final priceCtrl = TextEditingController(
        text: (existing?.unitPrice ?? product.salePriceValue)
            .toStringAsFixed(2));
    final discCtrl = TextEditingController(
        text: existing?.discountPct.toStringAsFixed(0) ?? '0');
    String? selectedTaxId = existing?.taxId;
    double discountPct = existing?.discountPct ?? 0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
              '${existing == null ? 'Agregar' : 'Editar'} ${product.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Precio unitario', prefixText: '\$ '),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: discCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Descuento (%)'),
                  onChanged: (v) {
                    final n = double.tryParse(v) ?? 0;
                    setDialogState(() => discountPct = n.clamp(0, 100));
                  },
                ),
                if (data.taxes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    initialValue: selectedTaxId,
                    decoration: const InputDecoration(
                        labelText: 'Impuesto (opcional)'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Sin impuesto')),
                      for (final t in data.taxes)
                        DropdownMenuItem(
                            value: t.id,
                            child: Text('${t.name} (${t.rate}%)')),
                    ],
                    onChanged: (v) => setDialogState(() => selectedTaxId = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final qty = double.tryParse(qtyCtrl.text) ?? 1;
                final price = double.tryParse(priceCtrl.text) ?? 0;
                if (qty <= 0 || price <= 0) {
                  AppToast.show(ctx,
                      message: 'Cantidad y precio deben ser mayores a 0',
                      type: ToastType.warning);
                  return;
                }
                final line = SaleLineInput(
                  productId: product.id,
                  quantity: qty,
                  unitPrice: price,
                  discountPct: discountPct,
                  taxId: selectedTaxId,
                );
                setState(() {
                  if (existingIndex != null) {
                    _lines[existingIndex] = line;
                  } else {
                    _lines.add(line);
                  }
                });
                Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
