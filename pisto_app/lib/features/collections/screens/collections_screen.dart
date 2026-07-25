import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/models/paginated.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/forms/forms.dart';
import '../../../shared/widgets/widgets.dart';
import '../../sales/models/customer_statement.dart' show CustomerStatement;
import '../../sales/providers/sales_providers.dart'
    show customerStatementProvider;
import '../../settings/providers/settings_providers.dart';
import '../models/aging_bucket.dart';
import '../models/receivable.dart';
import '../providers/collections_providers.dart';

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;

  final _receivableAcc = _PagedAccumulator<ReceivableListItem>();

  final _fmt = currencyFmt;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _tabIndex) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

    final receivablesAsync = ref
        .watch(receivablesListProvider(page: _receivableAcc.requestPage));
    ref.listen(receivablesListProvider(page: _receivableAcc.requestPage),
        (_, next) => _consume(next, _receivableAcc));
    final agingAsync = ref.watch(agingReportProvider);

    final totalCount = _receivableAcc.meta?.total ?? 0;
    final totalPending = _receivableAcc.items.fold<double>(
        0, (sum, item) => sum + item.receivable.balanceValue);
    final pendingScoped = totalCount > _receivableAcc.items.length;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: PageHeader(
              title: 'Te deben',
              metrics: [
                MetricChip(label: 'Cuentas', value: '$totalCount'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: BigFigure(
              label: 'Por cobrar',
              value: _fmt.format(totalPending),
              valueColor: totalPending > 0 ? context.tokens.warningText : null,
              caption: pendingScoped ? 'de las cargadas' : null,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: PTabs(
              tabs: [
                PTabItem('Cuentas por cobrar', count: totalCount),
                const PTabItem('Antigüedad'),
              ],
              index: _tabIndex,
              onChanged: (i) => _tabController.animateTo(i),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: KeyedSubtree(
                key: ValueKey(_tabIndex),
                child: _tabIndex == 0
                    ? _buildReceivablesTab(theme, isWide, receivablesAsync)
                    : AsyncValueWidget(
                        value: agingAsync,
                        loading: const _AgingSkeleton(),
                        onRetry: () => ref.invalidate(agingReportProvider),
                        data: (buckets) =>
                            _buildAgingTab(theme, isWide, buckets),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Receivables tab ────────────────────────────────────────────────────────

  List<DataListColumn<ReceivableListItem>> _receivableColumns() => [
        DataListColumn(
          label: 'Cliente',
          flex: 3,
          cell: (context, item) {
            final name = item.customerName ?? '';
            return Text(
              name.isEmpty ? 'Sin cliente' : name,
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
          label: 'Venta',
          flex: 2,
          cell: (context, item) => Text(
            item.saleNumber ?? '—',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        DataListColumn(
          label: 'Vence',
          flex: 2,
          cell: (context, item) => Text(
            formatDateShortEs(item.receivable.dueDate),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        DataListColumn(
          label: 'Estado',
          flex: 2,
          cell: (context, item) {
            final ar = item.receivable;
            if (ar.paid) {
              return const IntentChip(
                  label: 'Pagada', intent: ChipIntent.success, small: true);
            }
            if (ar.overdue) {
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
          cell: (context, item) {
            final ar = item.receivable;
            final color = ar.paid
                ? null
                : (ar.overdue ? context.tokens.dangerText : context.tokens.warningText);
            return Text(
              _fmt.format(ar.balanceValue),
              style: AppTheme.mono(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color),
            );
          },
        ),
      ];

  Widget _buildReceivablesTab(
      ThemeData theme, bool isWide, AsyncValue<Paginated<ReceivableListItem>> async) {
    final padX = isWide ? 32.0 : 20.0;
    final danger = theme.extension<PistoTokens>()!.danger;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: _PagedTab<ReceivableListItem>(
          async: async,
          acc: _receivableAcc,
          columns: _receivableColumns(),
          emptyState: const EmptyState(
            icon: LucideIcons.circleCheck,
            title: 'Todo cobrado',
            description:
                'No hay cuentas pendientes. Cuando emitas una factura a crédito aparecerá acá hasta que se pague.',
          ),
          rowAccentColor: (item) => item.receivable.overdue ? danger : null,
          onTap: (item) => _showReceivableDetail(item),
          onLoadMore: () => setState(_receivableAcc.loadMore),
          onRetry: () => ref.invalidate(receivablesListProvider),
        ),
      ),
    );
  }

  // ── Receivable detail with payment history ─────────────────────────────────

  void _showReceivableDetail(ReceivableListItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ar = item.receivable;
    final customerName = item.customerName ?? '';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PistoTokens.radiusCard)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName.isEmpty ? 'Cuenta por cobrar' : customerName,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MonoDetailRow(
                            theme: theme,
                            label: 'Monto original',
                            amount: ar.originalAmountValue,
                            labelWidth: 120),
                        _MonoDetailRow(
                            theme: theme,
                            label: 'Saldo',
                            amount: ar.balanceValue,
                            isNegative: true,
                            labelWidth: 120),
                        DetailRow(
                            theme: theme,
                            label: 'Vencimiento',
                            value: formatDateDisplay(ar.dueDate),
                            labelWidth: 120),
                        const SectionHeading(
                          title: 'Historial de pagos',
                          spaceBefore: 16,
                          spaceAfter: 8,
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final paymentsAsync =
                                ref.watch(receivablePaymentsProvider(ar.id));
                            return AsyncValueWidget(
                              value: paymentsAsync,
                              loading: const Padding(
                                padding: EdgeInsets.all(16),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                              onRetry: () => ref
                                  .invalidate(receivablePaymentsProvider(ar.id)),
                              data: (payments) {
                                if (payments.isEmpty) {
                                  return Text('Sin pagos registrados',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: cs.onSurfaceVariant));
                                }
                                return Column(
                                  children: [
                                    for (final p in payments)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                  formatDateDisplay(
                                                      p.paymentDate),
                                                  style: theme
                                                      .textTheme.bodySmall),
                                            ),
                                            Text(
                                              _fmt.format(p.amountValue),
                                              style: AppTheme.mono(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: cs.secondary),
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
                        const Divider(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showCustomerStatement(
                                  ar.customerId, customerName);
                            },
                            icon: const Icon(LucideIcons.fileChartColumn,
                                size: 16),
                            label: const Text('Ver estado de cuenta'),
                          ),
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
                    if (ar.balanceValue > 0) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _promptWhatsApp(
                            customerName.isEmpty ? 'Cliente' : customerName,
                            ar.balanceValue,
                            DateTime.parse(ar.dueDate),
                            phone: item.customerPhone,
                          );
                        },
                        icon: const Icon(LucideIcons.messageCircle,
                            size: 16, color: AppTheme.whatsappBrand),
                        label: const Text('WhatsApp'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.whatsappBrand,
                          side: BorderSide(
                              color: AppTheme.whatsappBrand
                                  .withValues(alpha: 0.5)),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showPaymentForm(ar);
                        },
                        icon: const Icon(LucideIcons.banknote, size: 16),
                        label: const Text('Registrar abono'),
                      ),
                    ],
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

  // ── Customer statement ─────────────────────────────────────────────────────

  void _showCustomerStatement(String customerId, String customerName) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PistoTokens.radiusCard)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado de cuenta',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Flexible(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final statementAsync =
                          ref.watch(customerStatementProvider(customerId));
                      return AsyncValueWidget(
                        value: statementAsync,
                        onRetry: () => ref
                            .invalidate(customerStatementProvider(customerId)),
                        data: (statement) =>
                            _buildStatement(theme, customerName, statement),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
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

  Widget _buildStatement(
      ThemeData theme, String customerName, CustomerStatement statement) {
    final cs = theme.colorScheme;
    final danger = theme.extension<PistoTokens>()!.danger;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(customerName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          BigFigure(
            label: 'Saldo total',
            value: _fmt.format(statement.totalPending),
            valueColor: context.tokens.dangerText,
          ),
          if (statement.receivables.isNotEmpty) ...[
            const SectionHeading(
              title: 'Detalle',
              spaceBefore: 20,
              spaceAfter: 8,
            ),
            for (final entry in statement.receivables)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.saleNumber ?? '',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w500)),
                          Text(
                            'Vence ${formatDateShortEs(entry.receivable.dueDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _fmt.format(double.parse(entry.receivable.balance)),
                      style: AppTheme.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: danger),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ── Aging tab ──────────────────────────────────────────────────────────────

  Widget _buildAgingTab(
      ThemeData theme, bool isWide, List<AgingBucket> buckets) {
    final cs = theme.colorScheme;
    final padX = isWide ? 32.0 : 20.0;

    if (buckets.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.clock,
        title: 'Sin datos de antigüedad',
        description:
            'Cuando tengas cuentas pendientes, acá vas a ver cuánto debe cada cliente y desde cuándo.',
      );
    }

    // Mapped to a semantic intent by range: more overdue = more severe.
    final tokens = theme.extension<PistoTokens>()!;
    Color colorForRange(String range) => switch (range) {
          'current' => tokens.successText,
          '1-30' => tokens.infoText,
          '31-60' => tokens.warningText,
          '61-90' => AppTheme.accentText,
          '90+' => tokens.dangerText,
          _ => cs.onSurfaceVariant,
        };

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padX, 16, padX, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(title: 'Antigüedad de saldos', spaceBefore: 0),
          Wrap(
            spacing: 40,
            runSpacing: 24,
            children: [
              for (final bucket in buckets)
                SizedBox(
                  width: 150,
                  child: BigFigure(
                    label: _agingLabel(bucket.range),
                    value: _fmt.format(bucket.totalValue),
                    valueColor: colorForRange(bucket.range),
                    caption:
                        '${bucket.count} cuenta${bucket.count == 1 ? '' : 's'}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _agingLabel(String range) {
    return switch (range) {
      'current' => 'Vigente',
      '1-30' => '1 a 30 días',
      '31-60' => '31 a 60 días',
      '61-90' => '61 a 90 días',
      '90+' => 'Más de 90 días',
      _ => range,
    };
  }

  // ── WhatsApp reminder ──────────────────────────────────────────────────────
  // The phone from the join is preloaded; the user can correct it before
  // generating the message.

  Future<void> _promptWhatsApp(
      String customerName, double amount, DateTime dueDate,
      {String? phone}) async {
    // The message goes to a real customer: never a business placeholder.
    final overview = await ref.read(settingsOverviewProvider.future);
    final businessName = overview.business?['name'] as String?;
    if (!mounted) return;
    if (businessName == null || businessName.isEmpty) {
      AppToast.error(context,
          'Configurá el nombre de tu negocio en Ajustes antes de enviar recordatorios de cobro.');
      return;
    }

    await PFormDialog.show(
      context,
      title: 'Número de WhatsApp',
      fields: [
        PTextField(
          name: 'phone',
          label: 'Teléfono (ej: +50312345678)',
          initialValue: phone,
          required: true,
          keyboardType: TextInputType.phone,
          validator: PValidators.phone,
          autofocus: true,
        ),
      ],
      submitLabel: 'Generar',
      onSubmit: (values) async {
        final phone = values['phone'] as String;
        final dueDateStr = '${dueDate.day}/${dueDate.month}/${dueDate.year}';
        final amountStr = '\$${amount.toStringAsFixed(2)}';
        final message = Uri.encodeComponent(
          'Hola $customerName, le saludamos de $businessName.\n'
          'Le recordamos que tiene un saldo pendiente de $amountStr con fecha de vencimiento $dueDateStr.\n'
          'Puede contactarnos para coordinar su pago.\n¡Gracias!',
        );
        final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
        final url = 'https://wa.me/$cleanPhone?text=$message';

        if (!mounted) return;
        AppToast.show(
          context,
          message: 'Mensaje de cobro listo',
          type: ToastType.success,
          actionLabel: 'Copiar URL',
          onAction: () => Clipboard.setData(ClipboardData(text: url)),
        );
      },
    );
  }

  // ── Payment form ───────────────────────────────────────────────────────────

  Future<void> _showPaymentForm(Receivable ar) async {
    final theme = Theme.of(context);
    // The payment requires a payment method (uuid); loaded before opening the form.
    final methods = await ref.read(collectionsPaymentMethodsProvider.future);
    if (!mounted) return;

    await PFormDialog.show(
      context,
      title: 'Registrar abono',
      maxWidth: 340,
      header: Text(
        'Saldo: ${_fmt.format(ar.balanceValue)}',
        style: AppTheme.mono(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      fields: [
        PMoneyField(
          name: 'amount',
          label: 'Monto',
          initialValue: ar.balance,
          required: true,
          positive: true,
        ),
        PSelectField<String>(
          name: 'paymentMethodId',
          label: 'Método de pago',
          options: [for (final m in methods) PSelectOption(m.id, m.name)],
          initialValue: methods.length == 1 ? methods.first.id : null,
          required: true,
        ),
      ],
      submitLabel: 'Pagar',
      successMessage: 'Abono registrado',
      onSubmit: (values) =>
          ref.read(collectionsMutationsProvider.notifier).createPayment(
                ar.id,
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

// ── Private helper widget ─────────────────────────────────────────────────────

class _MonoDetailRow extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final double amount;
  final double labelWidth;
  final bool isNegative;

  const _MonoDetailRow({
    required this.theme,
    required this.label,
    required this.amount,
    this.labelWidth = 120,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(
              currencyFmt.format(amount),
              style: AppTheme.mono(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isNegative ? context.tokens.danger : null,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aging skeleton ───────────────────────────────────────────────────────────
// Mirrors the grid layout: DataList's own skeleton doesn't fit the InfoCard
// grid, so this stays a small local mirror per §1 (never fake zeros).

class _AgingSkeleton extends StatelessWidget {
  const _AgingSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 40,
        runSpacing: 24,
        children: [
          for (var i = 0; i < 5; i++)
            SizedBox(
              width: 150,
              height: 64,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
