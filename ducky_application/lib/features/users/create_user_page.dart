import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/mock_data.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});
  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _idCtrl = TextEditingController();
  bool _imported = false;
  bool _loading = false;
  Map<String, String>? _importedData;
  String _accountStatus = 'Activo';

  static const _green = Color(0xFF0E7334);

  // Mock external DB lookup
  static const _mockExternal = {
    'STU2024001': {'name': 'Carlos Hernandez', 'type': 'Estudiante', 'email': 'carlos.hernandez@ducky.edu'},
    'STU2024002': {'name': 'Ana Martinez',     'type': 'Estudiante', 'email': 'ana.martinez@ducky.edu'},
    'STU2024003': {'name': 'Pedro Ramirez',    'type': 'Estudiante', 'email': 'pedro.ramirez@ducky.edu'},
    'PRO2023001': {'name': 'Dr. Sofia Torres', 'type': 'Profesor',   'email': 's.torres@ducky.edu'},
    'PRO2023002': {'name': 'Dr. Luis Morales', 'type': 'Profesor',   'email': 'l.morales@ducky.edu'},
    'LIB2022001': {'name': 'Elena Vargas',     'type': 'Bibliotecario', 'email': 'e.vargas@ducky.edu'},
    'LIB2022002': {'name': 'Marco Reyes',      'type': 'Bibliotecario', 'email': 'm.reyes@ducky.edu'},
    'ADM2021001': {'name': 'Director Admin',   'type': 'Administrador', 'email': 'admin@ducky.edu'},
    'ADM2021002': {'name': 'Sub Director',     'type': 'Administrador', 'email': 'subadmin@ducky.edu'},
  };

  Future<void> _importData() async {
    final id = _idCtrl.text.trim().toUpperCase();
    if (id.isEmpty) return;
    setState(() { _loading = true; _imported = false; _importedData = null; });
    await Future.delayed(const Duration(milliseconds: 600));
    final found = _mockExternal[id];
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (found != null) {
        _imported = true;
        _importedData = Map<String, String>.from(found);
      } else {
        _imported = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('ID no encontrado en la base de datos externa'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }

  @override
  void dispose() { _idCtrl.dispose(); super.dispose(); }

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
          GestureDetector(onTap: () => context.go('/users'),
            child: const Text('Usuarios', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          const Text('Crear Usuario', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),
        const Text('Crear Nuevo Usuario', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Importar usuario desde la base de datos externa',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 20),

        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(children: [
            const Icon(LucideIcons.info, size: 16, color: Color(0xFF3B82F6)),
            const SizedBox(width: 10),
            const Expanded(child: Text(
              'Los datos del usuario se importaran automaticamente desde la base de datos externa. '
              'Ingresa la Matricula o ID de Empleado y haz clic en "Importar Datos".',
              style: TextStyle(fontSize: 13, color: Color(0xFF1D4ED8)),
            )),
          ]),
        ),
        const SizedBox(height: 20),

        // Main card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Informacion del Usuario', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 20),

            // ID field + import button
            _fieldLabel('Matricula / ID de Empleado', required: true),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _idCtrl,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _importData(),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'ej., STU2024001, PRO2023001, LIB2022001, ADM2021001',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFD1D5DB)),
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _green, width: 2)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _idCtrl.text.isEmpty ? null : _importData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _imported ? _green : const Color(0xFF6B7280),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: _loading
                    ? const SizedBox(width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(LucideIcons.download, size: 16),
                  label: const Text('Importar Datos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
            ]),

            // Success message
            if (_imported) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(LucideIcons.checkCircle, size: 14, color: Color(0xFF059669)),
                const SizedBox(width: 6),
                const Text('Datos importados exitosamente',
                    style: TextStyle(fontSize: 12, color: Color(0xFF059669))),
              ]),
            ],

            // Imported data
            if (_imported && _importedData != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Datos Importados de la Base de Datos Externa',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _green)),
                  const SizedBox(height: 2),
                  const Text('Verifica que la informacion sea correcta antes de guardar',
                      style: TextStyle(fontSize: 12, color: Color(0xFF059669))),
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel('Nombre Completo'),
                  const SizedBox(height: 6),
                  _readOnlyField(_importedData!['name'] ?? ''),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel('Tipo de Usuario'),
                  const SizedBox(height: 6),
                  _readOnlyField(_importedData!['type'] ?? ''),
                ])),
              ]),
              const SizedBox(height: 16),
              _fieldLabel('Correo Electronico'),
              const SizedBox(height: 6),
              _readOnlyField(_importedData!['email'] ?? ''),
              const SizedBox(height: 16),
              _fieldLabel('Estado de la Cuenta', required: true),
              const SizedBox(height: 6),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _accountStatus,
                    isExpanded: true,
                    onChanged: (v) => setState(() => _accountStatus = v ?? 'Activo'),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                    items: ['Activo', 'Suspendido'].map((s) =>
                      DropdownMenuItem(value: s, child: Text(s))).toList(),
                  ),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 20),

        // Action buttons
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
            onPressed: () => context.go('/users'),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF374151))),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _imported ? () => context.go('/users') : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Guardar Usuario', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 24),

        // Sample IDs card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('IDs de Ejemplo para Pruebas', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _IdColumn('Estudiantes:', ['STU2024001', 'STU2024002', 'STU2024003']),
              _IdColumn('Profesores:', ['PRO2023001', 'PRO2023002']),
              _IdColumn('Bibliotecarios:', ['LIB2022001', 'LIB2022002']),
              _IdColumn('Administradores:', ['ADM2021001', 'ADM2021002']),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) => Row(
    children: [
      Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
          color: Color(0xFF374151))),
      if (required) const Text(' *', style: TextStyle(color: Color(0xFFEF4444))),
    ],
  );

  Widget _readOnlyField(String value) => Container(
    width: double.infinity, height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFD1D5DB)),
    ),
    child: Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
  );
}

class _IdColumn extends StatelessWidget {
  final String title;
  final List<String> ids;
  const _IdColumn(this.title, this.ids);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
      const SizedBox(height: 6),
      ...ids.map((id) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text('- $id', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      )),
    ]),
  );
}