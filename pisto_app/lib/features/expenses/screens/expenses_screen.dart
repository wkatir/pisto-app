import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/uploads_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _categories = [];
  double _totalMonth = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final service = ref.read(expensesServiceProvider);
      final now = DateTime.now();
      final startDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

      final results = await Future.wait([
        service.listCategories(),
        service.listExpenses(startDate: startDate),
        service.getSummary(from: startDate),
      ]);

      setState(() {
        _categories = results[0] as List<Map<String, dynamic>>;
        _expenses = results[1] as List<Map<String, dynamic>>;
        final summary = results[2] as Map<String, dynamic>;
        _totalMonth = double.tryParse(summary['total']?.toString() ?? '0') ?? 0;
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

  Future<void> _showAddExpenseDialog() async {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String? selectedCategoryId;
    DateTime selectedDate = DateTime.now();
    String? receiptUrl;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Registrar gasto'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
                  ),
                  const SizedBox(height: 12),
                  if (_categories.isNotEmpty)
                    DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Categoría (opcional)'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                        ..._categories.map((c) => DropdownMenuItem(
                              value: c['id'] as String,
                              child: Text(c['name'] as String),
                            )),
                      ],
                      onChanged: (v) => setDialogState(() => selectedCategoryId = v),
                    ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(LucideIcons.calendar, size: 18),
                    title: Text(formatDateDisplay(
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}')),
                    trailing: const Icon(LucideIcons.chevronRight, size: 16),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'FOTO DEL RECIBO (OPCIONAL)',
                    style: AppTheme.eyebrow(ctx),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ImagePickerField(
                      currentUrl: receiptUrl,
                      folder: UploadFolder.expenses,
                      shape: ImagePickerShape.rounded,
                      size: 110,
                      placeholderLabel: 'Subir foto\ndel recibo',
                      placeholderIcon: LucideIcons.receipt,
                      onChanged: (url) => setDialogState(() => receiptUrl = url),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (descCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  final service = ref.read(expensesServiceProvider);
                  await service.createExpense(
                    description: descCtrl.text,
                    amount: amountCtrl.text,
                    expenseDate:
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    categoryId: selectedCategoryId,
                    receiptUrl: receiptUrl,
                  );
                  _loadData();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ApiClient.parseError(e))),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;
    final fmt = currencyFmt;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              eyebrow: 'GASTOS · ESTE MES',
              title: 'Adónde se va tu dinero',
              meta: '${_expenses.length} gasto${_expenses.length == 1 ? '' : 's'} registrado${_expenses.length == 1 ? '' : 's'}',
              metaIsMono: true,
              actions: [
                OutlinedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  label: const Text('Actualizar'),
                ),
                FilledButton.icon(
                  onPressed: _showAddExpenseDialog,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Nuevo gasto'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ── Total card (mismo lenguaje que hero del dashboard) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderSubtle(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.tintBg(context, AppTheme.danger),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.trendingDown, size: 20, color: AppTheme.danger),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TOTAL GASTOS DEL MES',
                          style: AppTheme.eyebrow(context, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fmt.format(_totalMonth),
                          style: AppTheme.mono(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.danger,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_expenses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: EmptyState(
                  icon: LucideIcons.receipt,
                  title: 'Sin gastos este mes',
                  description: 'Cuando registrés un gasto aparecerá acá. Empezá a llevar el control de adónde se va tu dinero.',
                  actionLabel: 'Registrar gasto',
                  actionIcon: LucideIcons.plus,
                  onAction: _showAddExpenseDialog,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4),
                    child: Text(
                      'Movimientos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  ..._expenses.map((exp) {
                    final amount = double.tryParse(exp['amount']?.toString() ?? '0') ?? 0;
                    final description = exp['description'] as String? ?? '';
                    final date = formatDateShortEs(exp['expenseDate']?.toString());
                    final categoryName = exp['categoryName']?.toString() ?? '';
                    final receiptUrl = exp['receiptUrl'] as String?;
                    return FinancialListRow(
                      leading: NetworkImageThumb(
                        url: receiptUrl,
                        size: 38,
                        borderRadius: BorderRadius.circular(10),
                        fallback: RowLeadingIcon(
                          icon: LucideIcons.receipt,
                          color: AppTheme.danger,
                          size: 38,
                        ),
                      ),
                      title: description.isEmpty ? 'Gasto sin descripción' : description,
                      subtitleParts: [
                        if (date.isNotEmpty) date,
                        if (categoryName.isNotEmpty) categoryName,
                      ],
                      trailingValue: '−${fmt.format(amount)}',
                      trailingColor: AppTheme.danger,
                      onTap: () => _confirmDelete(exp),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: _expenses.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddExpenseDialog,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Gasto'),
            ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> exp) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text('¿Eliminar "${exp['description'] ?? ''}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(expensesServiceProvider).deleteExpense(exp['id'] as String);
      await _loadData();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(ApiClient.parseError(e))));
    }
  }
}
