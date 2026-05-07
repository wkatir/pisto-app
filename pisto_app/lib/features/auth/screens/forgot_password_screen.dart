import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/core_providers.dart';
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
      final authService = ref.read(authServiceProvider);
      await authService.forgotPassword(_emailCtrl.text.trim());
    } catch (e, st) {
      debugPrint('forgotPassword failed: $e\n$st');
    } finally {
      if (mounted) setState(() { _loading = false; _sent = true; });
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
              width: 52, height: 52,
              decoration: BoxDecoration(color: AppTheme.tintBg(context, cs.primary), borderRadius: BorderRadius.circular(14)),
              child: Icon(LucideIcons.mailCheck, color: cs.primary, size: 24),
            ),
            const SizedBox(height: 20),
            Text('Revisá tu correo', style: AppTheme.serif(fontSize: 28, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5, height: 1.1)),
            const SizedBox(height: 10),
            Text('Si el email está registrado, recibirás instrucciones para restablecer tu contraseña.', style: theme.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75), height: 1.5)),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('Volver al inicio de sesión', style: TextStyle(fontWeight: FontWeight.w600)),
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
            Text('Recuperar contraseña', style: AppTheme.serif(fontSize: 28, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5, height: 1.1)),
            const SizedBox(height: 10),
            Text('Ingresá tu email y te enviaremos instrucciones.', style: theme.textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75), height: 1.4)),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(LucideIcons.mail, size: 18),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'El email es requerido';
                if (!v.contains('@')) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar instrucciones', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Recordaste tu contraseña? ', style: theme.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text('Iniciar sesión', style: theme.textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
