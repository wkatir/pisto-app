import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';

class CreateSaleScreen extends ConsumerStatefulWidget {
  const CreateSaleScreen({super.key});

  @override
  ConsumerState<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends ConsumerState<CreateSaleScreen> {
  final List<_SaleLineItem> _lines = [];
  List<dynamic> _products = [];
  List<dynamic> _warehouses = [];
  List<dynamic> _customers = [];
  String? _selectedWarehouse;
  String? _selectedCustomer;
  String _paymentStatus = 'paid';
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _documentTypes = [];
  List<Map<String, dynamic>> _taxes = [];
  String? _selectedPaymentMethodId;
  String? _selectedDocumentTypeId;
  bool _loading = true;
  bool _submitting = false;

  Map<String, dynamic>? _selectedCustomerData;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final invSvc = ref.read(inventoryServiceProvider);
      final salesSvc = ref.read(salesServiceProvider);
      final results = await Future.wait([
        invSvc.listProducts(limit: 100),
        invSvc.listWarehouses(),
        salesSvc.listCustomers(limit: 100),
        salesSvc.listPaymentMethods(),
        salesSvc.listDocumentTypes(),
        salesSvc.listTaxes(),
      ]);
      setState(() {
        _products = ((results[0] as Map<String, dynamic>)['data'] as List<dynamic>?) ?? [];
        _warehouses = (results[1] as List<dynamic>?) ?? [];
        _customers = ((results[2] as Map<String, dynamic>)['data'] as List<dynamic>?) ?? [];
        _paymentMethods = results[3] as List<Map<String, dynamic>>;
        _documentTypes = results[4] as List<Map<String, dynamic>>;
        _taxes = results[5] as List<Map<String, dynamic>>;
        if (_warehouses.isNotEmpty) _selectedWarehouse = _warehouses[0]['id'] as String;
        if (_paymentMethods.isNotEmpty) _selectedPaymentMethodId = _paymentMethods.first['id'] as String;
        if (_documentTypes.isNotEmpty) _selectedDocumentTypeId = _documentTypes.first['id'] as String;
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

  Future<void> _loadCustomerData(String customerId) async {
    try {
      final collectionsService = ref.read(collectionsServiceProvider);
      final resp = await collectionsService.getCustomerStatement(customerId);
      if (mounted) setState(() => _selectedCustomerData = resp);
    } catch (e, st) {
      debugPrint('loadCustomerData failed: $e\n$st');
    }
  }

  double get _total => _lines.fold(0, (sum, l) => sum + l.total);

  Future<void> _submit() async {
    if (_lines.isEmpty || _selectedWarehouse == null) return;
    if (_selectedDocumentTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un tipo de documento')));
      return;
    }
    if (_paymentStatus == 'paid' && _selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un método de pago')));
      return;
    }

    if (_paymentStatus == 'credit' && _selectedCustomerData != null) {
      final limit = double.tryParse(_selectedCustomerData!['creditLimit']?.toString() ?? '0') ?? 0;
      final balance = double.tryParse(_selectedCustomerData!['totalPending']?.toString() ?? '0') ?? 0;
      if (limit > 0 && (balance + _total) > limit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Advertencia: Este cliente tiene \$${balance.toStringAsFixed(2)} pendiente '
              'y un límite de \$${limit.toStringAsFixed(2)}. Esta venta excedería su crédito.',
            ),
            backgroundColor: AppTheme.warning,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    setState(() => _submitting = true);
    try {
      await ref.read(salesServiceProvider).createSale({
        'documentTypeId': _selectedDocumentTypeId,
        'warehouseId': _selectedWarehouse,
        if (_selectedCustomer != null) 'customerId': _selectedCustomer,
        'paymentStatus': _paymentStatus,
        'lines': _lines.map((l) => {
          'productId': l.productId,
          'quantity': l.quantity.toStringAsFixed(2),
          'unitPrice': l.unitPrice.toStringAsFixed(2),
          if (l.taxId != null) 'taxId': l.taxId,
          if (l.discountPct > 0) 'discountPct': l.discountPct.toStringAsFixed(2),
        }).toList(),
        if (_paymentStatus == 'paid')
          'payments': [
            {'paymentMethodId': _selectedPaymentMethodId, 'amount': _total.toStringAsFixed(2)},
          ],
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.parseError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nueva Venta')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < Breakpoints.formStack;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: isNarrow ? constraints.maxWidth : 200,
                      child: DropdownButtonFormField<String>(
                isExpanded: true,
                        initialValue: _selectedWarehouse,
                        decoration: const InputDecoration(labelText: 'Bodega', border: OutlineInputBorder()),
                        items: _warehouses.map((w) => DropdownMenuItem(value: w['id'] as String, child: Text(w['name'] ?? ''))).toList(),
                        onChanged: (v) => setState(() => _selectedWarehouse = v),
                      ),
                    ),
                    SizedBox(
                      width: isNarrow ? constraints.maxWidth : 200,
                      child: DropdownButtonFormField<String?>(
                isExpanded: true,
                        initialValue: _selectedCustomer,
                        decoration: const InputDecoration(labelText: 'Cliente (opcional)', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Sin cliente')),
                          ..._customers.map((c) {
                            final name = c['companyName'] ?? '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim();
                            return DropdownMenuItem(value: c['id'] as String, child: Text(name.isEmpty ? 'Sin nombre' : name, overflow: TextOverflow.ellipsis));
                          }),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _selectedCustomer = v;
                            _selectedCustomerData = null;
                          });
                          if (v != null) _loadCustomerData(v);
                        },
                      ),
                    ),
                    SizedBox(
                      width: isNarrow ? constraints.maxWidth : 200,
                      child: DropdownButtonFormField<String>(
                isExpanded: true,
                        initialValue: _paymentStatus,
                        decoration: const InputDecoration(labelText: 'Tipo Pago', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'paid', child: Text('Contado')),
                          DropdownMenuItem(value: 'credit', child: Text('Crédito')),
                        ],
                        onChanged: (v) => setState(() => _paymentStatus = v ?? 'paid'),
                      ),
                    ),
                    if (_paymentMethods.isNotEmpty)
                      SizedBox(
                        width: isNarrow ? constraints.maxWidth : 200,
                        child: DropdownButtonFormField<String>(
                isExpanded: true,
                          initialValue: _selectedPaymentMethodId,
                          decoration: const InputDecoration(labelText: 'Método de pago', border: OutlineInputBorder()),
                          items: _paymentMethods.map((pm) => DropdownMenuItem(
                            value: pm['id'] as String,
                            child: Text(pm['name'] as String),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedPaymentMethodId = v),
                        ),
                      ),
                    if (_documentTypes.isNotEmpty)
                      SizedBox(
                        width: isNarrow ? constraints.maxWidth : 200,
                        child: DropdownButtonFormField<String>(
                isExpanded: true,
                          initialValue: _selectedDocumentTypeId,
                          decoration: const InputDecoration(labelText: 'Tipo de documento', border: OutlineInputBorder()),
                          items: _documentTypes.map((dt) => DropdownMenuItem(
                            value: dt['id'] as String,
                            child: Text(dt['name'] as String),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedDocumentTypeId = v),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Líneas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _addLine(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_lines.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Text('Agrega productos a la venta', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              )
            else
              ..._lines.asMap().entries.map((entry) {
                final i = entry.key;
                final line = entry.value;
                final product = _products.firstWhere((p) => p['id'] == line.productId, orElse: () => <String, dynamic>{});
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: theme.colorScheme.outlineVariant)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(
                                '\$${line.unitPrice.toStringAsFixed(2)} x ${line.quantity.toStringAsFixed(2)}'
                                '${line.discountPct > 0 ? ' (−${line.discountPct.toStringAsFixed(0)}%)' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Text('\$${line.total.toStringAsFixed(2)}', style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editLineDialog(i, line, product)),
                        IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _lines.removeAt(i))),
                      ],
                    ),
                  ),
                );
              }),
            const Divider(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${_total.toStringAsFixed(2)}',
                style: AppTheme.mono(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addLine() {
    if (_products.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Text('Seleccionar Producto', style: Theme.of(ctx).textTheme.titleLarge),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _products.length,
                    itemBuilder: (context, i) {
                      final p = _products[i];
                      return ListTile(
                        title: Text(p['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text('SKU: ${p['sku'] ?? 'N/A'}'),
                        trailing: SizedBox(
                          width: 80,
                          child: Text(
                            '\$${p['salePrice'] ?? '0.00'}',
                            style: AppTheme.mono(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showLineDialog(p);
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLineDialog(dynamic product) {
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController(text: (double.tryParse(product['salePrice']?.toString() ?? '0') ?? 0).toStringAsFixed(2));
    final discCtrl = TextEditingController(text: '0');
    String? selectedTaxId;
    double localDiscountPct = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Agregar ${product['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Precio Unitario', prefixText: '\$ ', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: discCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Descuento (%)', border: OutlineInputBorder()),
                  onChanged: (v) {
                    final n = double.tryParse(v) ?? 0;
                    setDialogState(() => localDiscountPct = n.clamp(0, 100));
                  },
                  validator: (v) {
                    final n = double.tryParse(v ?? '0') ?? 0;
                    if (n < 0 || n > 100) return 'Entre 0 y 100';
                    return null;
                  },
                ),
                if (_taxes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                isExpanded: true,
                    initialValue: selectedTaxId,
                    decoration: const InputDecoration(labelText: 'Impuesto (opcional)', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin impuesto')),
                      ..._taxes.map((t) => DropdownMenuItem(
                        value: t['id'] as String,
                        child: Text('${t['name']} (${t['rate']}%)'),
                      )),
                    ],
                    onChanged: (v) => setDialogState(() => selectedTaxId = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final qty = double.tryParse(qtyCtrl.text) ?? 1;
                final price = double.tryParse(priceCtrl.text) ?? 0;
                if (qty <= 0 || price <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Cantidad y precio deben ser mayores a 0')),
                  );
                  return;
                }
                setState(() {
                  _lines.add(_SaleLineItem(
                    productId: product['id'] as String,
                    unitPrice: price,
                    quantity: qty,
                    taxId: selectedTaxId,
                    discountPct: localDiscountPct,
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editLineDialog(int index, _SaleLineItem line, dynamic product) {
    final qtyCtrl = TextEditingController(text: line.quantity.toStringAsFixed(2));
    final priceCtrl = TextEditingController(text: line.unitPrice.toStringAsFixed(2));
    final discCtrl = TextEditingController(text: line.discountPct.toStringAsFixed(0));
    String? selectedTaxId = line.taxId;
    double localDiscountPct = line.discountPct;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Editar ${product['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Precio Unitario', prefixText: '\$ ', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: discCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Descuento (%)', border: OutlineInputBorder()),
                  onChanged: (v) {
                    final n = double.tryParse(v) ?? 0;
                    setDialogState(() => localDiscountPct = n.clamp(0, 100));
                  },
                  validator: (v) {
                    final n = double.tryParse(v ?? '0') ?? 0;
                    if (n < 0 || n > 100) return 'Entre 0 y 100';
                    return null;
                  },
                ),
                if (_taxes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                isExpanded: true,
                    initialValue: selectedTaxId,
                    decoration: const InputDecoration(labelText: 'Impuesto (opcional)', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin impuesto')),
                      ..._taxes.map((t) => DropdownMenuItem(
                        value: t['id'] as String,
                        child: Text('${t['name']} (${t['rate']}%)'),
                      )),
                    ],
                    onChanged: (v) => setDialogState(() => selectedTaxId = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final qty = double.tryParse(qtyCtrl.text) ?? 1;
                final price = double.tryParse(priceCtrl.text) ?? 0;
                if (qty <= 0 || price <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Cantidad y precio deben ser mayores a 0')),
                  );
                  return;
                }
                setState(() {
                  _lines[index] = line.copyWith(
                    quantity: qty,
                    unitPrice: price,
                    taxId: selectedTaxId,
                    discountPct: localDiscountPct,
                  );
                });
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleLineItem {
  final String productId;
  final double unitPrice;
  final double quantity;
  final String? taxId;
  final double discountPct;

  _SaleLineItem({
    required this.productId,
    required this.unitPrice,
    required this.quantity,
    this.taxId,
    this.discountPct = 0,
  });

  double get total => unitPrice * quantity * (1 - discountPct / 100);

  _SaleLineItem copyWith({
    String? productId,
    double? unitPrice,
    double? quantity,
    String? taxId,
    double? discountPct,
  }) {
    return _SaleLineItem(
      productId: productId ?? this.productId,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      taxId: taxId ?? this.taxId,
      discountPct: discountPct ?? this.discountPct,
    );
  }
}
