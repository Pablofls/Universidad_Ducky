import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/router.dart';
import '../../core/auth/auth_provider.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  final List<UserRole> roles;
  const _NavItem({required this.label, required this.icon,
      required this.route, required this.roles});
}

const _adminNav = [
  _NavItem(label: 'Tablero',               icon: LucideIcons.layoutDashboard, route: AppRoutes.dashboard,   roles: [UserRole.administrator, UserRole.librarian]),
  _NavItem(label: 'Usuarios',              icon: LucideIcons.users,           route: AppRoutes.users,       roles: [UserRole.administrator, UserRole.librarian]),
  _NavItem(label: 'Libros',               icon: LucideIcons.book,            route: AppRoutes.books,       roles: [UserRole.administrator, UserRole.librarian]),
  _NavItem(label: 'Ejemplares',            icon: LucideIcons.bookCopy,        route: AppRoutes.copies,      roles: [UserRole.administrator, UserRole.librarian]),
  _NavItem(label: 'Préstamos',             icon: LucideIcons.calendar,        route: AppRoutes.loans,       roles: [UserRole.administrator, UserRole.librarian]),
  _NavItem(label: 'Solicitudes de Compra', icon: LucideIcons.shoppingCart,    route: AppRoutes.purchases,   roles: [UserRole.administrator, UserRole.librarian]),
  _NavItem(label: 'Permisos',              icon: LucideIcons.shield,          route: AppRoutes.permissions, roles: [UserRole.administrator]),
];

const _studentNav = [
  _NavItem(label: 'Buscar Libros', icon: LucideIcons.search,
      route: AppRoutes.studentSearch, roles: [UserRole.student]),
];

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          const _Sidebar(),
          Expanded(child: ClipRect(child: child)),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    final isStudent = user.role == UserRole.student;
    final navItems  = isStudent
        ? _studentNav
        : _adminNav.where((i) => i.roles.contains(user.role)).toList();

    return Container(
      width: 200,
      color: Colors.white,
      child: Column(
        children: [
          // ── Logo ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                // Logo
                
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5E6C8),
                    border: Border.all(color: const Color(0xFFB8960C), width: 2),
                  ),
                  child: const Center(
                    child: Text('D', style: TextStyle(
                      color: Color(0xFF0E7334),
                      fontSize: 20, fontWeight: FontWeight.w900,
                    )),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ducky', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    )),
                    Text('Sistema de Gestión', style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500,
                    )),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Nav items ─────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: navItems.map((item) => _NavTile(item: item)).toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── User + logout ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFE5E7EB),
                    child: Text(user.initials, style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    )),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ), overflow: TextOverflow.ellipsis),
                        Text(user.role.label, style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500,
                        )),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      context.go(AppRoutes.login);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(LucideIcons.logOut, size: 15),
                    label: const Text('Cerrar Sesión',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  const _NavTile({required this.item});

  bool _isActive(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (item.route == AppRoutes.dashboard) return loc == '/';
    return loc.startsWith(item.route);
  }

  @override
  Widget build(BuildContext context) {
    final active = _isActive(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: active ? const Color(0xFF0E7334) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: active ? null : const Color(0xFFF3F4F6),
          onTap: () => context.go(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Icon(item.icon, size: 18,
                  color: active ? Colors.white : const Color(0xFF374151)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.label, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: active ? Colors.white : const Color(0xFF374151),
                )),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}