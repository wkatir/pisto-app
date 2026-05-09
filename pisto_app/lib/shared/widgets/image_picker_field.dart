import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/api_client.dart';
import '../../config/app_theme.dart';
import '../../core/providers/service_providers.dart';
import '../../core/services/uploads_service.dart';

/// Campo reutilizable para subir y previsualizar una imagen.
///
/// Soporta tres formas: cuadrada (productos/recibos), círculo (avatares de
/// usuario) y redondeada (logos). Maneja todo el flujo internamente: tap →
/// picker → upload → callback con URL.
///
/// El padre solo necesita guardar la URL ([currentUrl]) y reaccionar al
/// callback [onChanged] con la nueva URL (o null si se borró).
enum ImagePickerShape { square, circle, rounded }

class ImagePickerField extends ConsumerStatefulWidget {
  /// URL actual (relativa `/uploads/...` o absoluta). Si es null/empty se
  /// muestra el placeholder con ícono.
  final String? currentUrl;

  /// Carpeta destino en el backend.
  final UploadFolder folder;

  /// Forma del contenedor.
  final ImagePickerShape shape;

  /// Tamaño en px (para circle/rounded). Square es responsive.
  final double size;

  /// Texto del placeholder cuando no hay imagen.
  final String placeholderLabel;

  /// Ícono del placeholder.
  final IconData placeholderIcon;

  /// Callback cuando se sube o borra. Devuelve la URL relativa o null.
  final ValueChanged<String?> onChanged;

  /// Si true, permite borrar la imagen tocando un botón "X".
  final bool allowRemove;

  const ImagePickerField({
    super.key,
    required this.currentUrl,
    required this.folder,
    required this.onChanged,
    this.shape = ImagePickerShape.square,
    this.size = 96,
    this.placeholderLabel = 'Subir foto',
    this.placeholderIcon = LucideIcons.imagePlus,
    this.allowRemove = true,
  });

  @override
  ConsumerState<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends ConsumerState<ImagePickerField> {
  bool _uploading = false;

  Future<void> _pick(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final XFile? file;
    try {
      file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo abrir el selector: $e')),
      );
      return;
    }
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final url = await ref.read(uploadsServiceProvider).uploadImage(
            bytes: bytes,
            filename: file.name,
            folder: widget.folder,
            mimeType: file.mimeType,
          );
      if (!mounted) return;
      widget.onChanged(url);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(ApiClient.parseError(e))),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _showSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text('Elegir de galería'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.gallery);
                },
              ),
              if (widget.allowRemove && (widget.currentUrl?.isNotEmpty ?? false))
                ListTile(
                  leading: Icon(LucideIcons.trash2, color: AppTheme.danger),
                  title: Text('Quitar foto', style: TextStyle(color: AppTheme.danger)),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onChanged(null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasImage = widget.currentUrl?.isNotEmpty ?? false;

    final radius = switch (widget.shape) {
      ImagePickerShape.circle => widget.size / 2,
      ImagePickerShape.rounded => 16.0,
      ImagePickerShape.square => 14.0,
    };

    final box = Container(
      width: widget.size,
      height: widget.size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppTheme.borderSubtle(context)),
      ),
      child: _uploading
          ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)))
          : hasImage
              ? CachedNetworkImage(
                  imageUrl: resolveUrl(widget.currentUrl),
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: cs.surfaceContainerHigh,
                    alignment: Alignment.center,
                    child: const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, _, _) => Center(
                    child: Icon(LucideIcons.imageOff, size: 22, color: cs.onSurfaceVariant),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.placeholderIcon, size: widget.size * 0.28, color: cs.onSurfaceVariant),
                      const SizedBox(height: 6),
                      Text(
                        widget.placeholderLabel,
                        style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
    );

    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: _uploading ? null : _showSourceSheet,
            borderRadius: BorderRadius.circular(radius),
            child: box,
          ),
        ),
        // Botón flotante "editar" cuando hay imagen, para indicar que es tap-able.
        if (hasImage && !_uploading)
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderSubtle(context)),
              ),
              alignment: Alignment.center,
              child: Icon(LucideIcons.pencil, size: 13, color: cs.onSurface),
            ),
          ),
      ],
    );
  }
}

/// Imagen de solo lectura para mostrar en listas/chips/avatares.
/// Si la URL es null/empty, muestra [fallback] (típicamente un avatar de
/// iniciales o un ícono).
class NetworkImageThumb extends StatelessWidget {
  final String? url;
  final double size;
  final BorderRadius? borderRadius;
  final Widget fallback;

  const NetworkImageThumb({
    super.key,
    required this.url,
    required this.fallback,
    this.size = 40,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      child: CachedNetworkImage(
        imageUrl: resolveUrl(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => SizedBox(width: size, height: size, child: fallback),
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
