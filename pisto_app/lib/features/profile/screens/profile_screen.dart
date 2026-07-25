import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/services/uploads_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _me;
  bool _saving = false;
  String? _avatarUrl;

  // The controllers hydrate only once when the first data arrives
  // (see _hydrateMe): avoids stomping what the user is editing when
  // the provider refreshes after saving.
  bool _hydrated = false;

  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _hydrateMe(Map<String, dynamic> me) {
    if (_hydrated) return;
    _hydrated = true;
    _me = me;
    _firstNameCtrl.text = me['firstName']?.toString() ?? '';
    _lastNameCtrl.text = me['lastName']?.toString() ?? '';
    _emailCtrl.text = me['email']?.toString() ?? '';
    _phoneCtrl.text = me['phone']?.toString() ?? '';
    _avatarUrl = me['avatarUrl'] as String?;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updated = await ref.read(profileMutationsProvider.notifier).update(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? '' : _phoneCtrl.text.trim(),
        avatarUrl: _avatarUrl ?? '',
      );
      if (!mounted) return;
      setState(() {
        _me = updated;
        _saving = false;
      });
      // Refreshes the global UserModel so sidebar/AppBar show the
      // updated avatar and name without waiting for the next login.
      await ref.read(authProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiClient.parseError(e))),
      );
    }
  }

  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(LucideIcons.keyRound, size: 20, color: Theme.of(ctx).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Cambiar contraseña'),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: currentCtrl,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Contraseña actual',
                        prefixIcon: const Icon(LucideIcons.lock, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? LucideIcons.eye : LucideIcons.eyeOff, size: 18),
                          onPressed: () => setLocal(() => obscure = !obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newCtrl,
                      obscureText: obscure,
                      decoration: const InputDecoration(
                        labelText: 'Nueva contraseña',
                        prefixIcon: Icon(LucideIcons.lockKeyhole, size: 18),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
                        if (!RegExp(r'[A-Za-z]').hasMatch(v)) return 'Debe contener una letra';
                        if (!RegExp(r'[0-9]').hasMatch(v)) return 'Debe contener un número';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmCtrl,
                      obscureText: obscure,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar nueva contraseña',
                        prefixIcon: Icon(LucideIcons.lockKeyhole, size: 18),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (v != newCtrl.text) return 'No coincide';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ref.read(profileMutationsProvider.notifier).changePassword(
                          currentPassword: currentCtrl.text,
                          newPassword: newCtrl.text,
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Contraseña actualizada')),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(ApiClient.parseError(e))),
                    );
                  }
                },
                child: const Text('Cambiar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > Breakpoints.gridDense;

    final meAsync = ref.watch(profileMeProvider);
    if (meAsync.hasValue) _hydrateMe(meAsync.value!);

    return Scaffold(
      body: AsyncValueWidget(
        value: meAsync,
        onRetry: () => ref.invalidate(profileMeProvider),
        data: (_) => _buildContent(context, theme, cs, isWide),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    bool isWide,
  ) {
    final initials = _initials(
      _firstNameCtrl.text.trim(),
      _lastNameCtrl.text.trim(),
    );

    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 28, isWide ? 32 : 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(title: 'Tu perfil'),
            const SizedBox(height: 4),
            Text(
              'Editá tu información personal y la contraseña.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            // ── Identity (flat, no card) ──
            Row(
                children: [
                  // Editable avatar: shows the photo if there is one, else
                  // the initials with tap-to-upload on top.
                  Stack(
                    children: [
                      _avatarUrl?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: NetworkImageThumb(
                                url: _avatarUrl,
                                size: 72,
                                borderRadius: BorderRadius.circular(20),
                                fallback: _AvatarInitials(initials: initials),
                              ),
                            )
                          : SizedBox(
                              width: 72,
                              height: 72,
                              child: _AvatarInitials(initials: initials),
                            ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              await showModalBottomSheet<void>(
                                context: context,
                                showDragHandle: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (sheetCtx) => SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: ImagePickerField(
                                      currentUrl: _avatarUrl,
                                      folder: UploadFolder.avatars,
                                      shape: ImagePickerShape.circle,
                                      size: 140,
                                      placeholderLabel: 'Subir foto',
                                      placeholderIcon: LucideIcons.camera,
                                      onChanged: (url) async {
                                        Navigator.pop(sheetCtx);
                                        setState(() => _avatarUrl = url);
                                        await _save();
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Icon(LucideIcons.camera, size: 11, color: cs.onPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_firstNameCtrl.text} ${_lastNameCtrl.text}'.trim(),
                          style: AppTheme.serif(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _emailCtrl.text,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_me?['businessName'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.tintBg(context, cs.primary),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.building2, size: 11, color: cs.primary),
                                const SizedBox(width: 5),
                                Text(
                                  _me!['businessName']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            SectionHeading(title: 'Información personal'),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    LayoutBuilder(builder: (ctx, c) {
                      final stack = c.maxWidth < Breakpoints.formStack;
                      final firstName = TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      );
                      final lastName = TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(labelText: 'Apellido'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      );
                      return stack
                          ? Column(children: [firstName, const SizedBox(height: 12), lastName])
                          : Row(children: [Expanded(child: firstName), const SizedBox(width: 12), Expanded(child: lastName)]);
                    }),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(LucideIcons.mail, size: 18),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono (opcional)',
                        prefixIcon: Icon(LucideIcons.phone, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
                              : const Icon(LucideIcons.check, size: 16),
                          label: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            SectionHeading(title: 'Seguridad'),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contraseña',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Cambia tu contraseña por una nueva.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(LucideIcons.pencil, size: 14),
                  label: const Text('Cambiar'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // ── Session ── the ONE sanctioned alert card: accent edge signals
            // the destructive action.
            InfoCard(
              title: 'Sesión',
              accentColor: AppTheme.danger,
              child: Row(
                children: [
                  IconBadge(icon: LucideIcons.logOut, color: AppTheme.danger),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cerrar sesión',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          'Saldrás de tu cuenta en este dispositivo.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      await ref.read(authProvider.notifier).logout();
                      router.go('/login');
                    },
                    icon: const Icon(LucideIcons.logOut, size: 14),
                    label: const Text('Salir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  String _initials(String first, String last) {
    final f = first.isEmpty ? '' : first[0].toUpperCase();
    final l = last.isEmpty ? '' : last[0].toUpperCase();
    final result = '$f$l';
    return result.isEmpty ? '?' : result;
  }
}

class _AvatarInitials extends StatelessWidget {
  final String initials;
  const _AvatarInitials({required this.initials});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.tintBg(context, cs.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTheme.serif(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: cs.primary,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
