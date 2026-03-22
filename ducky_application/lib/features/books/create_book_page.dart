import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateBookPage extends StatefulWidget {
  const CreateBookPage({super.key});
  @override
  State<CreateBookPage> createState() => _CreateBookPageState();
}

class _CreateBookPageState extends State<CreateBookPage> {
  final _isbn     = TextEditingController();
  final _title    = TextEditingController();
  final _author   = TextEditingController();
  final _topic    = TextEditingController();
  final _publisher= TextEditingController();
  final _section  = TextEditingController();
  final _price    = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  static const _green = Color(0xFF0E7334);

  @override
  void dispose() {
    for (final c in [_isbn,_title,_author,_topic,_publisher,_section,_price]) c.dispose();
    super.dispose();
  }

  bool get _isValid => _isbn.text.isNotEmpty && _title.text.isNotEmpty &&
      _author.text.isNotEmpty && _topic.text.isNotEmpty &&
      _publisher.text.isNotEmpty && _section.text.isNotEmpty && _price.text.isNotEmpty;

  String? _validateIsbn(String? v) {
    if (v == null || v.isEmpty) return 'El ISBN es requerido';
    if (!RegExp(r'^978-').hasMatch(v)) return 'El ISBN debe estar en formato: 978-XXXXXXXXXX';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            GestureDetector(onTap: () => context.go('/'), child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
            const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
            GestureDetector(onTap: () => context.go('/books'), child: const Text('Libros', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
            const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
            const Text('Agregar Libro', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ]),
          const SizedBox(height: 12),
          const Text('Agregar Nuevo Libro', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const Text('Agregar un nuevo libro al catalogo', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),

          Container(padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Informacion del Libro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 20),
              _Field(ctrl: _isbn,  label: 'ISBN',   hint: 'ej., 978-0134685991', required: true, validator: _validateIsbn, onChange: () => setState((){})),
              const SizedBox(height: 16),
              _Field(ctrl: _title, label: 'Titulo', hint: 'ej., Effective Java',  required: true, onChange: () => setState((){})),
              const SizedBox(height: 16),
              _Field(ctrl: _author, label: 'Autor', hint: 'ej., Joshua Bloch',    required: true, onChange: () => setState((){})),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Field(ctrl: _topic,  label: 'Tema / Categoria', hint: 'ej., Ciencias de la Computacion', required: true, onChange: () => setState((){}))),
                const SizedBox(width: 16),
                Expanded(child: _Field(ctrl: _publisher, label: 'Editorial', hint: 'ej., Addison-Wesley', required: true, onChange: () => setState((){}))),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _Field(ctrl: _section, label: 'Genero', hint: 'ej., Ficcion, Ciencia, Historia', required: true, onChange: () => setState((){}))),
                const SizedBox(width: 16),
                Expanded(child: _Field(ctrl: _price, label: 'Precio', hint: 'ej., 29.99', required: true,
                    keyboard: TextInputType.number, onChange: () => setState((){}))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => context.go('/books'),
                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF374151)))),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isValid ? () {
                if (_formKey.currentState!.validate()) context.go('/books');
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green, disabledBackgroundColor: const Color(0xFFD1D5DB),
                foregroundColor: Colors.white, elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Guardar Libro', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final bool required;
  final String? Function(String?)? validator;
  final TextInputType keyboard;
  final VoidCallback onChange;
  const _Field({required this.ctrl, required this.label, required this.hint,
      this.required = false, this.validator, this.keyboard = TextInputType.text, required this.onChange});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
      if (required) const Text(' *', style: TextStyle(color: Color(0xFFEF4444))),
    ]),
    const SizedBox(height: 6),
    TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: validator,
      onChanged: (_) => onChange(),
      style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0E7334), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
        errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
      ),
    ),
  ]);
}
