import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/models/paginated.dart';
import '../../../core/services/uploads_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/forms/forms.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/catalogs.dart';
import '../models/product.dart';
import '../models/transfer.dart';
import '../providers/inventory_providers.dart';

bool _isLowStock(Product p) =>
    !p.isService && p.totalStockValue <= double.parse(p.minStock);

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int _tabIndex = 0;

  String _search = '';

  // "Cargar más" for the product list: page 1 is reactive (search), the
  // following pages are accumulated imperatively to avoid races with
  // AsyncValue.
  List<Product> _extraProductPages = [];
  int _nextProductPage = 2;
  bool _loadingMoreProducts = false;

  final _fmt = currencyFmt;

  static String? _quantityValidator(String? v) {
    final formatError = PValidators.money(v);
    if (formatError != null) return formatError;
    if (v != null && v.isNotEmpty && double.parse(v) <= 0) {
      return 'Debe ser mayor a 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;

    final productsAsync =
        ref.watch(productsListProvider(page: 1, search: _search));
    final overviewAsync = ref.watch(inventoryOverviewProvider);

    final totalProducts = productsAsync.value?.meta.total ?? 0;
    final overview = overviewAsync.value;
    final alertCount = overview?.alerts.length ?? 0;

    final tabContent = switch (_tabIndex) {
      0 => _buildProductsTab(isWide, productsAsync),
      1 => AsyncValueWidget(
          value: overviewAsync,
          loading: _tabSkeleton(_categoryColumns),
          onRetry: () => ref.invalidate(inventoryOverviewProvider),
          data: (o) => _buildCategoriesTab(isWide, o.categories),
        ),
      2 => AsyncValueWidget(
          value: overviewAsync,
          loading: _tabSkeleton(_warehouseColumns),
          onRetry: () => ref.invalidate(inventoryOverviewProvider),
          data: (o) => _buildWarehousesTab(isWide, o.warehouses),
        ),
      3 => AsyncValueWidget(
          value: overviewAsync,
          loading: _tabSkeleton(_unitColumns),
          onRetry: () => ref.invalidate(inventoryOverviewProvider),
          data: (o) => _buildUnitsTab(isWide, o.units),
        ),
      4 => AsyncValueWidget(
          value: overviewAsync,
          loading: _tabSkeleton(_transferColumns(const [])),
          onRetry: () => ref.invalidate(inventoryOverviewProvider),
          data: (o) => _buildTransfersTab(isWide, o.transfers, o.warehouses),
        ),
      5 => AsyncValueWidget(
          value: overviewAsync,
          loading: _tabSkeleton(_alertSkeletonColumns),
          onRetry: () => ref.invalidate(inventoryOverviewProvider),
          data: (o) => _buildAlertsTab(isWide, o.alerts),
        ),
      _ => const SizedBox.shrink(),
    };

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: PageHeader(
              title: 'Tu inventario',
              metrics: [
                MetricChip(label: 'Productos', value: '$totalProducts'),
                if (alertCount > 0)
                  MetricChip(label: 'Alertas', value: '$alertCount'),
              ],
              actions: [
                OutlinedButton.icon(
                  onPressed: _openAdjustmentForm,
                  icon: const Icon(LucideIcons.clipboardPen, size: 14),
                  label: const Text('Ajuste'),
                ),
                FilledButton.icon(
                  onPressed: _openProductForm,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Nuevo producto'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: PTabs(
                tabs: [
                  PTabItem('Productos', count: totalProducts),
                  PTabItem('Categorías', count: overview?.categories.length),
                  PTabItem('Bodegas', count: overview?.warehouses.length),
                  PTabItem('Unidades', count: overview?.units.length),
                  PTabItem('Transferencias', count: overview?.transfers.length),
                  PTabItem('Alertas', count: alertCount > 0 ? alertCount : null),
                ],
                index: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: KeyedSubtree(
                key: ValueKey(_tabIndex),
                child: tabContent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Products tab ───────────────────────────────────────────────────────────

  List<DataListColumn<Product>> get _productColumns => [
        DataListColumn<Product>(
          label: 'SKU',
          flex: 2,
          cell: (ctx, p) => Text(
            p.sku ?? '—',
            style: AppTheme.mono(
                fontSize: 12, color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataListColumn<Product>(
          label: 'Nombre',
          flex: 4,
          cell: _productNameCell,
        ),
        DataListColumn<Product>(
          label: 'Categoría',
          flex: 3,
          cell: (ctx, p) => Text(
            p.categoryName ?? '—',
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataListColumn<Product>(
          label: 'Stock',
          flex: 2,
          isMoney: true,
          cell: _productStockCell,
        ),
        DataListColumn<Product>(
          label: 'Precio',
          flex: 2,
          isMoney: true,
          cell: (ctx, p) => Text(
            _fmt.format(p.salePriceValue),
            style: AppTheme.mono(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(ctx).colorScheme.onSurface),
          ),
        ),
      ];

  Widget _productNameCell(BuildContext ctx, Product p) {
    final cs = Theme.of(ctx).colorScheme;
    final wide = MediaQuery.sizeOf(ctx).width >= 900;
    final text = Text(
      p.name,
      style: Theme.of(ctx)
          .textTheme
          .bodyMedium
          ?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (wide || !_isLowStock(p)) return text;
    // Compact mode: 3px warning accent edge next to the name, not a tinted row.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: ctx.tokens.warning,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(child: text),
      ],
    );
  }

  Widget _productStockCell(BuildContext ctx, Product p) {
    final cs = Theme.of(ctx).colorScheme;
    final wide = MediaQuery.sizeOf(ctx).width >= 900;
    final low = _isLowStock(p);
    final valueText = Text(
      p.isService ? '—' : formatQty(p.totalStockValue),
      style: AppTheme.mono(
          fontSize: 13, color: low ? ctx.tokens.warning : cs.onSurface),
    );
    if (!wide || !low) return valueText;
    // Table mode: subtle warning dot instead of an accent edge.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration:
              BoxDecoration(color: ctx.tokens.warning, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        valueText,
      ],
    );
  }

  Widget _buildProductsTab(bool isWide, AsyncValue<Paginated<Product>> async) {
    final padX = isWide ? 32.0 : 20.0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padX, 16, padX, 12),
          child: SearchField(
            hint: 'Buscar productos por nombre o SKU...',
            onChanged: (v) => setState(() {
              _search = v;
              _extraProductPages = [];
              _nextProductPage = 2;
            }),
          ),
        ),
        Expanded(
          child: AsyncValueWidget(
            value: async,
            loading: _tabSkeleton(_productColumns),
            onRetry: () => ref.invalidate(productsListProvider),
            data: (page) {
              final items = [...page.data, ..._extraProductPages];
              if (items.isEmpty) {
                // Only one brand prop per state: the illustration is the
                // "brand moment" of the real empty state (no filters); a
                // no-results search is not a brand empty state, so it uses
                // an icon, not an image (docs/DESIGN-VOICE.md §1).
                return _search.isEmpty
                    ? EmptyState(
                        image: 'assets/illustrations/empty_inventory.png',
                        title: 'Aún no tenés productos',
                        description:
                            'Agregá tu primer producto para empezar a controlar stock y precios.',
                        actionLabel: 'Nuevo producto',
                        actionIcon: LucideIcons.plus,
                        onAction: _openProductForm,
                      )
                    : EmptyState(
                        icon: LucideIcons.packageOpen,
                        title: 'Sin resultados',
                        description:
                            'No encontramos productos que coincidan con "$_search".',
                      );
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: padX),
                child: SingleChildScrollView(
                  child: DataList<Product>(
                    columns: _productColumns,
                    data: Paginated(data: items, meta: page.meta),
                    emptyState: const SizedBox.shrink(),
                    onTap: _showProductDetail,
                    onLoadMore:
                        items.length < page.meta.total ? _loadMoreProducts : null,
                    loadingMore: _loadingMoreProducts,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _loadMoreProducts() async {
    setState(() => _loadingMoreProducts = true);
    final page = await ref.read(
      productsListProvider(page: _nextProductPage, search: _search).future,
    );
    if (!mounted) return;
    setState(() {
      _extraProductPages = [..._extraProductPages, ...page.data];
      _nextProductPage++;
      _loadingMoreProducts = false;
    });
  }

  // ── Simple tab builder (categories, warehouses, units, transfers) ──────────
  // DataList covers row + table/compact/skeleton/empty: there's no row icon
  // because the tab already identifies which list it is (docs/DESIGN.md §Primitives).

  Widget _tabSkeleton<T>(List<DataListColumn<T>> columns) => DataList<T>(
        columns: columns,
        data: null,
        loading: true,
        emptyState: const SizedBox.shrink(),
      );

  Widget _simpleTab<T>({
    required bool isWide,
    required List<T> items,
    required List<DataListColumn<T>> columns,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyDescription,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
    void Function(T item)? onTap,
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padX),
            child: SingleChildScrollView(
              child: DataList<T>(
                columns: columns,
                data: Paginated(
                  data: items,
                  meta: PageMeta(
                    page: 1,
                    limit: items.length,
                    total: items.length,
                    totalPages: 1,
                  ),
                ),
                emptyState: const SizedBox.shrink(),
                onTap: onTap,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _plainCell(BuildContext ctx, String value, {bool mono = false}) {
    final cs = Theme.of(ctx).colorScheme;
    return Text(
      value.isEmpty ? '—' : value,
      style: mono
          ? AppTheme.mono(fontSize: 13, color: cs.onSurfaceVariant)
          : Theme.of(ctx)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.onSurfaceVariant),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _nameCell(BuildContext ctx, String value) {
    final cs = Theme.of(ctx).colorScheme;
    return Text(
      value,
      style: Theme.of(ctx)
          .textTheme
          .bodyMedium
          ?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Categories tab ─────────────────────────────────────────────────────────

  List<DataListColumn<Category>> get _categoryColumns => [
        DataListColumn<Category>(
          label: 'Nombre',
          flex: 3,
          cell: (ctx, c) => _nameCell(ctx, c.name),
        ),
        DataListColumn<Category>(
          label: 'Descripción',
          flex: 4,
          cell: (ctx, c) => _plainCell(ctx, c.description ?? ''),
        ),
      ];

  Widget _buildCategoriesTab(bool isWide, List<Category> categories) {
    return _simpleTab(
      isWide: isWide,
      items: categories,
      columns: _categoryColumns,
      emptyIcon: LucideIcons.folderOpen,
      emptyTitle: 'Sin categorías',
      emptyDescription:
          'Organizá tus productos en categorías para reportes y filtros más claros.',
      actionLabel: 'Nueva categoría',
      actionIcon: LucideIcons.plus,
      onAction: _showCategoryForm,
      onTap: _confirmDeleteCategory,
    );
  }

  // ── Warehouses tab ─────────────────────────────────────────────────────────

  List<DataListColumn<Warehouse>> get _warehouseColumns => [
        DataListColumn<Warehouse>(
          label: 'Nombre',
          flex: 3,
          cell: (ctx, w) => _nameCell(ctx, w.name),
        ),
        DataListColumn<Warehouse>(
          label: 'Dirección',
          flex: 4,
          cell: (ctx, w) => _plainCell(ctx, w.address ?? ''),
        ),
      ];

  Widget _buildWarehousesTab(bool isWide, List<Warehouse> warehouses) {
    return _simpleTab(
      isWide: isWide,
      items: warehouses,
      columns: _warehouseColumns,
      emptyIcon: LucideIcons.warehouse,
      emptyTitle: 'Sin bodegas',
      emptyDescription:
          'Las bodegas te permiten manejar stock por ubicación y hacer transferencias entre ellas.',
      actionLabel: 'Nueva bodega',
      actionIcon: LucideIcons.plus,
      onAction: _showWarehouseForm,
    );
  }

  // ── Units tab ──────────────────────────────────────────────────────────────

  List<DataListColumn<UnitOfMeasure>> get _unitColumns => [
        DataListColumn<UnitOfMeasure>(
          label: 'Nombre',
          flex: 3,
          cell: (ctx, u) => _nameCell(ctx, u.name),
        ),
        DataListColumn<UnitOfMeasure>(
          label: 'Código',
          flex: 2,
          cell: (ctx, u) => _plainCell(ctx, u.code, mono: true),
        ),
      ];

  Widget _buildUnitsTab(bool isWide, List<UnitOfMeasure> units) {
    return _simpleTab(
      isWide: isWide,
      items: units,
      columns: _unitColumns,
      emptyIcon: LucideIcons.ruler,
      emptyTitle: 'Sin unidades de medida',
      emptyDescription:
          'Definí cómo medís tus productos: unidad, kilo, litro, caja, docena, etc.',
    );
  }

  // ── Transfers tab ──────────────────────────────────────────────────────────

  String _warehouseName(List<Warehouse> warehouses, String id) {
    // Una bodega desactivada ya no viene en el listado: caso manejado.
    for (final w in warehouses) {
      if (w.id == id) return w.name;
    }
    return 'Bodega inactiva';
  }

  List<DataListColumn<Transfer>> _transferColumns(List<Warehouse> warehouses) => [
        DataListColumn<Transfer>(
          label: 'Ruta',
          flex: 4,
          cell: (ctx, t) => _nameCell(
            ctx,
            '${_warehouseName(warehouses, t.fromWarehouseId)} → ${_warehouseName(warehouses, t.toWarehouseId)}',
          ),
        ),
        DataListColumn<Transfer>(
          label: 'Detalle',
          flex: 4,
          cell: (ctx, t) => _plainCell(
            ctx,
            [
              if (t.notes?.isNotEmpty == true) t.notes!,
              formatDateShortEs(t.createdAt.toIso8601String()),
            ].join(' · '),
          ),
        ),
        DataListColumn<Transfer>(
          label: 'Estado',
          flex: 2,
          cell: (ctx, t) => t.status == 'completed'
              ? IntentChip(
                  label: 'Completada', intent: ChipIntent.success, small: true)
              : _plainCell(ctx, t.status),
        ),
      ];

  Widget _buildTransfersTab(
      bool isWide, List<Transfer> transfers, List<Warehouse> warehouses) {
    return _simpleTab(
      isWide: isWide,
      items: transfers,
      columns: _transferColumns(warehouses),
      emptyIcon: LucideIcons.arrowLeftRight,
      emptyTitle: 'Sin transferencias',
      emptyDescription:
          'Movés stock entre bodegas. Cada transferencia queda registrada acá.',
      actionLabel: 'Nueva transferencia',
      actionIcon: LucideIcons.arrowLeftRight,
      onAction: _openTransferForm,
    );
  }

  // ── Alerts tab ─────────────────────────────────────────────────────────────
  // A real feed (docs/DESIGN-VOICE.md §1 exempts feeds/nav): keeps the
  // RowLeadingIcon as the feed's anchor, but no longer doubles it with an
  // IntentChip — the accent bar + the number in warning already communicate "low stock".

  List<DataListColumn<LowStockAlert>> get _alertSkeletonColumns => [
        DataListColumn<LowStockAlert>(label: '', cell: (_, a) => const SizedBox()),
        DataListColumn<LowStockAlert>(label: '', cell: (_, a) => const SizedBox()),
        DataListColumn<LowStockAlert>(label: '', cell: (_, a) => const SizedBox()),
      ];

  Widget _buildAlertsTab(bool isWide, List<LowStockAlert> alerts) {
    final padX = isWide ? 32.0 : 20.0;

    if (alerts.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.circleCheck,
        title: 'Todo en orden',
        description:
            'No hay productos con stock bajo. Cuando alguno se acerque al mínimo, te avisamos acá.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      itemCount: alerts.length,
      itemBuilder: (context, i) {
        final a = alerts[i];
        final warning = context.tokens.warning;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: warning),
                Expanded(
                  child: FinancialListRow(
                    dense: true,
                    leading:
                        RowLeadingIcon(icon: LucideIcons.triangleAlert, color: warning),
                    title: a.productName,
                    subtitleParts: [
                      'SKU: ${a.sku ?? 'N/A'}',
                      'Mínimo: ${formatQty(a.minStockValue)}',
                    ],
                    trailingValue: formatQty(a.totalStockValue),
                    trailingColor: warning,
                    trailingSubtitle: 'unidades',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Product detail ─────────────────────────────────────────────────────────

  Widget _specRow(ThemeData theme, String label, String value) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Text(value, style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showProductDetail(Product product) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PistoTokens.radiusCard)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    product.sku ?? 'Sin SKU',
                    if (product.categoryName != null) product.categoryName!,
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Divider(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _specRow(theme, 'Precio venta', _fmt.format(product.salePriceValue)),
                        _specRow(theme, 'Precio costo', _fmt.format(product.costPriceValue)),
                        if (!product.isService)
                          _specRow(theme, 'Stock', product.stockDisplay),
                        const Divider(height: 24),
                        Text(
                          'Movimientos',
                          style: AppTheme.quietLabel(context),
                        ),
                        const SizedBox(height: 8),
                        Consumer(
                          builder: (context, ref, _) {
                            final movementsAsync =
                                ref.watch(productMovementsProvider(product.id));
                            return AsyncValueWidget(
                              value: movementsAsync,
                              loading: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              onRetry: () => ref
                                  .invalidate(productMovementsProvider(product.id)),
                              data: (movements) {
                                if (movements.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text('Sin movimientos',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: cs.onSurfaceVariant)),
                                  );
                                }
                                // Feed exemption (docs/DESIGN-VOICE.md §1): this
                                // list does keep the in/out IconBadge per row.
                                return Column(
                                  children: [
                                    for (final m in movements.take(10))
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            IconBadge(
                                              icon: m.isInbound
                                                  ? LucideIcons.circleArrowDown
                                                  : LucideIcons.circleArrowUp,
                                              color: m.isInbound
                                                  ? context.tokens.success
                                                  : context.tokens.danger,
                                              size: IconBadgeSize.s,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(m.typeLabel,
                                                      style: theme.textTheme.bodySmall),
                                                  Text(
                                                    formatDateShortEs(
                                                        m.createdAt.toIso8601String()),
                                                    style: theme.textTheme.labelSmall
                                                        ?.copyWith(
                                                            color: cs.onSurfaceVariant),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '${m.isInbound ? '+' : '−'}${formatQty(m.quantityValue)}',
                                              style: AppTheme.mono(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: m.isInbound
                                                    ? context.tokens.success
                                                    : context.tokens.danger,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmDeleteProduct(product);
                      },
                      icon: Icon(LucideIcons.trash2, size: 16, color: cs.error),
                      label: Text('Eliminar', style: TextStyle(color: cs.error)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditProductForm(product);
                      },
                      icon: const Icon(LucideIcons.pencil, size: 16),
                      label: const Text('Editar'),
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

  // ── Create / edit product ──────────────────────────────────────────────────

  Widget _productImageHeader(String? initialUrl, ValueChanged<String?> onChanged) {
    var imageUrl = initialUrl;
    return StatefulBuilder(
      builder: (ctx, setLocal) => Center(
        child: ImagePickerField(
          currentUrl: imageUrl,
          folder: UploadFolder.products,
          shape: ImagePickerShape.rounded,
          size: 110,
          placeholderLabel: 'Foto del\nproducto',
          onChanged: (url) {
            setLocal(() => imageUrl = url);
            onChanged(url);
          },
        ),
      ),
    );
  }

  void _openProductForm() async {
    final overview = await ref.read(inventoryOverviewProvider.future);
    if (!mounted) return;

    String? imageUrl;
    await SidePanelForm.show(
      context,
      title: 'Nuevo producto',
      icon: LucideIcons.packagePlus,
      header: _productImageHeader(null, (url) => imageUrl = url),
      fields: [
        const SectionHeading(title: 'Datos básicos', spaceBefore: 0),
        const PTextField(
            name: 'name', label: 'Nombre', required: true, autofocus: true),
        const PTextField(name: 'sku', label: 'SKU'),
        const SectionHeading(title: 'Precios', spaceBefore: 8),
        Row(
          children: [
            Expanded(
              child: const PMoneyField(
                  name: 'salePrice',
                  label: 'Precio venta',
                  required: true,
                  positive: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: const PMoneyField(name: 'costPrice', label: 'Precio costo'),
            ),
          ],
        ),
        SectionHeading(title: 'Clasificación', spaceBefore: 8),
        PSelectField<String>(
          name: 'unitId',
          label: 'Unidad de medida',
          required: true,
          initialValue: overview.units.isEmpty ? null : overview.units.first.id,
          options: [
            for (final u in overview.units)
              PSelectOption(u.id, '${u.name} (${u.code})'),
          ],
        ),
        PSelectField<String>(
          name: 'categoryId',
          label: 'Categoría',
          options: [
            for (final c in overview.categories) PSelectOption(c.id, c.name),
          ],
        ),
      ],
      submitLabel: 'Crear',
      successMessage: 'Producto creado',
      onSubmit: (values) =>
          ref.read(inventoryMutationsProvider.notifier).createProduct(
                name: values['name'] as String,
                salePrice: values['salePrice'] as String,
                unitId: values['unitId'] as String,
                costPrice: values['costPrice'] as String?,
                sku: values['sku'] as String?,
                categoryId: values['categoryId'] as String?,
                imageUrl: imageUrl,
              ),
    );
  }

  void _showEditProductForm(Product product) {
    String? imageUrl = product.imageUrl;
    SidePanelForm.show(
      context,
      title: 'Editar producto',
      icon: LucideIcons.pencil,
      header: _productImageHeader(product.imageUrl, (url) => imageUrl = url),
      fields: [
        const SectionHeading(title: 'Datos básicos', spaceBefore: 0),
        PTextField(
            name: 'name',
            label: 'Nombre',
            initialValue: product.name,
            required: true),
        PTextField(name: 'sku', label: 'SKU', initialValue: product.sku),
        const SectionHeading(title: 'Precios', spaceBefore: 8),
        Row(
          children: [
            Expanded(
              child: PMoneyField(
                  name: 'salePrice',
                  label: 'Precio venta',
                  initialValue: product.salePrice,
                  required: true,
                  positive: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PMoneyField(
                  name: 'costPrice',
                  label: 'Precio costo',
                  initialValue: product.costPrice),
            ),
          ],
        ),
      ],
      successMessage: 'Producto actualizado',
      onSubmit: (values) =>
          ref.read(inventoryMutationsProvider.notifier).updateProduct(
                product.id,
                name: values['name'] as String,
                salePrice: values['salePrice'] as String,
                costPrice: values['costPrice'] as String?,
                sku: values['sku'] as String?,
                imageUrl: imageUrl,
              ),
    );
  }

  void _confirmDeleteProduct(Product product) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar producto',
      description:
          '¿Eliminar "${product.name}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      icon: LucideIcons.trash2,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    await AppToast.guard(
      context,
      () => ref.read(inventoryMutationsProvider.notifier).deleteProduct(product.id),
      successMessage: 'Producto eliminado',
    );
  }

  // ── Categories ─────────────────────────────────────────────────────────────

  void _showCategoryForm() {
    PFormDialog.show(
      context,
      title: 'Nueva categoría',
      icon: LucideIcons.folderPlus,
      fields: const [
        PTextField(
            name: 'name', label: 'Nombre', required: true, autofocus: true),
        PTextField(name: 'description', label: 'Descripción', maxLines: 2),
      ],
      submitLabel: 'Crear',
      successMessage: 'Categoría creada',
      onSubmit: (values) =>
          ref.read(inventoryMutationsProvider.notifier).createCategory(
                name: values['name'] as String,
                description: values['description'] as String?,
              ),
    );
  }

  void _confirmDeleteCategory(Category category) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar categoría',
      description: '¿Eliminar la categoría "${category.name}"?',
      confirmLabel: 'Eliminar',
      icon: LucideIcons.trash2,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    await AppToast.guard(
      context,
      () => ref
          .read(inventoryMutationsProvider.notifier)
          .deleteCategory(category.id),
      successMessage: 'Categoría eliminada',
    );
  }

  // ── Warehouses ─────────────────────────────────────────────────────────────

  void _showWarehouseForm() {
    PFormDialog.show(
      context,
      title: 'Nueva bodega',
      icon: LucideIcons.warehouse,
      fields: const [
        PTextField(
            name: 'name', label: 'Nombre', required: true, autofocus: true),
        PTextField(name: 'address', label: 'Dirección'),
      ],
      submitLabel: 'Crear',
      successMessage: 'Bodega creada',
      onSubmit: (values) =>
          ref.read(inventoryMutationsProvider.notifier).createWarehouse(
                name: values['name'] as String,
                address: values['address'] as String?,
              ),
    );
  }

  // ── Transfers ──────────────────────────────────────────────────────────────

  void _openTransferForm() async {
    final (products, overview) = await (
      ref.read(productOptionsProvider.future),
      ref.read(inventoryOverviewProvider.future),
    ).wait;
    if (!mounted) return;
    final warehouses = overview.warehouses;

    await PFormDialog.show(
      context,
      title: 'Nueva transferencia',
      icon: LucideIcons.arrowLeftRight,
      fields: [
        PSelectField<String>(
          name: 'productId',
          label: 'Producto',
          required: true,
          options: [for (final p in products) PSelectOption(p.id, p.name)],
        ),
        PSelectField<String>(
          name: 'fromWarehouseId',
          label: 'Bodega origen',
          required: true,
          initialValue: warehouses.length >= 2 ? warehouses[0].id : null,
          options: [for (final w in warehouses) PSelectOption(w.id, w.name)],
        ),
        PSelectField<String>(
          name: 'toWarehouseId',
          label: 'Bodega destino',
          required: true,
          initialValue: warehouses.length >= 2 ? warehouses[1].id : null,
          options: [for (final w in warehouses) PSelectOption(w.id, w.name)],
        ),
        PTextField(
          name: 'quantity',
          label: 'Cantidad',
          initialValue: '1',
          required: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _quantityValidator,
        ),
      ],
      submitLabel: 'Transferir',
      successMessage: 'Transferencia registrada',
      onSubmit: (values) =>
          ref.read(inventoryMutationsProvider.notifier).createTransfer(
                fromWarehouseId: values['fromWarehouseId'] as String,
                toWarehouseId: values['toWarehouseId'] as String,
                lines: [
                  TransferLineInput(
                    productId: values['productId'] as String,
                    quantity: values['quantity'] as String,
                  ),
                ],
              ),
    );
  }

  // ── Adjustments ────────────────────────────────────────────────────────────

  void _openAdjustmentForm() async {
    final (products, overview) = await (
      ref.read(productOptionsProvider.future),
      ref.read(inventoryOverviewProvider.future),
    ).wait;
    if (!mounted) return;
    final warehouses = overview.warehouses;

    await PFormDialog.show(
      context,
      title: 'Ajuste de inventario',
      icon: LucideIcons.clipboardPen,
      fields: [
        PSelectField<String>(
          name: 'productId',
          label: 'Producto',
          required: true,
          options: [for (final p in products) PSelectOption(p.id, p.name)],
        ),
        PSelectField<String>(
          name: 'warehouseId',
          label: 'Bodega',
          required: true,
          initialValue: warehouses.isEmpty ? null : warehouses.first.id,
          options: [for (final w in warehouses) PSelectOption(w.id, w.name)],
        ),
        const PSelectField<String>(
          name: 'type',
          label: 'Tipo',
          required: true,
          initialValue: 'adjustment_in',
          options: [
            PSelectOption('adjustment_in', 'Entrada'),
            PSelectOption('adjustment_out', 'Salida'),
          ],
        ),
        PTextField(
          name: 'quantity',
          label: 'Cantidad',
          initialValue: '1',
          required: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _quantityValidator,
        ),
        const PTextField(name: 'notes', label: 'Notas', maxLines: 2),
      ],
      successMessage: 'Ajuste registrado',
      onSubmit: (values) =>
          ref.read(inventoryMutationsProvider.notifier).createAdjustment(
                productId: values['productId'] as String,
                warehouseId: values['warehouseId'] as String,
                type: values['type'] as String,
                quantity: values['quantity'] as String,
                notes: values['notes'] as String?,
              ),
    );
  }
}

