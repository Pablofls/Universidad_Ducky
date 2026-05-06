import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/router.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _searchCtrl = TextEditingController();
  String _roleFilter = 'Todos';
  List<AppUser> _users = [];
  AppUser? _userToDelete;

  static const _green = Color(0xFF0E7334);

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await ApiService.getUsers();
      if (mounted) setState(() { _users = users; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AppUser> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return _users.where((u) {
      final matchSearch = q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.id.toLowerCase().contains(q);
      final matchRole = _roleFilter == 'Todos' || u.role.label == _roleFilter;
      return matchSearch && matchRole;
    }).toList();
  }

  void _confirmDelete(AppUser user) {
    setState(() => _userToDelete = user);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(children: [
          Text('Eliminar Usuario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        content: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(LucideIcons.alertTriangle,
                size: 18, color: Color(0xFFEF4444)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '¿Está seguro de que desea eliminar a ${user.name}? Esta acción no se puede deshacer.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF374151))),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.deleteUser(user.id);
                setState(() => _users.removeWhere((u) => u.id == user.id));
              } catch (_) {}
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0E7334)));
    }
    final filtered = _filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Breadcrumb
        Row(children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF)),
          ),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          const Text('Usuarios', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),

        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Gestión de Usuarios', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const SizedBox(height: 2),
            const Text('Administrar usuarios del sistema y permisos',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ])),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.userCreate),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Agregar Usuario',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 24),

        // Search + filter row
        Row(children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o ID...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF9CA3AF)),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _green, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.filter, size: 18, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          _RoleDropdown(
            value: _roleFilter,
            onChanged: (v) => setState(() => _roleFilter = v ?? 'Todos'),
          ),
        ]),
        const SizedBox(height: 16),

        // Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(children: [
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(children: const [
                Expanded(flex: 2, child: _ColHeader('ID USUARIO')),
                Expanded(flex: 3, child: _ColHeader('NOMBRE')),
                Expanded(flex: 4, child: _ColHeader('CORREO ELECTRÓNICO')),
                Expanded(flex: 2, child: _ColHeader('ROL')),
                Expanded(flex: 2, child: _ColHeader('ESTADO')),
                Expanded(flex: 2, child: _ColHeader('ACCIONES')),
              ]),
            ),
            // Rows
            ...filtered.map((u) => _UserRow(
              user: u,
              onView: () => context.go('/users/${u.id}'),
              onDelete: () => _confirmDelete(u),
            )),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No se encontraron usuarios',
                    style: TextStyle(color: Color(0xFF9CA3AF)))),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: Color(0xFF9CA3AF), letterSpacing: 0.5,
  ));
}

class _UserRow extends StatelessWidget {
  final AppUser user;
  final VoidCallback onView, onDelete;
  const _UserRow({required this.user, required this.onView, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(children: [
        Expanded(flex: 2, child: Text(user.id,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: Color(0xFF111827)))),
        Expanded(flex: 3, child: Text(user.name,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 4, child: Text(user.email,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: Text(user.role.label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: _StatusBadge(user.isActive)),
        Expanded(flex: 2, child: Row(children: [
          IconButton(
            onPressed: onView,
            icon: const Icon(LucideIcons.eye, size: 17, color: Color(0xFF9CA3AF)),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(LucideIcons.trash2, size: 17, color: Color(0xFF9CA3AF)),
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          ),
        ])),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge(this.active);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(active ? 'Activo' : 'Suspendido',
      style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: active ? const Color(0xFF059669) : const Color(0xFFEF4444),
      )),
  );
}

class _RoleDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        items: ['Todos', 'Estudiante', 'Profesor', 'Bibliotecario', 'Administrador']
          .map((r) => DropdownMenuItem(value: r, child: Text(r == 'Todos' ? 'Todos los Roles' : r)))
          .toList(),
      ),
    ),
  );
}