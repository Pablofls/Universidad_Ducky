import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ── Modelo de permiso ──────────────────────────────────────────────────────────
class _Permission {
  final String id, label, description;
  _Permission(this.id, this.label, this.description);
}

class _PermissionGroup {
  final String title;
  final List<_Permission> permissions;
  _PermissionGroup(this.title, this.permissions);
}

// ── Grupos de permisos ─────────────────────────────────────────────────────────
final _allGroups = [
  _PermissionGroup('Gestión de Usuarios', [
    _Permission('view_users',   'Ver usuarios',   'Ver lista y detalles de usuarios'),
    _Permission('create_users', 'Crear usuarios', 'Crear nuevos usuarios en el sistema'),
    _Permission('delete_users', 'Eliminar usuarios', 'Eliminar usuarios del sistema'),
  ]),
  _PermissionGroup('Gestión de Catálogo', [
    _Permission('view_books',   'Ver libros',     'Ver catálogo de libros'),
    _Permission('create_books', 'Crear libros',   'Agregar nuevos libros al catálogo'),
    _Permission('edit_books',   'Editar libros',  'Modificar información de libros'),
    _Permission('delete_books', 'Eliminar libros','Eliminar libros del catálogo'),
  ]),
  _PermissionGroup('Gestión de Ejemplares', [
    _Permission('view_copies',   'Ver ejemplares',    'Ver inventario de ejemplares'),
    _Permission('create_copies', 'Crear ejemplares',  'Agregar nuevos ejemplares'),
    _Permission('edit_copies',   'Editar ejemplares', 'Modificar información de ejemplares'),
    _Permission('delete_copies', 'Eliminar ejemplares','Eliminar ejemplares del inventario'),
  ]),
  _PermissionGroup('Gestión de Préstamos', [
    _Permission('view_loans',   'Ver préstamos',    'Ver lista de préstamos'),
    _Permission('create_loans', 'Crear préstamos',  'Registrar nuevos préstamos'),
    _Permission('return_loans', 'Devolver libros',  'Registrar devoluciones'),
    _Permission('manage_fines', 'Gestionar multas', 'Administrar multas y pagos'),
  ]),
  _PermissionGroup('Solicitudes de Compra', [
    _Permission('view_purchases',   'Ver solicitudes',    'Ver solicitudes de compra'),
    _Permission('create_purchases', 'Crear solicitudes',  'Crear nuevas solicitudes de compra'),
    _Permission('approve_purchases','Aprobar solicitudes','Aprobar o rechazar solicitudes'),
    _Permission('delete_purchases', 'Eliminar solicitudes','Eliminar solicitudes de compra'),
  ]),
  _PermissionGroup('Búsqueda de Libros', [
    _Permission('search_books',    'Buscar libros',     'Buscar y ver disponibilidad de libros'),
    _Permission('advanced_search', 'Búsqueda avanzada', 'Usar filtros avanzados de búsqueda'),
  ]),
  _PermissionGroup('Reportes y Analíticas', [
    _Permission('view_reports',   'Ver reportes',      'Acceso a reportes y estadísticas'),
    _Permission('export_reports', 'Exportar reportes', 'Exportar datos en formato CSV/PDF'),
  ]),
  _PermissionGroup('Configuración del Sistema', [
    _Permission('manage_permissions', 'Gestionar permisos',   'Configurar permisos de roles'),
    _Permission('system_config',      'Configuración general','Modificar configuración del sistema'),
  ]),
];

// ── Permisos por defecto por rol ───────────────────────────────────────────────
final _defaultPerms = {
  'Estudiante':     {'search_books', 'advanced_search'},
  'Profesor':       {'search_books', 'advanced_search', 'view_books', 'view_copies',
                     'view_loans', 'create_purchases', 'view_purchases', 'view_reports'},
  'Bibliotecario':  {
    'view_users','create_users',
    'view_books','create_books','edit_books','delete_books',
    'view_copies','create_copies','edit_copies','delete_copies',
    'view_loans','create_loans','return_loans','manage_fines',
    'view_purchases','create_purchases','approve_purchases',
    'search_books','advanced_search',
    'view_reports','export_reports',
  },
  'Administrador':  _allGroups.expand((g) => g.permissions).map((p) => p.id).toSet(),
};

// ── Page ───────────────────────────────────────────────────────────────────────
class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});
  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  static const _green = Color(0xFF0E7334);
  final _roles = ['Estudiante', 'Profesor', 'Bibliotecario', 'Administrador'];
  String _selectedRole = 'Administrador';
  late Map<String, Set<String>> _perms;

  @override
  void initState() {
    super.initState();
    // Deep copy
    _perms = _defaultPerms.map((k, v) => MapEntry(k, Set<String>.from(v)));
  }

  Set<String> get _current => _perms[_selectedRole]!;

  int _countFor(String role) => _perms[role]!.length;

  void _toggle(String permId) {
    setState(() {
      if (_current.contains(permId)) {
        _current.remove(permId);
      } else {
        _current.add(permId);
      }
    });
  }

  void _reset() {
    setState(() {
      _perms[_selectedRole] = Set<String>.from(_defaultPerms[_selectedRole]!);
    });
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Permisos de $_selectedRole guardados correctamente'),
      backgroundColor: _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Breadcrumb
        Row(children: [
          GestureDetector(onTap: () => context.go('/'),
              child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          const Text('Permisos', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),

        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Gestión de Permisos', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const Text('Configurar permisos por rol de usuario',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ])),
          // Restablecer
          OutlinedButton.icon(
            onPressed: _reset,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(LucideIcons.rotateCcw, size: 16),
            label: const Text('Restablecer', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 12),
          // Guardar
          ElevatedButton.icon(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(LucideIcons.save, size: 16),
            label: const Text('Guardar Cambios',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 24),

        // Two-column layout
        LayoutBuilder(builder: (ctx, c) {
          final leftW  = 280.0;
          final rightW = c.maxWidth - leftW - 20;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Left panel
            SizedBox(width: leftW, child: Column(children: [
              // Roles card
              Container(
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(children: [
                      const Icon(LucideIcons.shield, size: 18, color: Color(0xFF374151)),
                      const SizedBox(width: 8),
                      const Text('Roles', style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                    ]),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  ..._roles.map((role) {
                    final active = _selectedRole == role;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRole = role),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: active ? _green : Colors.transparent,
                          border: const Border(
                              bottom: BorderSide(color: Color(0xFFF3F4F6))),
                        ),
                        child: Row(children: [
                          Expanded(child: Text(role, style: TextStyle(
                            fontSize: 14,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                            color: active ? Colors.white : const Color(0xFF374151),
                          ))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withOpacity(0.25)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${_countFor(role)}', style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: active ? Colors.white : const Color(0xFF374151),
                            )),
                          ),
                        ]),
                      ),
                    );
                  }),
                ]),
              ),
              const SizedBox(height: 16),
              // Info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(LucideIcons.info, size: 16, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    const Text('Información', style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  ]),
                  const SizedBox(height: 12),
                  const Text(
                    'Los permisos determinan qué acciones puede realizar cada rol en el sistema. '
                    'Selecciona un rol para ver y modificar sus permisos.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                  ),
                ]),
              ),
            ])),
            const SizedBox(width: 20),

            // Right panel — permissions
            Container(
              width: rightW,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Permisos para $_selectedRole', style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  Text('${_current.length} permisos activos',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ]),
                const SizedBox(height: 24),
                ..._allGroups.map((group) => _PermGroup(
                  group: group,
                  activePerms: _current,
                  onToggle: _toggle,
                )),
              ]),
            ),
          ]);
        }),
      ]),
    );
  }
}

// ── Permission group widget ────────────────────────────────────────────────────
class _PermGroup extends StatelessWidget {
  final _PermissionGroup group;
  final Set<String> activePerms;
  final void Function(String) onToggle;
  const _PermGroup({required this.group, required this.activePerms, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(group.title, style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        ...group.permissions.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 20, height: 20,
              child: Checkbox(
                value: activePerms.contains(p.id),
                onChanged: (_) => onToggle(p.id),
                activeColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.label, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text(p.description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ])),
          ]),
        )),
      ]),
    );
  }
}