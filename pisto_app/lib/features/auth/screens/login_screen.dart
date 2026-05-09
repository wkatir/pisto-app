import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/auth_provider.dart';
import '../../../config/app_theme.dart';
import '../../../i18n/translations.g.dart';
import '_auth_panel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${authState.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else if (authState.hasValue && authState.value != null) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AuthSplitLayout(
      form: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenido de nuevo',
              style: AppTheme.serif(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresá a tu cuenta para continuar.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: t.email,
                prefixIcon: const Icon(LucideIcons.mail, size: 18),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return t.emailRequired;
                if (!v.contains('@')) return t.invalidEmail;
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: t.password,
                prefixIcon: const Icon(LucideIcons.lock, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 6) return t.minChars(count: 6);
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                    )
                  : Text(
                      t.login,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => context.go('/forgot-password'),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No tienes cuenta? ',
                  style: theme.textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: Text(
                    'Crear cuenta',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
