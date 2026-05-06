import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  String _customerType = 'person';
  bool _submitting = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _taxIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(salesServiceProvider).createCustomer({
        'customerType': _customerType,
        if (_firstNameCtrl.text.isNotEmpty) 'firstName': _firstNameCtrl.text,
        if (_lastNameCtrl.text.isNotEmpty) 'lastName': _lastNameCtrl.text,
        if (_companyCtrl.text.isNotEmpty) 'companyName': _companyCtrl.text,
        if (_emailCtrl.text.isNotEmpty) 'email': _emailCtrl.text,
        if (_phoneCtrl.text.isNotEmpty) 'phone': _phoneCtrl.text,
        if (_addressCtrl.text.isNotEmpty) 'address': _addressCtrl.text,
        if (_taxIdCtrl.text.isNotEmpty) 'taxId': _taxIdCtrl.text,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Cliente'),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < Breakpoints.formStack;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _customerType,
                    decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'person', child: Text('Persona')),
                      DropdownMenuItem(value: 'company', child: Text('Empresa')),
                    ],
                    onChanged: (v) => setState(() => _customerType = v ?? 'person'),
                  ),
                  const SizedBox(height: 16),
                  if (_customerType == 'person') ...[
                    if (isNarrow) ...[
                      TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder())),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameCtrl,
                              decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder()))),
                        ],
                      ),
                  ] else
                    TextFormField(
                      controller: _companyCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre Empresa', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _taxIdCtrl, decoration: const InputDecoration(labelText: 'NIT / DUI', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  if (isNarrow) ...[
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null; // opcional
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v)) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null; // opcional
                        if (!RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(v)) return 'Teléfono inválido (7-15 dígitos)';
                        return null;
                      },
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return null; // opcional
                              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(v)) return 'Email inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return null; // opcional
                              if (!RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(v)) return 'Teléfono inválido (7-15 dígitos)';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()), maxLines: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
