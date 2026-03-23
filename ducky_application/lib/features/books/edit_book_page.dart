import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/mock_data.dart';

class EditBookPage extends StatefulWidget {
  final String isbn;
  const EditBookPage({super.key, required this.isbn});
  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  late final TextEditingController _title, _author, _topic, _publisher, _section, _price;
  static const _green = Color(0xFF0E7334);

  @override
  void initState() {
    super.initState();
    final book = MockData.books.firstWhere((b) => b.isbn == widget.isbn, orElse: () => MockData.books.first);
    _title     = TextEditingController(text: book.title);
    _author    = TextEditingController(text: book.author);
    _topic     = TextEditingController(text: book.topic);
    _publisher = TextEditingController(text: book.publisher);
    _section   = TextEditingController(text: book.section);
    _price     = TextEditingController(text: book.price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    for (final c in [_title,_author,_topic,_publisher,_section,_price]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => context.go('/'), child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          GestureDetector(onTap: () => context.go('/books'), child: const Text('Libros', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          GestureDetector(onTap: () => context.go('/books/${Uri.encodeComponent(widget.isbn)}'), child: Text(widget.isbn, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          const Text('Editar', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),
        const Text('Editar Libro', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const Text('Actualizar informacion del libro', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),

        Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Informacion del Libro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 4),
            Text('ISBN: ${widget.isbn} (no puede ser editado)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 20),
            _EditField(ctrl: _title,  label: 'Titulo',          required: true),
            const SizedBox(height: 16),
            _EditField(ctrl: _author, label: 'Autor',           required: true),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _EditField(ctrl: _topic,  label: 'Tema / Categoria', required: true)),
              const SizedBox(width: 16),
              Expanded(child: _EditField(ctrl: _publisher, label: 'Editorial',     required: true)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _EditField(ctrl: _section, label: 'Genero',  required: true)),
              const SizedBox(width: 16),
              Expanded(child: _EditField(ctrl: _price,   label: 'Precio',  required: true, keyboard: TextInputType.number)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => context.go('/books/${Uri.encodeComponent(widget.isbn)}'),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF374151)))),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.go('/books/${Uri.encodeComponent(widget.isbn)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool required;
  final TextInputType keyboard;
  const _EditField({required this.ctrl, required this.label, this.required = false, this.keyboard = TextInputType.text});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
      if (required) const Text(' *', style: TextStyle(color: Color(0xFFEF4444))),
    ]),
    const SizedBox(height: 6),
    TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF0E7334), width: 2)),
      ),
    ),
  ]);
}