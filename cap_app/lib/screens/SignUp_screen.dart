import 'package:flutter/material.dart';

// NOTE: This is a basic structure. You can reuse the custom widgets from SignIn_screen.dart for a consistent look.

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  bool _obscurePwd = true;
  bool _obscureConfirmPwd = true;

  void _goToSignIn() {
    // Navigate back to the sign-in screen
    Navigator.of(context).pop();
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
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
                color: cs.surface.withOpacity(0.85),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Créer un compte', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pwdCtrl,
                          obscureText: _obscurePwd,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                             suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                              icon: Icon(_obscurePwd ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmPwdCtrl,
                          obscureText: _obscureConfirmPwd,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                             suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscureConfirmPwd = !_obscureConfirmPwd),
                              icon: Icon(_obscureConfirmPwd ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: () {
                              // TODO: Implement registration logic
                            },
                            child: const Text("S'inscrire"),
                          ),
                        ),
                         const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Déjà un compte ?"),
                            TextButton(onPressed: _goToSignIn, child: const Text("Se connecter")),
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
