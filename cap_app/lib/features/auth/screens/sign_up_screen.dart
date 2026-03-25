import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_init.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

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
      await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
      if (!mounted) return;

      // Si la session est active directement (email confirmation désactivée)
      if (supabase.auth.currentSession != null) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        // Email de confirmation envoyé
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vérifie ton email pour confirmer ton compte.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.teal.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Une erreur inattendue est survenue.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _loading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF26A69A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/icons/mutuelio_logo_with_name.png',
                      height: 180,
                    ),
                    const SizedBox(height: 36),
                    Card(
                      elevation: 16,
                      shadowColor: Colors.black.withOpacity(0.3),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Créer un compte',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rejoins Mutuellio gratuitement.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.blueGrey.shade400,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _emailCtrl,
                                enabled: !disabled,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration:
                                    _inputDeco('Email', Icons.email_outlined),
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  if (value.isEmpty) return 'Email requis';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                      .hasMatch(value)) return 'Email invalide';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pwdCtrl,
                                enabled: !disabled,
                                obscureText: _obscure,
                                autofillHints: const [
                                  AutofillHints.newPassword
                                ],
                                decoration: _inputDeco(
                                        'Mot de passe', Icons.lock_outline)
                                    .copyWith(
                                  suffixIcon: IconButton(
                                    tooltip:
                                        _obscure ? 'Afficher' : 'Masquer',
                                    onPressed: disabled
                                        ? null
                                        : () => setState(
                                            () => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                validator: (v) =>
                                    (v ?? '').isEmpty ? 'Mot de passe requis' : null,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 16),
                                _ErrorBanner(message: _error!),
                              ],
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: disabled ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00897B),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.teal.shade100,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: Colors.white),
                                        )
                                      : Text(
                                          'Créer un compte',
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Déjà un compte ?',
                                    style: GoogleFonts.poppins(
                                        color: Colors.blueGrey.shade400),
                                  ),
                                  TextButton(
                                    onPressed: disabled
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Se connecter',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF00897B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
  }
}
