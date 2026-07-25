import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/models/paginated.dart';
import '../../../core/services/uploads_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/forms/forms.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/expenses_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  String get _monthStart {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;
    final fmt = currencyFmt;

    final overviewAsync = ref.watch(
      expensesOverviewProvider(startDate: _monthStart),
    );

    return Scaffold(
      body: AsyncValueWidget(
        value: overviewAsync,
        onRetry: () => ref.invalidate(expensesOverviewProvider),
        data: (overview) {
          final categoryNames = {
            for (final c in overview.categories) c.id: c.name,
          };

          return RefreshIndicator(
            onRefresh: () => ref.refresh(
              expensesOverviewProvider(startDate: _monthStart).future,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                isWide ? 32 : 20,
                28,
                isWide ? 32 : 20,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Adónde se va tu dinero',
                    metrics: [
                      MetricChip(
                        label: 'Gastos',
                        value: '${overview.expenses.length}',
                      ),
                    ],
                    actions: [
                      OutlinedButton.icon(
                        onPressed: () => context.go('/ai-scan'),
                        icon: const Icon(LucideIcons.scan, size: 14),
                        label: const Text('Escanear recibo'),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showAddExpenseDialog(
                          context,
                          ref,
                          overview.categories,
                        ),
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Nuevo gasto'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BigFigure(
                    label: 'Total gastos del mes',
                    value: fmt.format(overview.summary.totalValue),
                    size: BigFigureSize.m,
                    valueColor: overview.summary.totalValue > 0
                        ? context.tokens.dangerText
                        : null,
                  ),
                  if (overview.expenses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: EmptyState(
                        icon: LucideIcons.receipt,
                        title: 'Sin gastos este mes',
                        description:
                            'Cuando registrés un gasto aparecerá acá. Empezá a llevar el control de adónde se va tu dinero.',
                        actionLabel: 'Registrar gasto',
                        actionIcon: LucideIcons.plus,
                        onAction: () => _showAddExpenseDialog(
                          context,
                          ref,
                          overview.categories,
                        ),
                      ),
                    )
                  else ...[
                    SectionHeading(title: 'Movimientos'),
                    InfoCard(
                      padding: EdgeInsets.zero,
                      child: DataList<Expense>(
                        data: Paginated(
                          data: overview.expenses,
                          meta: PageMeta(
                            page: 1,
                            limit: overview.expenses.length,
                            total: overview.expenses.length,
                            totalPages: 1,
                          ),
                        ),
                        emptyState: const SizedBox.shrink(),
                        onTap: (exp) => _showExpenseDetail(
                          context,
                          ref,
                          exp,
                          categoryNames,
                        ),
                        columns: [
                          DataListColumn<Expense>(
                            label: 'Fecha',
                            flex: 2,
                            cell: (context, exp) => Text(
                              formatDateShortEs(exp.expenseDate),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          DataListColumn<Expense>(
                            label: 'Descripción',
                            flex: 4,
                            cell: (context, exp) => Text(
                              exp.description.isEmpty
                                  ? 'Gasto sin descripción'
                                  : exp.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataListColumn<Expense>(
                            label: 'Categoría',
                            flex: 3,
                            cell: (context, exp) {
                              final name = categoryNames[exp.categoryId];
                              return name == null
                                  ? const SizedBox.shrink()
                                  : IntentChip(label: name, small: true);
                            },
                          ),
                          DataListColumn<Expense>(
                            label: 'Monto',
                            flex: 2,
                            align: TextAlign.right,
                            isMoney: true,
                            cell: (context, exp) => Text(
                              '−${fmt.format(exp.amountValue)}',
                              style: AppTheme.mono(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.tokens.dangerText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddExpenseDialog(
    BuildContext context,
    WidgetRef ref,
    List<ExpenseCategory> categories,
  ) {
    return PFormDialog.show(
      context,
      title: 'Registrar gasto',
      fields: [
        const PTextField(
          name: 'description',
          label: 'Descripción',
          required: true,
          autofocus: true,
        ),
        const PMoneyField(
          name: 'amount',
          label: 'Monto',
          required: true,
          positive: true,
        ),
        if (categories.isNotEmpty)
          PSelectField<String?>(
            name: 'categoryId',
            label: 'Categoría (opcional)',
            options: [
              const PSelectOption(null, 'Sin categoría'),
              for (final c in categories) PSelectOption(c.id, c.name),
            ],
          ),
        PDateField(
          name: 'expenseDate',
          label: 'Fecha',
          initialValue: DateTime.now(),
          required: true,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        ),
        const _ReceiptField(name: 'receiptUrl'),
      ],
      successMessage: 'Gasto registrado',
      onSubmit: (values) => ref
          .read(expenseMutationsProvider.notifier)
          .create(
            description: values['description'] as String,
            amount: values['amount'] as String,
            expenseDate: values['expenseDate'] as String,
            categoryId: values['categoryId'] as String?,
            receiptUrl: values['receiptUrl'] as String?,
          ),
    );
  }

  /// Tapping a row opens the detail (same pattern as sales/purchases/
  /// collections/inventory); deleting is an explicit action inside the
  /// dialog, not the default result of tapping the row.
  Future<void> _showExpenseDetail(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
    Map<String, String> categoryNames,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final categoryName = categoryNames[expense.categoryId];

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          expense.description.isEmpty
              ? 'Gasto sin descripción'
              : expense.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(
                  theme: theme,
                  label: 'Monto',
                  value: currencyFmt.format(expense.amountValue),
                ),
                DetailRow(
                  theme: theme,
                  label: 'Fecha',
                  value: formatDateDisplay(expense.expenseDate),
                ),
                if (categoryName != null)
                  DetailRow(
                    theme: theme,
                    label: 'Categoría',
                    value: categoryName,
                  ),
                if (expense.receiptUrl != null &&
                    expense.receiptUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  NetworkImageThumb(
                    url: expense.receiptUrl,
                    size: 120,
                    borderRadius: BorderRadius.circular(12),
                    fallback: Icon(
                      LucideIcons.receipt,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDelete(context, ref, expense);
            },
            icon: Icon(LucideIcons.trash2, size: 16, color: cs.error),
            label: Text('Eliminar', style: TextStyle(color: cs.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar gasto',
      description:
          '¿Eliminar "${expense.description}"? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      icon: LucideIcons.trash2,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    await AppToast.guard(
      context,
      () => ref.read(expenseMutationsProvider.notifier).delete(expense.id),
      successMessage: 'Gasto eliminado',
    );
  }
}

/// Form kit field for the receipt photo: uploads via [ImagePickerField]
/// and saves the URL (or null) into the PForm's values.
class _ReceiptField extends StatelessWidget {
  final String name;

  const _ReceiptField({required this.name});

  @override
  Widget build(BuildContext context) {
    final form = PForm.of(context);
    return FormField<String>(
      onSaved: (v) => form.values[name] = (v == null || v.isEmpty) ? null : v,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foto del recibo (opcional)',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: ImagePickerField(
              currentUrl: state.value,
              folder: UploadFolder.expenses,
              shape: ImagePickerShape.rounded,
              size: 110,
              placeholderLabel: 'Subir foto\ndel recibo',
              placeholderIcon: LucideIcons.receipt,
              onChanged: state.didChange,
            ),
          ),
        ],
      ),
    );
  }
}
