import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/service_providers.dart';
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
                    Icon(LucideIcons.package, size: 28, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Inventario', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showAdjustmentForm(context),
                      icon: const Icon(LucideIcons.clipboardPen, size: 18),
                      label: const Text('Ajuste'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showProductForm(context),
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('Producto'),
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
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.box, size: 16), const SizedBox(width: 6), Text('Productos (${_products.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.folderOpen, size: 16), const SizedBox(width: 6), Text('Categorias (${_categories.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.warehouse, size: 16), const SizedBox(width: 6), Text('Bodegas (${_warehouses.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.ruler, size: 16), const SizedBox(width: 6), Text('Unidades (${_units.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.arrowLeftRight, size: 16), const SizedBox(width: 6), Text('Transferencias (${_transfers.length})')])),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.triangleAlert, size: 16), const SizedBox(width: 6), Text('Alertas (${_alerts.length})')])),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(theme),
                _buildCategoriesTab(theme),
                _buildWarehousesTab(theme),
                _buildUnitsTab(theme),
                _buildTransfersTab(theme),
                _buildAlertsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Products Tab ──

  Widget _buildProductsTab(ThemeData theme) {
    final cs = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.packageX, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('No hay productos', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _products.length,
                      itemBuilder: (context, i) {
                        final p = _products[i] as Map<String, dynamic>;
                        final salePrice = double.tryParse(p['salePrice']?.toString() ?? '0') ?? 0;
                        final costPrice = double.tryParse(p['costPrice']?.toString() ?? '0') ?? 0;

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
                              child: Icon(LucideIcons.box, size: 20, color: cs.primary),
                            ),
                            title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              'SKU: ${p['sku'] ?? 'N/A'} · Costo: ${_fmt.format(costPrice)}',
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              _fmt.format(salePrice),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                            onTap: () => _showProductDetail(context, p),
                          ),
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

  // ── Categories Tab ──

  Widget _buildCategoriesTab(ThemeData theme) {
    final cs = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showCategoryForm(context),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Categoria'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.folderX, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('No hay categorias', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final c = _categories[i] as Map<String, dynamic>;
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
                          child: Icon(LucideIcons.folderOpen, size: 20, color: cs.secondary),
                        ),
                        title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: c['description'] != null ? Text(c['description'], maxLines: 2, overflow: TextOverflow.ellipsis) : null,
                        trailing: IconButton(
                          icon: Icon(LucideIcons.trash2, size: 18, color: cs.error),
                          onPressed: () => _confirmDeleteCategory(context, c),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Warehouses Tab ──

  Widget _buildWarehousesTab(ThemeData theme) {
    final cs = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showWarehouseForm(context),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Bodega'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _warehouses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.warehouse, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('No hay bodegas', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _warehouses.length,
                  itemBuilder: (context, i) {
                    final w = _warehouses[i] as Map<String, dynamic>;
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
                          decoration: BoxDecoration(color: cs.tertiaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                          child: Icon(LucideIcons.warehouse, size: 20, color: cs.tertiary),
                        ),
                        title: Text(w['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: w['address'] != null ? Text(w['address'], maxLines: 2, overflow: TextOverflow.ellipsis) : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Units Tab ──

  Widget _buildUnitsTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_units.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.ruler, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No hay unidades de medida', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _units.length,
      itemBuilder: (context, i) {
        final u = _units[i] as Map<String, dynamic>;
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
              decoration: BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
              child: Icon(LucideIcons.ruler, size: 20, color: cs.primary),
            ),
            title: Text(u['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(u['abbreviation'] ?? '', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
        );
      },
    );
  }

  // ── Transfers Tab ──

  Widget _buildTransfersTab(ThemeData theme) {
    final cs = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showTransferForm(context),
                icon: const Icon(LucideIcons.arrowLeftRight, size: 18),
                label: const Text('Nueva Transferencia'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _transfers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.arrowLeftRight, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('No hay transferencias', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _transfers.length,
                  itemBuilder: (context, i) {
                    final t = _transfers[i] as Map<String, dynamic>;
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
                          decoration: BoxDecoration(color: cs.tertiaryContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                          child: Icon(LucideIcons.arrowLeftRight, size: 20, color: cs.tertiary),
                        ),
                        title: Text(
                          '${t['fromWarehouseName'] ?? 'Origen'} → ${t['toWarehouseName'] ?? 'Destino'}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${t['productName'] ?? ''} · Cant: ${t['quantity'] ?? 0}',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        trailing: SizedBox(
                          width: 80,
                          child: Text(
                            t['createdAt']?.toString().substring(0, 10) ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Alerts Tab ──

  Widget _buildAlertsTab(ThemeData theme) {
    final cs = theme.colorScheme;

    if (_alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleCheck, size: 48, color: cs.secondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('Sin alertas de stock bajo', style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _alerts.length,
      itemBuilder: (context, i) {
        final a = _alerts[i] as Map<String, dynamic>;
        final currentStock = a['currentStock'] ?? a['stock'] ?? 0;
        final minStock = a['minStock'] ?? a['reorderPoint'] ?? 0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: cs.error.withValues(alpha: 0.3)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: cs.errorContainer.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
              child: Icon(LucideIcons.triangleAlert, size: 20, color: cs.error),
            ),
            title: Text(a['name'] ?? a['productName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('SKU: ${a['sku'] ?? 'N/A'}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$currentStock', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.error), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('min: $minStock', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.pencil, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Editar Producto'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio Venta', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Precio Costo', border: OutlineInputBorder()), keyboardType: TextInputType.number),
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.packagePlus, size: 22, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Nuevo Producto'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio Venta', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Precio Costo', border: OutlineInputBorder()), keyboardType: TextInputType.number),
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
