import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/widgets.dart';
import '../../expenses/providers/expenses_providers.dart';

class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final _picker = ImagePicker();

  _ScanStep _step = _ScanStep.pick;
  Uint8List? _imageBytes;
  String? _error;

  final _proveedorCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  List<_ReceiptItem> _items = [];
  double _subtotal = 0;
  double _iva = 0;
  double _total = 0;
  bool _saving = false;

  @override
  void dispose() {
    _proveedorCtrl.dispose();
    _nitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final name = picked.name.toLowerCase();
      final mime = name.endsWith('.png')
          ? 'image/png'
          : name.endsWith('.webp')
              ? 'image/webp'
              : 'image/jpeg';

      setState(() {
        _imageBytes = bytes;
        _step = _ScanStep.processing;
        _error = null;
      });

      await _processImage(bytes, mime);
    } catch (e) {
      setState(() {
        _error = 'No se pudo acceder a la imagen. Verifica que la app tenga permisos de cámara/galería.';
        _step = _ScanStep.pick;
      });
    }
  }

  Future<void> _processImage(Uint8List bytes, String mimeType) async {
    try {
      final base64 = base64Encode(bytes);
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.scanReceipt(base64, mimeType);

      _proveedorCtrl.text = result.vendor ?? '';
      _nitCtrl.text = ''; // NIT isn't part of the typed scan result model

      final fechaRaw = result.date;
      if (fechaRaw != null) {
        final parsed = DateTime.tryParse(fechaRaw);
        if (parsed != null) _fecha = parsed;
      }

      _items = result.items.map((item) {
        return _ReceiptItem(
          descriptionCtrl: TextEditingController(text: item.description ?? ''),
          quantityCtrl: TextEditingController(text: (item.quantity ?? 1).toString()),
          priceCtrl: TextEditingController(text: (item.unitPrice ?? 0).toString()),
        );
      }).toList();

      _iva = result.tax ?? 0;
      _total = result.total ?? 0;
      _subtotal = _total - _iva;

      setState(() {
        _step = _ScanStep.review;
      });
    } catch (e) {
      setState(() {
        _error = ApiClient.parseError(e);
        _step = _ScanStep.pick;
      });
    }
  }

  Future<void> _saveExpense() async {
    setState(() => _saving = true);
    try {
      final description = _proveedorCtrl.text.isNotEmpty
          ? 'Factura: ${_proveedorCtrl.text}'
          : 'Factura escaneada';

      await ref.read(expenseMutationsProvider.notifier).create(
        description: description,
        amount: _total.toStringAsFixed(2),
        expenseDate: dateFmt.format(_fecha),
        notes: _nitCtrl.text.isNotEmpty ? 'NIT: ${_nitCtrl.text}' : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto registrado correctamente')),
        );
        _reset();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.parseError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _reset() {
    setState(() {
      _step = _ScanStep.pick;
      _imageBytes = null;
      _error = null;
      _proveedorCtrl.clear();
      _nitCtrl.clear();
      _fecha = DateTime.now();
      _items = [];
      _subtotal = 0;
      _iva = 0;
      _total = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < Breakpoints.compact;
    final maxWidth = isCompact ? double.infinity : 640.0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 32,
          vertical: isCompact ? 16 : 28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(title: 'Escanear factura'),
                const SizedBox(height: 4),
                Text(
                  'Tomá una foto o seleccioná una imagen desde la galería.',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  _ErrorBanner(message: _error!, onRetry: _reset),
                  const SizedBox(height: 16),
                ],
                switch (_step) {
                  _ScanStep.pick => _buildPicker(cs),
                  _ScanStep.processing => _buildProcessing(cs),
                  _ScanStep.review => _buildReview(cs),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPicker(ColorScheme cs) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PickerButton(
                icon: LucideIcons.camera,
                label: 'Tomar Foto',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PickerButton(
                icon: LucideIcons.image,
                label: 'Galería',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Placeholder illustration — quiet card, icon is the only accent.
        InfoCard(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Column(
              children: [
                const IconBadge(icon: LucideIcons.scanLine, color: AppTheme.info),
                const SizedBox(height: 16),
                Text(
                  'Escaneá una factura para extraer\nlos datos automáticamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessing(ColorScheme cs) {
    return Column(
      children: [
        if (_imageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              _imageBytes!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 32),
        // Transient state — flat, no card.
        Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Procesando factura...',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Extrayendo datos con IA',
              style: TextStyle(
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReview(ColorScheme cs) {
    final theme = Theme.of(context);
    final fmt = currencyFmt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              _imageBytes!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 20),

        TextField(
          controller: _proveedorCtrl,
          decoration: const InputDecoration(labelText: 'Proveedor'),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _nitCtrl,
          decoration: const InputDecoration(labelText: 'NIT'),
        ),
        const SizedBox(height: 12),

        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _fecha,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) setState(() => _fecha = picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Fecha'),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateDisplayFmt.format(_fecha),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Icon(LucideIcons.calendar, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        // Items — flat hairline sections, document-style, no boxed rows.
        SectionHeading(title: 'Items'),
        if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Sin items detectados',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          )
        else
          ..._items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isLast = idx == _items.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${idx + 1}.',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: item.descriptionCtrl,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Descripción',
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: item.quantityCtrl,
                          keyboardType: TextInputType.number,
                          style: AppTheme.mono(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Cant.',
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: item.priceCtrl,
                          keyboardType: TextInputType.number,
                          style: AppTheme.mono(fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Precio',
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: cs.outlineVariant),
                  ],
                ],
              ),
            );
          }),

        // Totales — Subtotal/IVA quiet, Total as the hero mono figure.
        SectionHeading(title: 'Total'),
        _TotalRow(label: 'Subtotal', value: fmt.format(_subtotal)),
        const SizedBox(height: 6),
        _TotalRow(label: 'IVA', value: fmt.format(_iva)),
        const SizedBox(height: 14),
        BigFigure(label: 'Total', value: fmt.format(_total), size: BigFigureSize.m),
        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(LucideIcons.rotateCcw, size: 16),
                label: const Text('Reiniciar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveExpense,
                icon: _saving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Icon(LucideIcons.save, size: 16),
                label: Text(_saving ? 'Guardando...' : 'Guardar como Gasto'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

enum _ScanStep { pick, processing, review }

class _ReceiptItem {
  final TextEditingController descriptionCtrl;
  final TextEditingController quantityCtrl;
  final TextEditingController priceCtrl;

  _ReceiptItem({
    required this.descriptionCtrl,
    required this.quantityCtrl,
    required this.priceCtrl,
  });
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderSubtle(context)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: cs.primary),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InfoCard(
      accentColor: AppTheme.danger,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, size: 18, color: AppTheme.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.onSurface, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;

  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTheme.mono(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
