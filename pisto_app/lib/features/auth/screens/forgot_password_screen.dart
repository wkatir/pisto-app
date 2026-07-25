import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/api_client.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/widgets/app_toast.dart';
import '_auth_panel.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).forgotPassword(_emailCtrl.text.trim());
      if (mounted) {
        setState(() {
          _loading = false;
          _sent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.error(context, ApiClient.parseError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_sent) {
      return AuthSplitLayout(
        form: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.tintBg(context, cs.primary),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(LucideIcons.mailCheck, color: cs.primary, size: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Revisá tu correo',
              style: AppTheme.serif(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Si el correo está registrado, te llegarán las instrucciones '
              'para restablecer tu contraseña en unos minutos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('Volver a iniciar sesión', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return AuthSplitLayout(
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Recuperar contraseña',
              style: AppTheme.serif(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribí tu correo y te enviamos las instrucciones.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(LucideIcons.mail, size: 18),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'El correo es requerido';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _loading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                    )
                  : const Text(
                      'Enviar instrucciones',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿La recordaste? ',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
