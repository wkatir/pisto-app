import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/services/uploads_service.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for editing the business — hydrated only once when
  // the first data arrives (see _hydrateBusiness).
  bool _businessHydrated = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _currencyCode = 'USD';
  String? _logoUrl;
  bool _savingBusiness = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _hydrateBusiness(Map<String, dynamic>? business) {
    if (_businessHydrated || business == null) return;
    _businessHydrated = true;
    _nameCtrl.text = business['name'] as String? ?? '';
    _phoneCtrl.text = business['phone'] as String? ?? '';
    _emailCtrl.text = business['email'] as String? ?? '';
    _currencyCode = business['currencyCode'] as String? ?? 'USD';
    _logoUrl = business['logoUrl'] as String?;
  }

  Future<void> _saveBusiness() async {
    setState(() => _savingBusiness = true);
    try {
      await ref.read(settingsMutationsProvider.notifier).updateBusiness({
        'name': _nameCtrl.text,
        if (_phoneCtrl.text.isNotEmpty) 'phone': _phoneCtrl.text,
        if (_emailCtrl.text.isNotEmpty) 'email': _emailCtrl.text,
        'currencyCode': _currencyCode,
        'logoUrl': _logoUrl ?? '',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.parseError(e))),
        );
      }
    }
    if (mounted) setState(() => _savingBusiness = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;

    final overviewAsync = ref.watch(settingsOverviewProvider);
    _hydrateBusiness(overviewAsync.value?.business);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 0),
            child: const PageHeader(title: 'Configuración'),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: PTabs(
              tabs: const [
                PTabItem('Negocio'),
                PTabItem('Impuestos'),
                PTabItem('Pagos'),
              ],
              index: _tabController.index,
              onChanged: (i) => setState(() => _tabController.index = i),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AsyncValueWidget(
              value: overviewAsync,
              onRetry: () => ref.invalidate(settingsOverviewProvider),
              data: (overview) {
                final tabContent = switch (_tabController.index) {
                  0 => _buildBusinessTab(theme, cs, isWide),
                  1 => _buildTaxesTab(theme, cs, isWide, overview.taxes),
                  2 => _buildPaymentMethodsTab(theme, cs, isWide, overview.paymentMethods),
                  _ => const SizedBox.shrink(),
                };
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: KeyedSubtree(
                    key: ValueKey(_tabController.index),
                    child: tabContent,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTab(ThemeData theme, ColorScheme cs, bool isWide) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 4, isWide ? 32 : 20, 24),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeading(title: 'Negocio', spaceBefore: 12),
            // Business logo (rounded square, left-aligned).
            Row(
              children: [
                ImagePickerField(
                  currentUrl: _logoUrl,
                  folder: UploadFolder.logos,
                  shape: ImagePickerShape.rounded,
                  size: 88,
                  placeholderLabel: 'Logo',
                  placeholderIcon: LucideIcons.image,
                  onChanged: (url) => setState(() => _logoUrl = url),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Logo del negocio',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aparecerá en facturas, recibos y otros documentos.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del negocio'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
                isExpanded: true,
              initialValue: _currencyCode,
              decoration: const InputDecoration(labelText: 'Moneda'),
              items: const [
                DropdownMenuItem(value: 'USD', child: Text('USD — Dólar americano')),
                DropdownMenuItem(value: 'GTQ', child: Text('GTQ — Quetzal guatemalteco')),
                DropdownMenuItem(value: 'CRC', child: Text('CRC — Colón costarricense')),
                DropdownMenuItem(value: 'HNL', child: Text('HNL — Lempira hondureño')),
                DropdownMenuItem(value: 'SVC', child: Text('SVC — Colón salvadoreño')),
              ],
              onChanged: (v) => setState(() => _currencyCode = v ?? 'USD'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _savingBusiness ? null : _saveBusiness,
              child: _savingBusiness
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Text(
                      'Guardar cambios',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
    );
  }

  Widget _buildTaxesTab(
    ThemeData theme,
    ColorScheme cs,
    bool isWide,
    List<Map<String, dynamic>> taxes,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 4, isWide ? 32 : 20, 24),
      children: [
        SectionHeading(title: 'Impuestos', spaceBefore: 12),
        for (final t in taxes) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['name'] as String? ?? '',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${t['rate']}%',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: t['isActive'] as bool? ?? true,
                  onChanged: (v) => ref
                      .read(settingsMutationsProvider.notifier)
                      .toggleTax(t['id'] as String, v),
                ),
              ],
            ),
          ),
          if (t != taxes.last) Divider(height: 1, color: cs.outlineVariant),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Agregar impuesto'),
          onPressed: _showAddTaxDialog,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsTab(
    ThemeData theme,
    ColorScheme cs,
    bool isWide,
    List<Map<String, dynamic>> paymentMethods,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 4, isWide ? 32 : 20, 24),
      children: [
        SectionHeading(title: 'Métodos de pago', spaceBefore: 12),
        for (final pm in paymentMethods) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    pm['name'] as String? ?? '',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Switch(
                  value: pm['isActive'] as bool? ?? true,
                  onChanged: (v) => ref
                      .read(settingsMutationsProvider.notifier)
                      .togglePaymentMethod(pm['id'] as String, v),
                ),
              ],
            ),
          ),
          if (pm != paymentMethods.last) Divider(height: 1, color: cs.outlineVariant),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Agregar método de pago'),
          onPressed: _showAddPaymentMethodDialog,
        ),
      ],
    );
  }

  Future<void> _showAddTaxDialog() async {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo impuesto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre (ej: IVA)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateCtrl,
              decoration: const InputDecoration(
                labelText: 'Tasa (%)',
                suffixText: '%',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(settingsMutationsProvider.notifier)
                  .createTax(nameCtrl.text, rateCtrl.text);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPaymentMethodDialog() async {
    final nameCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo método de pago'),
        content: TextField(
          controller: nameCtrl,
          decoration:
              const InputDecoration(labelText: 'Nombre (ej: Efectivo)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(settingsMutationsProvider.notifier)
                  .createPaymentMethod(nameCtrl.text);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
