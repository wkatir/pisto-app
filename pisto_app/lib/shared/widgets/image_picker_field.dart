import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/api_client.dart';
import '../../config/app_theme.dart';
import '../../core/providers/core_providers.dart';
import '../../core/providers/service_providers.dart';
import '../../core/services/uploads_service.dart';

/// Reusable field for uploading and previewing an image.
///
/// Supports three shapes: square (products/receipts), circle (user
/// avatars), and rounded (logos). Handles the whole flow internally: tap →
/// picker → upload → callback with the URL.
///
/// The parent only needs to store the URL ([currentUrl]) and react to the
/// [onChanged] callback with the new URL (or null if it was removed).
enum ImagePickerShape { square, circle, rounded }

class ImagePickerField extends ConsumerStatefulWidget {
  /// Current URL (relative `/uploads/...` or absolute). If null/empty, shows
  /// the icon placeholder.
  final String? currentUrl;

  /// Destination folder on the backend.
  final UploadFolder folder;

  /// Container shape.
  final ImagePickerShape shape;

  /// Size in px (for circle/rounded). Square is responsive.
  final double size;

  /// Placeholder text when there's no image.
  final String placeholderLabel;

  /// Placeholder icon.
  final IconData placeholderIcon;

  /// Callback on upload or delete. Returns the relative URL or null.
  final ValueChanged<String?> onChanged;

  /// If true, allows removing the image by tapping an "X" button.
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
        SnackBar(content: Text('No se pudo abrir el selector de imagen. Verifica los permisos.')),
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
                  title: Text('Quitar foto',
                      style: TextStyle(color: context.tokens.dangerText)),
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
                  httpHeaders: ref.watch(apiClientProvider).authHeaders,
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
        // Floating "edit" button when there's an image, to signal it's tappable.
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

/// Read-only image for displaying in lists/chips/avatars.
/// If the URL is null/empty, shows [fallback] (typically an initials
/// avatar or an icon).
class NetworkImageThumb extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (url == null || url!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      child: CachedNetworkImage(
        imageUrl: resolveUrl(url),
        httpHeaders: ref.watch(apiClientProvider).authHeaders,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => SizedBox(width: size, height: size, child: fallback),
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
