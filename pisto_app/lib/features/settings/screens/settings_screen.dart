import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/providers/service_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _business;
  List<Map<String, dynamic>> _taxes = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _loading = true;

  // Controladores para editar negocio
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _currencyCode = 'USD';
  bool _savingBusiness = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final service = ref.read(settingsServiceProvider);
      final results = await Future.wait([
        service.getBusiness(),
        service.listTaxes(),
        service.listPaymentMethods(),
      ]);
      setState(() {
        _business = results[0] as Map<String, dynamic>?;
        _taxes = results[1] as List<Map<String, dynamic>>;
        _paymentMethods = results[2] as List<Map<String, dynamic>>;
        if (_business != null) {
          _nameCtrl.text = _business!['name'] as String? ?? '';
          _phoneCtrl.text = _business!['phone'] as String? ?? '';
          _emailCtrl.text = _business!['email'] as String? ?? '';
          _currencyCode = _business!['currencyCode'] as String? ?? 'USD';
        }
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveBusiness() async {
    setState(() => _savingBusiness = true);
    try {
      await ref.read(settingsServiceProvider).updateBusiness({
        'name': _nameCtrl.text,
        if (_phoneCtrl.text.isNotEmpty) 'phone': _phoneCtrl.text,
        if (_emailCtrl.text.isNotEmpty) 'email': _emailCtrl.text,
        'currencyCode': _currencyCode,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => _savingBusiness = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Negocio'),
                    Tab(text: 'Impuestos'),
                    Tab(text: 'Pagos'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBusinessTab(theme, cs),
                      _buildTaxesTab(theme, cs),
                      _buildPaymentMethodsTab(theme, cs),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessTab(ThemeData theme, ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar cambios',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxesTab(ThemeData theme, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._taxes.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
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
                              ?.copyWith(),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: t['isActive'] as bool? ?? true,
                    onChanged: (v) async {
                      await ref
                          .read(settingsServiceProvider)
                          .toggleTax(t['id'] as String, v);
                      _loadData();
                    },
                  ),
                ],
              ),
            )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Agregar impuesto'),
          onPressed: _showAddTaxDialog,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsTab(ThemeData theme, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._paymentMethods.map((pm) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
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
                    onChanged: (v) async {
                      await ref
                          .read(settingsServiceProvider)
                          .togglePaymentMethod(pm['id'] as String, v);
                      _loadData();
                    },
                  ),
                ],
              ),
            )),
        const SizedBox(height: 8),
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
                  .read(settingsServiceProvider)
                  .createTax(nameCtrl.text, rateCtrl.text);
              _loadData();
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
                  .read(settingsServiceProvider)
                  .createPaymentMethod(nameCtrl.text);
              _loadData();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
