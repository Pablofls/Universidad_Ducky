import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/mock_data.dart';
import '../../core/models/models.dart';

class StudentSearchMobilePage extends StatefulWidget {
  const StudentSearchMobilePage({super.key});
  @override
  State<StudentSearchMobilePage> createState() => _StudentSearchMobilePageState();
}

class _StudentSearchMobilePageState extends State<StudentSearchMobilePage> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;
  String _topicFilter = 'Todos';
  Book? _selectedBook;
  static const _green = Color(0xFF0E7334);

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Book> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return MockData.books.where((b) {
      final ms = q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.isbn.toLowerCase().contains(q);
      final mt = _topicFilter == 'Todos' || b.topic == _topicFilter;
      return ms && mt;
    }).toList();
  }

  List<String> get _topics => ['Todos', ...{...MockData.books.map((b) => b.topic)}];

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(children: [
        CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Container(
            color: _green,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(LucideIcons.search, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                const Text('Búsqueda de Libros', style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 4),
              const Text('Explora nuestro catálogo de libros',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                height: 44,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Buscar libro...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    prefixIcon: Icon(LucideIcons.search, size: 16, color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                  icon: const Icon(LucideIcons.filter, size: 16),
                  label: const Text('Filtros', style: TextStyle(fontSize: 14)),
                ),
              ),
              if (_showFilters) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _topics.map((t) {
                    final active = _topicFilter == t;
                    return GestureDetector(
                      onTap: () => setState(() => _topicFilter = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: Text(t, style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: active ? _green : Colors.white,
                        )),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('${filtered.length} libros encontrados',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          )),
          SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) => _MobileBookTile(book: filtered[i],
                onTap: () => setState(() => _selectedBook = filtered[i])),
            childCount: filtered.length,
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
        if (_selectedBook != null)
          _MobileDetailModal(
            book: _selectedBook!,
            copies: MockData.copies.where((c) =>
                c.isbn == _selectedBook!.isbn && c.status == CopyStatus.available).toList(),
            onClose: () => setState(() => _selectedBook = null),
          ),
      ]),
    );
  }
}

class _MobileBookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const _MobileBookTile({required this.book, required this.onTap});
  static const _green = Color(0xFF0E7334);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Row(children: [
      Container(width: 52, height: 68,
          decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(6)),
          child: const Icon(LucideIcons.book, size: 26, color: Colors.white)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(book.title, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 2),
        Text(book.author, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 6),
        Text('${book.availableCopies} disponibles',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: book.availableCopies > 0 ? _green : const Color(0xFFEF4444))),
      ])),
      TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF374151), padding: EdgeInsets.zero),
        icon: const Icon(LucideIcons.eye, size: 15),
        label: const Text('Ver', style: TextStyle(fontSize: 13)),
      ),
    ]),
  );
}

class _MobileDetailModal extends StatelessWidget {
  final Book book;
  final List<BookCopy> copies;
  final VoidCallback onClose;
  const _MobileDetailModal({required this.book, required this.copies, required this.onClose});
  static const _green = Color(0xFF0E7334);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onClose,
    child: Container(
      color: Colors.black54,
      child: Center(child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
              child: Row(children: [
                const Text('Detalles del Libro', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const Spacer(),
                IconButton(onPressed: onClose,
                    icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF374151)),
                    padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ])),
            const Divider(height: 20, color: Color(0xFFE5E7EB)),
            Flexible(child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 60, height: 80,
                      decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(LucideIcons.book, size: 30, color: Colors.white)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(book.title, style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                    const SizedBox(height: 4),
                    Text(book.author, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ])),
                ]),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E7EB)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _Cell('ISBN', book.isbn)),
                  Expanded(child: _Cell('Tema', book.topic)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _Cell('Editorial', book.publisher)),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Disponibilidad', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 3),
                    Text('${book.availableCopies} disponibles',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: book.availableCopies > 0 ? _green : const Color(0xFFEF4444))),
                  ])),
                ]),
                if (copies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),
                  Row(children: const [
                    Icon(LucideIcons.mapPin, size: 15, color: Color(0xFF374151)),
                    SizedBox(width: 6),
                    Text('Ubicación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  ]),
                  const SizedBox(height: 10),
                  ...copies.map((c) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB))),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.location, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                        const SizedBox(height: 2),
                        Text('Código: ${c.id} • ${c.condition}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Disponible', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                      ),
                    ]),
                  )),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Este libro está disponible para préstamo. Acércate al mostrador de la biblioteca para solicitarlo.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.5)),
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white,
                        elevation: 0, padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w600)),
                  )),
              ]),
            )),
          ]),
        ),
      )),
    ),
  );
}

class _Cell extends StatelessWidget {
  final String label, value;
  const _Cell(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
  ]);
}
