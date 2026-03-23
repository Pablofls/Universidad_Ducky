import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../app/router.dart';
import '../../core/auth/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading    = false;
  bool _obscurePass = true;
  String? _error;

  static const _green = Color(0xFF0E7334);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    final err  = await auth.login(email, password);
    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      final user = auth.currentUser!;
      if (user.role == UserRole.student) {
        context.go('/app');
      } else {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _green,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: SizedBox(
            width: 420,
            child: Column(
              children: [
                // ── Logo ────────────────────────────────────────────────
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo_ducky.png',
                    width: 96, height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Sistema de Gestión Ducky',
                  style: TextStyle(color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text('Universidad Ducky',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14)),
                const SizedBox(height: 28),

                // ── Card ────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Iniciar Sesión', style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827),
                      )),
                      const SizedBox(height: 4),
                      const Text('Selecciona la plataforma e ingresa tus credenciales',
                        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      const SizedBox(height: 24),

                      _fieldLabel('Correo Electrónico'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _handleLogin(),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                        decoration: _inputDeco('ejemplo@ducky.edu',
                          prefix: const Icon(LucideIcons.mail, size: 17, color: Color(0xFF9CA3AF))),
                      ),
                      const SizedBox(height: 16),

                      _fieldLabel('Contraseña'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePass,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _handleLogin(),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                        decoration: _inputDeco('Ingresa tu contraseña',
                          prefix: const Icon(LucideIcons.lock, size: 17, color: Color(0xFF9CA3AF)),
                          suffix: IconButton(
                            icon: Icon(_obscurePass ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 17, color: const Color(0xFF9CA3AF)),
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          )),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(children: [
                            const Icon(LucideIcons.alertCircle, size: 15, color: Color(0xFFEF4444)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!, style: const TextStyle(
                                color: Color(0xFFEF4444), fontSize: 13))),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity, height: 46,
                        child: ElevatedButton(
                          onPressed: (_loading || _emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty)
                              ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            disabledBackgroundColor: const Color(0xFFAAD4B8),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white70,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _loading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(LucideIcons.logIn, size: 18),
                                SizedBox(width: 8),
                                Text('Iniciar Sesión', style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                              ]),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),
                      Center(child: Text('Sistema de Gestión de Biblioteca v1.0',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text, style: const TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151),
  ));

  InputDecoration _inputDeco(String hint, {Widget? prefix, Widget? suffix}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
      prefixIcon: prefix, suffixIcon: suffix,
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _green, width: 2),
      ),
    );
}
