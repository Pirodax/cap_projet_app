// lib/screens/SignIn_screen.dart
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'demo@local.dev');
  final _pwdCtrl = TextEditingController(text: 'Password123!');
  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;
  String? _error;

  final _repo = _AuthRepository(); // faux backend local

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.signIn(email: _emailCtrl.text, password: _pwdCtrl.text);
      if (!mounted) return;
      // Redirection vers la page principale (définis la route '/main' dans MaterialApp)
      Navigator.of(context).pushReplacementNamed('/main');
    } on _AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Une erreur est survenue. Réessaie.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToSignUp() {
    Navigator.of(context).pushNamed('/signup');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (cs.primary).withOpacity(0.12),
              (cs.tertiary).withOpacity(0.10),
              (cs.surfaceVariant).withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 28,
                      spreadRadius: -8,
                      offset: const Offset(0, 18),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _LogoTitle(),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'you@example.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Email requis';
                            final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
                            if (!ok) return 'Email invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pwdCtrl,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: '••••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscure ? 'Afficher' : 'Masquer',
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                          validator: (v) {
                            final value = v ?? '';
                            if (value.isEmpty) return 'Mot de passe requis';
                            if (value.length < 8) return 'Au moins 8 caractères';
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              onChanged: (v) => setState(() => _remember = v ?? false),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            const Text('Se souvenir de moi'),
                            const Spacer(),
                            TextButton(onPressed: () {}, child: const Text('Mot de passe oublié ?')),
                          ],
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 6),
                          _ErrorBanner(message: _error!),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                                : const Text('Se connecter'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _DividerWithText(text: 'ou'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.apple),
                                label: const Text('Apple'),
                                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.alternate_email),
                                label: const Text('SAML/SSO'),
                                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Nouveau ?"),
                            TextButton(onPressed: _goToSignUp, child: const Text("Créer un compte")),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --- Faux backend local ------------------------------------------------
class _AuthRepository {
  static const _demoEmail = 'demo@local.dev';
  static const _demoPwd = 'Password123!';

  Future<void> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final ok = email.trim().toLowerCase() == _demoEmail && password == _demoPwd;
    if (!ok) throw _AuthException('Identifiants invalides.');
  }
}

class _AuthException implements Exception {
  final String message;
  _AuthException(this.message);
  @override
  String toString() => message;
}

/// --- Petits widgets UI -------------------------------------------------
class _LogoTitle extends StatelessWidget {
  const _LogoTitle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [cs.primary, cs.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 12),
        Text('Bienvenue 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Connecte-toi pour continuer', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: Theme.of(context).textTheme.labelMedium),
        ),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}
