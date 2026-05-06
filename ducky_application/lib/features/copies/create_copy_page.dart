import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class CreateCopyPage extends StatefulWidget {
  const CreateCopyPage({super.key});
  @override
  State<CreateCopyPage> createState() => _CreateCopyPageState();
}

class _CreateCopyPageState extends State<CreateCopyPage> {
  final _idCtrl       = TextEditingController();
  final _locationCtrl = TextEditingController();
  String? _selectedIsbn;
  String _status    = 'Available';
  String _condition = 'Good';
  static const _green = Color(0xFF0E7334);

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

  @override
  void dispose() { _idCtrl.dispose(); _locationCtrl.dispose(); super.dispose(); }

  bool get _isValid =>
      _idCtrl.text.isNotEmpty && _selectedIsbn != null && _locationCtrl.text.isNotEmpty;

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
          GestureDetector(onTap: () => context.go('/copies'),
              child: const Text('Copies', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          const Text('Add Copy', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),
        const Text('Add New Copy', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const Text('Add a physical copy to the inventory',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Copy Information', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 20),

            // Copy ID
            _fieldLabel('Copy ID / Barcode', required: true),
            const SizedBox(height: 6),
            TextField(
              controller: _idCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: _inputDeco('e.g., C001, BAR123456'),
            ),
            const SizedBox(height: 16),

            // Book dropdown
            _fieldLabel('Book (ISBN)', required: true),
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
                  value: _selectedIsbn,
                  isExpanded: true,
                  hint: const Text('Select a book...', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 14)),
                  onChanged: (v) => setState(() => _selectedIsbn = v),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                  items: books.map((b) => DropdownMenuItem(
                    value: b.isbn,
                    child: Text('${b.isbn} - ${b.title}', overflow: TextOverflow.ellipsis),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status + Condition
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Status', required: true),
                const SizedBox(height: 6),
                _Dropdown(
                  value: _status,
                  items: const ['Available', 'Borrowed', 'Reserved', 'Internal Use', 'Damaged'],
                  onChanged: (v) => setState(() => _status = v ?? 'Available'),
                ),
              ])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _fieldLabel('Condition', required: true),
                const SizedBox(height: 6),
                _Dropdown(
                  value: _condition,
                  items: const ['New', 'Good', 'Fair', 'Poor', 'Damaged'],
                  onChanged: (v) => setState(() => _condition = v ?? 'Good'),
                ),
              ])),
            ]),
            const SizedBox(height: 16),

            // Location
            _fieldLabel('Physical Location', required: true),
            const SizedBox(height: 6),
            TextField(
              controller: _locationCtrl,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: _inputDeco('e.g., Section A, Shelf 3, Row 2'),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
            onPressed: () => context.go('/copies'),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF374151))),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isValid ? () async {
              try {
                await ApiService.createCopy({
                  'isbn': _selectedIsbn!,
                  'location': _locationCtrl.text.trim(),
                  'condition': _condition,
                  'notes': 'Status: $_status',
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copia creada exitosamente')));
                  context.go('/copies');
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
            child: const Text('Save Copy', style: TextStyle(fontWeight: FontWeight.w600)),
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
        borderSide: const BorderSide(color: Color(0xFF0E7334), width: 2)),
  );
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, isExpanded: true, onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      ),
    ),
  );
}
