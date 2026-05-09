import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/uploads_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  List<dynamic> _warehouses = [];
  List<dynamic> _units = [];
  List<dynamic> _transfers = [];
  List<dynamic> _alerts = [];
  bool _loading = true;
  String _search = '';
  int _page = 1;
  int _totalPages = 1;

  final _fmt = currencyFmt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
      final svc = ref.read(inventoryServiceProvider);
      final results = await Future.wait([
        svc.listProducts(page: _page, search: _search.isEmpty ? null : _search),
        svc.listCategories(),
        svc.listWarehouses(),
        svc.listUnits(),
        svc.listTransfers(),
        svc.getLowStockAlerts(),
      ]);
      final productsData = results[0] as Map<String, dynamic>;
      setState(() {
        _products = (productsData['data'] as List<dynamic>?) ?? [];
        final meta = productsData['meta'] as Map<String, dynamic>?;
        _totalPages = int.tryParse(meta?['totalPages']?.toString() ?? '1') ?? 1;
        _categories = results[1] as List<dynamic>;
        _warehouses = results[2] as List<dynamic>;
        _units = results[3] as List<dynamic>;
        _transfers = results[4] as List<dynamic>;
        _alerts = results[5] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;

    final alertCount = _alerts.length;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: PageHeader(
              eyebrow: 'OPERACIÓN',
              title: 'Tu inventario',
              meta: '${_products.length} producto${_products.length == 1 ? '' : 's'}'
                  '${alertCount > 0 ? ' · $alertCount alerta${alertCount == 1 ? '' : 's'} de stock' : ''}',
              metaIsMono: true,
              actions: [
                OutlinedButton.icon(
                  onPressed: () => _showAdjustmentForm(context),
                  icon: const Icon(LucideIcons.clipboardPen, size: 14),
                  label: const Text('Ajuste'),
                ),
                FilledButton.icon(
                  onPressed: () => _showProductForm(context),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Nuevo producto'),
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
                Tab(text: 'Productos (${_products.length})'),
                Tab(text: 'Categorías (${_categories.length})'),
                Tab(text: 'Bodegas (${_warehouses.length})'),
                Tab(text: 'Unidades (${_units.length})'),
                Tab(text: 'Transferencias (${_transfers.length})'),
                Tab(text: 'Alertas${alertCount > 0 ? ' ($alertCount)' : ''}'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(theme, isWide),
                _buildCategoriesTab(theme, isWide),
                _buildWarehousesTab(theme, isWide),
                _buildUnitsTab(theme, isWide),
                _buildTransfersTab(theme, isWide),
                _buildAlertsTab(theme, isWide),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Products Tab ──

  Widget _buildProductsTab(ThemeData theme, bool isWide) {
    final cs = theme.colorScheme;
    final padX = isWide ? 32.0 : 20.0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padX, 16, padX, 12),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar productos por nombre o SKU...',
              prefixIcon: Icon(LucideIcons.search, size: 18),
              isDense: true,
            ),
            onChanged: (v) {
              _search = v;
              _page = 1;
              _loadData();
            },
          ),
        ),
        Expanded(
          child: _loading
              ? const _InventoryListSkeleton()
              : _products.isEmpty
                  ? EmptyState(
                      icon: LucideIcons.packageOpen,
                      title: _search.isEmpty ? 'Aún no tenés productos' : 'Sin resultados',
                      description: _search.isEmpty
                          ? 'Agregá tu primer producto para empezar a controlar stock y precios.'
                          : 'No encontramos productos que coincidan con "$_search".',
                      actionLabel: _search.isEmpty ? 'Nuevo producto' : null,
                      actionIcon: _search.isEmpty ? LucideIcons.plus : null,
                      onAction: _search.isEmpty ? () => _showProductForm(context) : null,
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(padX, 0, padX, 24),
                      itemCount: _products.length,
                      itemBuilder: (context, i) {
                        final p = _products[i] as Map<String, dynamic>;
                        final salePrice = double.tryParse(p['salePrice']?.toString() ?? '0') ?? 0;
                        final costPrice = double.tryParse(p['costPrice']?.toString() ?? '0') ?? 0;
                        final stock = p['stock']?.toString();
                        final productImage = p['imageUrl'] as String?;

                        return FinancialListRow(
                          leading: NetworkImageThumb(
                            url: productImage,
                            size: 38,
                            borderRadius: BorderRadius.circular(10),
                            fallback: RowLeadingIcon(
                              icon: LucideIcons.box,
                              color: cs.primary,
                            ),
                          ),
                          title: p['name']?.toString() ?? 'Sin nombre',
                          subtitleParts: [
                            'SKU: ${p['sku'] ?? 'N/A'}',
                            'Costo: ${_fmt.format(costPrice)}',
                            if (stock != null && stock.isNotEmpty) 'Stock: $stock',
                          ],
                          trailingValue: _fmt.format(salePrice),
                          trailingSubtitle: 'venta',
                          onTap: () => _showProductDetail(context, p),
                        );
                      },
                    ),
        ),
        if (_totalPages > 1)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft, size: 20),
                  onPressed: _page > 1 ? () { _page--; _loadData(); } : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_page / $_totalPages', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight, size: 20),
                  onPressed: _page < _totalPages ? () { _page++; _loadData(); } : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Tab simple builder (categorías, bodegas, unidades, transferencias) ──

  Widget _simpleTab({
    required bool isWide,
    required List<dynamic> items,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyDescription,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
    required FinancialListRow Function(BuildContext, Map<String, dynamic>) builder,
  }) {
    final padX = isWide ? 32.0 : 20.0;
    if (items.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        description: emptyDescription,
        actionLabel: actionLabel,
        actionIcon: actionIcon,
        onAction: onAction,
      );
    }
    return Column(
      children: [
        if (actionLabel != null && onAction != null)
          Padding(
            padding: EdgeInsets.fromLTRB(padX, 16, padX, 8),
            child: Row(
              children: [
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon ?? LucideIcons.plus, size: 14),
                  label: Text(actionLabel),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(padX, 0, padX, 24),
            itemCount: items.length,
            itemBuilder: (context, i) => builder(context, items[i] as Map<String, dynamic>),
          ),
        ),
      ],
    );
  }

  // ── Categories Tab ──

  Widget _buildCategoriesTab(ThemeData theme, bool isWide) {
    final cs = theme.colorScheme;
    return _simpleTab(
      isWide: isWide,
      items: _categories,
      emptyIcon: LucideIcons.folderOpen,
      emptyTitle: 'Sin categorías',
      emptyDescription: 'Organizá tus productos en categorías para reportes y filtros más claros.',
      actionLabel: 'Nueva categoría',
      actionIcon: LucideIcons.plus,
      onAction: () => _showCategoryForm(context),
      builder: (ctx, c) => FinancialListRow(
        leading: RowLeadingIcon(icon: LucideIcons.folderOpen, color: cs.primary),
        title: c['name']?.toString() ?? 'Sin nombre',
        subtitleParts: [
          if (c['description'] != null && (c['description'] as String).isNotEmpty)
            c['description'] as String,
        ],
        onTap: () => _confirmDeleteCategory(context, c),
      ),
    );
  }

  // ── Warehouses Tab ──

  Widget _buildWarehousesTab(ThemeData theme, bool isWide) {
    return _simpleTab(
      isWide: isWide,
      items: _warehouses,
      emptyIcon: LucideIcons.warehouse,
      emptyTitle: 'Sin bodegas',
      emptyDescription: 'Las bodegas te permiten manejar stock por ubicación y hacer transferencias entre ellas.',
      actionLabel: 'Nueva bodega',
      actionIcon: LucideIcons.plus,
      onAction: () => _showWarehouseForm(context),
      builder: (ctx, w) => FinancialListRow(
        leading: RowLeadingIcon(icon: LucideIcons.warehouse, color: AppTheme.info),
        title: w['name']?.toString() ?? 'Sin nombre',
        subtitleParts: [
          if (w['address'] != null && (w['address'] as String).isNotEmpty)
            w['address'] as String,
        ],
      ),
    );
  }

  // ── Units Tab ──

  Widget _buildUnitsTab(ThemeData theme, bool isWide) {
    return _simpleTab(
      isWide: isWide,
      items: _units,
      emptyIcon: LucideIcons.ruler,
      emptyTitle: 'Sin unidades de medida',
      emptyDescription: 'Definí cómo medís tus productos: unidad, kilo, litro, caja, docena, etc.',
      builder: (ctx, u) => FinancialListRow(
        leading: RowLeadingIcon(icon: LucideIcons.ruler, color: theme.colorScheme.primary),
        title: u['name']?.toString() ?? 'Sin nombre',
        subtitleParts: [
          if (u['abbreviation'] != null && (u['abbreviation'] as String).isNotEmpty)
            u['abbreviation'] as String,
        ],
      ),
    );
  }

  // ── Transfers Tab ──

  Widget _buildTransfersTab(ThemeData theme, bool isWide) {
    return _simpleTab(
      isWide: isWide,
      items: _transfers,
      emptyIcon: LucideIcons.arrowLeftRight,
      emptyTitle: 'Sin transferencias',
      emptyDescription: 'Movés stock entre bodegas. Cada transferencia queda registrada acá.',
      actionLabel: 'Nueva transferencia',
      actionIcon: LucideIcons.arrowLeftRight,
      onAction: () => _showTransferForm(context),
      builder: (ctx, t) => FinancialListRow(
        leading: RowLeadingIcon(icon: LucideIcons.arrowLeftRight, color: AppTheme.info),
        title: '${t['fromWarehouseName'] ?? 'Origen'} → ${t['toWarehouseName'] ?? 'Destino'}',
        subtitleParts: [
          t['productName']?.toString() ?? '',
          'Cant: ${t['quantity'] ?? 0}',
          if (t['createdAt'] != null) formatDateShortEs(t['createdAt']?.toString()),
        ],
      ),
    );
  }

  // ── Alerts Tab ──

  Widget _buildAlertsTab(ThemeData theme, bool isWide) {
    final padX = isWide ? 32.0 : 20.0;

    if (_alerts.isEmpty) {
      return EmptyState(
        icon: LucideIcons.circleCheck,
        title: 'Todo en orden',
        description: 'No hay productos con stock bajo. Cuando alguno se acerque al mínimo, te avisamos acá.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      itemCount: _alerts.length,
      itemBuilder: (context, i) {
        final a = _alerts[i] as Map<String, dynamic>;
        final currentStock = a['currentStock'] ?? a['stock'] ?? 0;
        final minStock = a['minStock'] ?? a['reorderPoint'] ?? 0;

        return FinancialListRow(
          leading: RowLeadingIcon(icon: LucideIcons.triangleAlert, color: AppTheme.danger),
          title: a['name']?.toString() ?? a['productName']?.toString() ?? 'Producto',
          subtitleParts: [
            'SKU: ${a['sku'] ?? 'N/A'}',
            'Mínimo: $minStock',
          ],
          chips: [
            IntentChip(label: 'Stock bajo', intent: ChipIntent.danger, small: true),
          ],
          trailingValue: '$currentStock',
          trailingColor: AppTheme.danger,
          trailingSubtitle: 'unidades',
        );
      },
    );
  }

  // ── Product Detail Dialog ──

  void _showProductDetail(BuildContext context, Map<String, dynamic> product) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final salePrice = double.tryParse(product['salePrice']?.toString() ?? '0') ?? 0;
    final costPrice = double.tryParse(product['costPrice']?.toString() ?? '0') ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.box, size: 22, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(product['name'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DetailRow(theme: theme, label: 'SKU', value: product['sku'] ?? 'N/A', labelWidth: 110),
                DetailRow(theme: theme, label: 'Precio Venta', value: _fmt.format(salePrice), labelWidth: 110),
                DetailRow(theme: theme, label: 'Precio Costo', value: _fmt.format(costPrice), labelWidth: 110),
                if (product['categoryName'] != null)
                  DetailRow(theme: theme, label: 'Categoria', value: product['categoryName'], labelWidth: 110),
                if (product['stock'] != null)
                  DetailRow(theme: theme, label: 'Stock', value: product['stock'].toString(), labelWidth: 110),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(LucideIcons.history, size: 16, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Movimientos', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<dynamic>>(
                  future: ref.read(inventoryServiceProvider).getProductMovements(product['id'] as String),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError) {
                      return Text('Error al cargar movimientos', style: TextStyle(color: cs.error));
                    }
                    final movements = snapshot.data ?? [];
                    if (movements.isEmpty) {
                      return Text('Sin movimientos', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant));
                    }
                    return Column(
                      children: movements.take(10).map((m) {
                        final mov = m as Map<String, dynamic>;
                        final type = mov['movementType'] ?? mov['type'] ?? '';
                        final qty = mov['quantity'] ?? 0;
                        final isIn = type == 'in' || type == 'purchase' || type == 'adjustment_in';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(isIn ? LucideIcons.circleArrowDown : LucideIcons.circleArrowUp, size: 14, color: isIn ? cs.secondary : cs.error),
                              const SizedBox(width: 6),
                              Expanded(child: Text(type, style: theme.textTheme.bodySmall)),
                              Text('${isIn ? '+' : '-'}$qty', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: isIn ? cs.secondary : cs.error)),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDeleteProduct(context, product);
            },
            icon: Icon(LucideIcons.trash2, size: 16, color: cs.error),
            label: Text('Eliminar', style: TextStyle(color: cs.error)),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showEditProductForm(context, product);
            },
            icon: const Icon(LucideIcons.pencil, size: 16),
            label: const Text('Editar'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  // ── Edit Product ──

  void _showEditProductForm(BuildContext context, Map<String, dynamic> product) {
    final nameCtrl = TextEditingController(text: product['name'] ?? '');
    final skuCtrl = TextEditingController(text: product['sku'] ?? '');
    final priceCtrl = TextEditingController(text: product['salePrice']?.toString() ?? '');
    final costCtrl = TextEditingController(text: product['costPrice']?.toString() ?? '');
    String? imageUrl = product['imageUrl'] as String?;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.pencil, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Editar producto'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ImagePickerField(
                      currentUrl: imageUrl,
                      folder: UploadFolder.products,
                      shape: ImagePickerShape.rounded,
                      size: 110,
                      placeholderLabel: 'Foto del\nproducto',
                      onChanged: (url) => setLocal(() => imageUrl = url),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                  const SizedBox(height: 12),
                  TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU')),
                  const SizedBox(height: 12),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio venta'), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Precio costo'), keyboardType: TextInputType.number),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(inventoryServiceProvider).updateProduct(product['id'] as String, {
                    'name': nameCtrl.text,
                    'sku': skuCtrl.text,
                    'salePrice': priceCtrl.text,
                    'costPrice': costCtrl.text,
                    'imageUrl': imageUrl ?? '',
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
      ),
    );
  }

  // ── Delete Product ──

  void _confirmDeleteProduct(BuildContext context, Map<String, dynamic> product) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.triangleAlert, size: 22, color: cs.error),
            const SizedBox(width: 8),
            const Text('Eliminar Producto'),
          ],
        ),
        content: Text('¿Eliminar "${product['name']}"? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              try {
                await ref.read(inventoryServiceProvider).deleteProduct(product['id'] as String);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ── Delete Category ──

  void _confirmDeleteCategory(BuildContext context, Map<String, dynamic> category) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.triangleAlert, size: 22, color: cs.error),
            const SizedBox(width: 8),
            const Text('Eliminar Categoria'),
          ],
        ),
        content: Text('¿Eliminar la categoria "${category['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () async {
              try {
                await ref.read(inventoryServiceProvider).deleteCategory(category['id'] as String);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ── Transfer Form ──

  void _showTransferForm(BuildContext context) {
    final qtyCtrl = TextEditingController(text: '1');
    String? fromWarehouse;
    String? toWarehouse;
    String? selectedProduct;

    if (_warehouses.length >= 2) {
      fromWarehouse = _warehouses[0]['id'] as String;
      toWarehouse = _warehouses[1]['id'] as String;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.arrowLeftRight, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Nueva Transferencia'),
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
                    initialValue: selectedProduct,
                    decoration: const InputDecoration(labelText: 'Producto', border: OutlineInputBorder()),
                    items: _products.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] ?? '', overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setDialogState(() => selectedProduct = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                isExpanded: true,
                    initialValue: fromWarehouse,
                    decoration: const InputDecoration(labelText: 'Bodega Origen', border: OutlineInputBorder()),
                    items: _warehouses.map((w) => DropdownMenuItem(value: w['id'] as String, child: Text(w['name'] ?? ''))).toList(),
                    onChanged: (v) => setDialogState(() => fromWarehouse = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                isExpanded: true,
                    initialValue: toWarehouse,
                    decoration: const InputDecoration(labelText: 'Bodega Destino', border: OutlineInputBorder()),
                    items: _warehouses.map((w) => DropdownMenuItem(value: w['id'] as String, child: Text(w['name'] ?? ''))).toList(),
                    onChanged: (v) => setDialogState(() => toWarehouse = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (selectedProduct == null || fromWarehouse == null || toWarehouse == null) return;
                try {
                  await ref.read(inventoryServiceProvider).createTransfer({
                    'productId': selectedProduct,
                    'fromWarehouseId': fromWarehouse,
                    'toWarehouseId': toWarehouse,
                    'quantity': qtyCtrl.text,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Transferir'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Adjustment Form ──

  void _showAdjustmentForm(BuildContext context) {
    final qtyCtrl = TextEditingController(text: '1');
    final reasonCtrl = TextEditingController();
    String? selectedProduct;
    String? selectedWarehouse = _warehouses.isNotEmpty ? _warehouses[0]['id'] as String : null;
    String adjustmentType = 'in';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.clipboardPen, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Ajuste de Inventario'),
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
                    initialValue: selectedProduct,
                    decoration: const InputDecoration(labelText: 'Producto', border: OutlineInputBorder()),
                    items: _products.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] ?? '', overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setDialogState(() => selectedProduct = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                isExpanded: true,
                    initialValue: selectedWarehouse,
                    decoration: const InputDecoration(labelText: 'Bodega', border: OutlineInputBorder()),
                    items: _warehouses.map((w) => DropdownMenuItem(value: w['id'] as String, child: Text(w['name'] ?? ''))).toList(),
                    onChanged: (v) => setDialogState(() => selectedWarehouse = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                isExpanded: true,
                    initialValue: adjustmentType,
                    decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'in', child: Text('Entrada')),
                      DropdownMenuItem(value: 'out', child: Text('Salida')),
                    ],
                    onChanged: (v) => setDialogState(() => adjustmentType = v ?? 'in'),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()), keyboardType: TextInputType.number),
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
                if (selectedProduct == null || selectedWarehouse == null) return;
                try {
                  await ref.read(inventoryServiceProvider).createAdjustment({
                    'productId': selectedProduct,
                    'warehouseId': selectedWarehouse,
                    'type': adjustmentType,
                    'quantity': qtyCtrl.text,
                    if (reasonCtrl.text.isNotEmpty) 'reason': reasonCtrl.text,
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
      ),
    );
  }

  // ── Create Product ──

  void _showProductForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String? imageUrl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.packagePlus, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Nuevo producto'),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ImagePickerField(
                      currentUrl: imageUrl,
                      folder: UploadFolder.products,
                      shape: ImagePickerShape.rounded,
                      size: 110,
                      placeholderLabel: 'Foto del\nproducto',
                      onChanged: (url) => setLocal(() => imageUrl = url),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                  const SizedBox(height: 12),
                  TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU')),
                  const SizedBox(height: 12),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio venta'), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Precio costo'), keyboardType: TextInputType.number),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(inventoryServiceProvider).createProduct({
                    'name': nameCtrl.text,
                    'sku': skuCtrl.text,
                    'salePrice': priceCtrl.text,
                    'costPrice': costCtrl.text,
                    'unitId': 1,
                    if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
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

  // ── Create Category ──

  void _showCategoryForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.folderPlus, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Nueva Categoria'),
          ],
        ),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(inventoryServiceProvider).createCategory({'name': nameCtrl.text});
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

  // ── Create Warehouse ──

  void _showWarehouseForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.warehouse, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Nueva Bodega'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Direccion', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(inventoryServiceProvider).createWarehouse({
                  'name': nameCtrl.text,
                  'address': addressCtrl.text,
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
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _InventorySkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _InventorySkeletonBox({
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
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 700.ms, curve: Curves.easeIn)
        .fadeOut(delay: 700.ms, duration: 700.ms, curve: Curves.easeOut);
  }
}

class _InventoryListSkeleton extends StatelessWidget {
  const _InventoryListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: 8,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            _InventorySkeletonBox(width: 40, height: 40, radius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InventorySkeletonBox(width: 130 + (i % 3) * 20.0, height: 14),
                  const SizedBox(height: 6),
                  _InventorySkeletonBox(width: 90 + (i % 2) * 25.0, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const _InventorySkeletonBox(width: 68, height: 16),
          ],
        ),
      ),
    );
  }
}
