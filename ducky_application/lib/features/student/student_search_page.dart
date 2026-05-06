import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class StudentSearchPage extends StatefulWidget {
  const StudentSearchPage({super.key});
  @override
  State<StudentSearchPage> createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends State<StudentSearchPage> {
  final _searchCtrl = TextEditingController();
  String _topicFilter = 'Todos';
  Book? _selectedBook;
  static const _green = Color(0xFF0E7334);

  List<Book> _allBooks = [];
  List<BookCopy> _allCopies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getBooks(),
        ApiService.getCopies(),
      ]);
      if (mounted) setState(() {
        _allBooks  = results[0] as List<Book>;
        _allCopies = results[1] as List<BookCopy>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Book> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return _allBooks.where((b) {
      final ms = q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.isbn.toLowerCase().contains(q) ||
          b.publisher.toLowerCase().contains(q) ||
          b.topic.toLowerCase().contains(q);
      final mt = _topicFilter == 'Todos' || b.topic == _topicFilter;
      return ms && mt;
    }).toList();
  }

  List<String> get _topics =>
      ['Todos', ...{..._allBooks.map((b) => b.topic)}];

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _green));
    final filtered = _filtered;
    return Stack(children: [
      SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Green header ────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: _green,
            padding: const EdgeInsets.fromLTRB(48, 40, 48, 48),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(LucideIcons.search, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text('Búsqueda de Libros', style: TextStyle(
                    color: Colors.white, fontSize: 28,
                    fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 6),
              const Text('Explora nuestro catálogo de libros disponibles en Ducky',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14)),
            ]),
          ),

          // ── Search bar + filter ─────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título, autor, ISBN, editorial o tema...',
                    hintStyle: const TextStyle(
                        color: Color(0xFFD1D5DB), fontSize: 14),
                    prefixIcon: const Icon(LucideIcons.search,
                        size: 16, color: Color(0xFF9CA3AF)),
                    filled: true, fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: _green, width: 2)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Topic dropdown
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _topicFilter,
                    onChanged: (v) => setState(() => _topicFilter = v ?? 'Todos'),
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF374151)),
                    items: _topics.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t == 'Todos' ? 'Todos los Temas' : t),
                    )).toList(),
                  ),
                ),
              ),
            ]),
          ),

          // ── Results ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 20, 48, 0),
            child: Text('${filtered.length} libros encontrados',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF6B7280))),
          ),
          const SizedBox(height: 12),

          // Book cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: filtered.map((b) => _WebBookCard(
                book: b,
                onTap: () => setState(() => _selectedBook = b),
              )).toList(),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),

      // ── Modal overlay ───────────────────────────────────────────────
      if (_selectedBook != null)
        _BookDetailModal(
          book: _selectedBook!,
          copies: _allCopies
              .where((c) =>
                  c.isbn == _selectedBook!.isbn &&
                  c.status == CopyStatus.available)
              .toList(),
          onClose: () => setState(() => _selectedBook = null),
        ),
    ]);
  }
}

// ── Web book card ──────────────────────────────────────────────────────────────
class _WebBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const _WebBookCard({required this.book, required this.onTap});

  static const _green = Color(0xFF0E7334);

  Color get _availColor {
    if (book.availableCopies == 0) return const Color(0xFFEF4444);
    if (book.availableCopies <= 2) return const Color(0xFFF59E0B);
    return _green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        // Book cover
        Container(
          width: 56, height: 72,
          decoration: BoxDecoration(
              color: _green, borderRadius: BorderRadius.circular(6)),
          child: const Icon(LucideIcons.book, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 20),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(book.title, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: Color(0xFF111827))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _MetaField('Autor:', book.author)),
            Expanded(child: _MetaField('ISBN:', book.isbn)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _MetaField('Tema:', book.topic)),
            Expanded(child: _MetaField('Editorial:', book.publisher)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Text('Disponibles: ',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            Text(
              '${book.availableCopies} de ${book.totalCopies}',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: _availColor),
            ),
          ]),
        ])),

        // Ver detalles button
        TextButton.icon(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF374151),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: const Icon(LucideIcons.eye, size: 16),
          label: const Text('Ver Detalles',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

class _MetaField extends StatelessWidget {
  final String label, value;
  const _MetaField(this.label, this.value);
  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: const TextStyle(fontSize: 13),
      children: [
        TextSpan(text: label,
            style: const TextStyle(color: Color(0xFF6B7280))),
        const TextSpan(text: '  '),
        TextSpan(text: value,
            style: const TextStyle(
                color: Color(0xFF374151), fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

// ── Book detail modal ──────────────────────────────────────────────────────────
class _BookDetailModal extends StatelessWidget {
  final Book book;
  final List<BookCopy> copies;
  final VoidCallback onClose;
  const _BookDetailModal(
      {required this.book, required this.copies, required this.onClose});

  static const _green = Color(0xFF0E7334);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black45,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 560,
              margin: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
                  child: Row(children: [
                    const Text('Detalles del Libro', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                    const Spacer(),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(LucideIcons.x, size: 20,
                          color: Color(0xFF374151)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ]),
                ),
                const Divider(height: 20, color: Color(0xFFE5E7EB)),

                Flexible(child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Book header
                    Row(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                        width: 64, height: 84,
                        decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(LucideIcons.book,
                            size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(book.title, style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: Color(0xFF111827))),
                        const SizedBox(height: 4),
                        Text(book.author, style: const TextStyle(
                            fontSize: 14, color: Color(0xFF6B7280))),
                      ])),
                    ]),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),

                    // Info grid
                    Row(children: [
                      Expanded(child: _DetailCell('ISBN', book.isbn)),
                      Expanded(child: _DetailCell('Tema', book.topic)),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _DetailCell('Editorial', book.publisher)),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Disponibilidad', style: TextStyle(
                            fontSize: 12, color: Color(0xFF9CA3AF))),
                        const SizedBox(height: 3),
                        Text('${book.availableCopies} disponibles',
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: book.availableCopies > 0
                                ? _green : const Color(0xFFEF4444),
                          )),
                      ])),
                    ]),

                    if (copies.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),
                      Row(children: const [
                        Icon(LucideIcons.mapPin, size: 16,
                            color: Color(0xFF374151)),
                        SizedBox(width: 8),
                        Text('Ubicación de Copias Disponibles',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: Color(0xFF111827))),
                      ]),
                      const SizedBox(height: 12),
                      ...copies.map((c) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFE5E7EB))),
                        child: Row(children: [
                          Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(c.location, style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: Color(0xFF111827))),
                            const SizedBox(height: 2),
                            Text('Código: ${c.id} • Condición: ${c.condition}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280))),
                          ])),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('Disponible',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF059669))),
                          ),
                        ]),
                      )),
                    ],

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text(
                        'Este libro está disponible para préstamo. '
                        'Acércate al mostrador de la biblioteca para solicitarlo.',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF374151),
                            height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cerrar',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final String label, value;
  const _DetailCell(this.label, this.value);
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
            fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: Color(0xFF111827))),
      ]);
}
