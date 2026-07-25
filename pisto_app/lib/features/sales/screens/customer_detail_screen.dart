import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../models/invoice.dart';
import '../providers/sales_providers.dart';
import 'create_sale_screen.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  List<DataListColumn<Invoice>> _columns(ThemeData theme, ColorScheme cs) => [
        DataListColumn<Invoice>(
          label: 'Nº',
          flex: 2,
          cell: (context, inv) => Text(
            inv.saleNumber,
            style: AppTheme.mono(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataListColumn<Invoice>(
          label: 'Fecha',
          flex: 2,
          cell: (context, inv) => Text(
            formatDateShortEs(inv.saleDate),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
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
                    label: 'Anulada', intent: ChipIntent.danger, small: true),
            ],
          ),
        ),
        DataListColumn<Invoice>(
          label: 'Total',
          flex: 2,
          isMoney: true,
          cell: (context, inv) => MoneyValue(
            formatted: currencyFmt.format(inv.totalValue),
            size: MoneySize.small,
            color: inv.cancelled ? AppTheme.danger : null,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final overviewAsync = ref.watch(customerOverviewProvider(customerId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainer,
        surfaceTintColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          overviewAsync.value?.customer.displayName ?? '',
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Nueva venta'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, _, _) =>
                        CreateSaleScreen(initialCustomerId: customerId),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                ref.invalidate(customerOverviewProvider(customerId));
              },
            ),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: overviewAsync,
        onRetry: () => ref.invalidate(customerOverviewProvider(customerId)),
        data: (overview) {
          final customer = overview.customer;
          final totalPending = overview.statement.totalPending;
          final creditLimit = customer.creditLimitValue;
          final invoicesPage = overview.invoices;

          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(customerOverviewProvider(customerId).future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                BigFigure(
                  label: 'Balance pendiente',
                  value: currencyFmt.format(totalPending),
                  size: BigFigureSize.l,
                  valueColor: totalPending > 0
                      ? context.tokens.dangerText
                      : context.tokens.successText,
                ),
                if (creditLimit > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Límite de crédito: ',
                          style: theme.textTheme.bodySmall),
                      Text(
                        currencyFmt.format(creditLimit),
                        style: AppTheme.mono(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
                if (customer.phone != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(LucideIcons.phone,
                          size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(customer.phone!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
                if (customer.email != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.mail,
                          size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(customer.email!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
                const SectionHeading(title: 'Últimas facturas'),
                InfoCard(
                  padding: EdgeInsets.zero,
                  child: DataList<Invoice>(
                    columns: _columns(theme, theme.colorScheme),
                    data: invoicesPage,
                    emptyState: const EmptyState.compact(
                      title: 'Sin facturas aún',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
