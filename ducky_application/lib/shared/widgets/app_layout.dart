import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../app/router.dart';
import '../../core/auth/auth_provider.dart';

/// Layout para la versión móvil — equivalente a AppLayout.tsx
class AppLayout extends StatefulWidget {
  final Widget child;
  const AppLayout({super.key, required this.child});
  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool _menuOpen = false;
  static const _green = Color(0xFF0E7334);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(child: Stack(children: [
        Column(children: [
          // ── Mobile top bar ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Image.asset('assets/images/logo_ducky.png',
                  width: 36, height: 36, fit: BoxFit.contain),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Ducky', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const Text('App Móvil',
                    style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              ]),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _menuOpen = true),
                icon: const Icon(LucideIcons.menu, size: 24, color: Color(0xFF374151)),
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
            ]),
          ),
          // Divider
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          // Content
          Expanded(child: widget.child),
        ]),

        // ── Fullscreen drawer ────────────────────────────────────────
        if (_menuOpen)
          Container(
            color: Colors.white,
            child: SafeArea(child: Column(children: [
              // Drawer header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                child: Row(children: [
                  const Text('Mi Cuenta', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() => _menuOpen = false),
                    icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF374151)),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                  ),
                ]),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // User info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _green,
                    child: Text(user.initials, style: const TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user.name, style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                    Text(user.role.label,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    Text(user.email,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  ]),
                ]),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const Spacer(),

              // Logout
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      context.go(AppRoutes.login);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: const Text('Cerrar Sesión',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ])),
          ),
      ])),
    );
  }
}
