import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class CreatePurchasePage extends StatefulWidget {
  const CreatePurchasePage({super.key});
  @override
  State<CreatePurchasePage> createState() => _CreatePurchasePageState();
}

class _CreatePurchasePageState extends State<CreatePurchasePage> {
  String? _selectedIsbn;
  final _titleCtrl   = TextEditingController();
  final _authorCtrl  = TextEditingController();
  final _topicCtrl   = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _qtyCtrl     = TextEditingController(text: '1');
  final _justCtrl    = TextEditingController();
  static const _green = Color(0xFF0E7334);

  @override
  void dispose() {
    for (final c in [_titleCtrl,_authorCtrl,_topicCtrl,_publisherCtrl,_priceCtrl,_qtyCtrl,_justCtrl]) c.dispose();
    super.dispose();
  }

  List<Book> _books = [];
  bool _loadingBooks = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await ApiService.getBooks();
      if (mounted) setState(() { _books = books; _loadingBooks = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingBooks = false);
    }
  }

  void _onBookSelected(String? isbn) {
    setState(() => _selectedIsbn = isbn);
    if (isbn == null) {
      _titleCtrl.clear(); _authorCtrl.clear();
      _topicCtrl.clear(); _publisherCtrl.clear(); _priceCtrl.clear();
      return;
    }
    final book = _books.firstWhere((b) => b.isbn == isbn, orElse: () => _books.first);
    _titleCtrl.text    = book.title;
    _authorCtrl.text   = book.author;
    _topicCtrl.text    = book.topic;
    _publisherCtrl.text = book.publisher;
    _priceCtrl.text    = book.price.toStringAsFixed(2);
  }

  bool get _isValid =>
      _titleCtrl.text.isNotEmpty && _authorCtrl.text.isNotEmpty &&
      _qtyCtrl.text.isNotEmpty && _justCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_loadingBooks) return const Center(child: CircularProgressIndicator(color: _green));
    final books = _books;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Breadcrumb
        Row(children: [
          GestureDetector(onTap: () => context.go('/'),
              child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          GestureDetector(onTap: () => context.go('/purchases'),
              child: const Text('Solicitudes de Compra',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          const Text('Nueva Solicitud',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),

        Row(children: [
          GestureDetector(onTap: () => context.go('/purchases'),
              child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF374151))),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nueva Solicitud de Compra', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            Text('Crear solicitud de compra de ejemplares',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ]),
        ]),
        const SizedBox(height: 24),

        // Book info card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Informacion del Libro', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 20),

            // Book selector
            _fieldLabel('Seleccionar Libro Existente (Opcional)'),
            const SizedBox(height: 6),
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1D5DB))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIsbn,
                  isExpanded: true,
                  hint: const Text('-- Seleccionar libro del catalogo --',
                      style: TextStyle(color: Color(0xFF374151), fontSize: 14)),
                  onChanged: _onBookSelected,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                  items: [
                    const DropdownMenuItem<String>(value: null,
                        child: Text('-- Seleccionar libro del catalogo --')),
                    ...books.map((b) => DropdownMenuItem(
                      value: b.isbn,
                      child: Text('${b.title} - ${b.author}', overflow: TextOverflow.ellipsis),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('O ingrese la informacion manualmente:',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 12),

            // Title + Author
            Row(children: [
              Expanded(child: _Field(ctrl: _titleCtrl,    label: 'Titulo',    hint: 'Titulo del libro',       required: true)),
              const SizedBox(width: 16),
              Expanded(child: _Field(ctrl: _authorCtrl,   label: 'Autor',     hint: 'Nombre del autor',       required: true)),
            ]),
            const SizedBox(height: 16),

            // Topic + Publisher
            Row(children: [
              Expanded(child: _Field(ctrl: _topicCtrl,    label: 'Tema',      hint: 'Tema o categoria',       required: true)),
              const SizedBox(width: 16),
              Expanded(child: _Field(ctrl: _publisherCtrl,label: 'Editorial', hint: 'Nombre de la editorial', required: true)),
            ]),
            const SizedBox(height: 16),

            // Price
            SizedBox(
              width: 300,
              child: _Field(ctrl: _priceCtrl, label: 'Precio', hint: 'Precio del libro', required: true,
                  keyboard: TextInputType.number),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Request details card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Detalles de la Solicitud', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 20),

            _fieldLabel('Cantidad de Ejemplares', required: true),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14),
                decoration: _inputDeco('1'),
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel('Justificacion', required: true),
            const SizedBox(height: 6),
            TextField(
              controller: _justCtrl,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: _inputDeco('Explique la razon de la solicitud de compra...'),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Actions
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
            onPressed: () => context.go('/purchases'),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF374151))),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isValid ? () async {
              try {
                await ApiService.createPurchase({
                  'isbn': _selectedIsbn ?? 'NUEVO',
                  'book_title': _titleCtrl.text.trim(),
                  'author': _authorCtrl.text.trim(),
                  'quantity': int.tryParse(_qtyCtrl.text) ?? 1,
                  'unit_price': double.tryParse(_priceCtrl.text) ?? 0,
                  'justification': _justCtrl.text.trim(),
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Solicitud enviada exitosamente')));
                  context.go('/purchases');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444)));
                }
              }
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green, disabledBackgroundColor: const Color(0xFFD1D5DB),
              foregroundColor: Colors.white, elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Enviar Solicitud', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }

  Widget _fieldLabel(String text, {bool required = false}) => Row(children: [
    Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
    if (required) const Text(' *', style: TextStyle(color: Color(0xFFEF4444))),
  ]);

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _green, width: 2)),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final bool required;
  final TextInputType keyboard;
  const _Field({required this.ctrl, required this.label, required this.hint,
      this.required = false, this.keyboard = TextInputType.text});

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
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
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
