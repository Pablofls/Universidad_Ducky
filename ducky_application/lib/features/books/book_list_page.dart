import 'package:flutter/material.dart';
import '../../../shared/utils/export_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/router.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});
  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final _searchCtrl = TextEditingController();
  String _topicFilter = 'Todos';
  bool _gridView = true;
  List<Book> _books = [];
  static const _green = Color(0xFF0E7334);

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await ApiService.getBooks();
      if (mounted) setState(() { _books = books; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Book> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return _books.where((b) {
      final ms = q.isEmpty ||
          b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.isbn.toLowerCase().contains(q) ||
          b.publisher.toLowerCase().contains(q);
      final mt = _topicFilter == 'Todos' || b.topic == _topicFilter;
      return ms && mt;
    }).toList();
  }

  List<String> get _topics =>
      ['Todos', ...{..._books.map((b) => b.topic)}];

  void _deleteBook(Book book) {
    showDialog<void>(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Eliminar Libro',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      content: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(18)),
          child: const Icon(LucideIcons.alertTriangle, size: 18, color: Color(0xFFEF4444))),
        const SizedBox(width: 12),
        Expanded(child: Text(
          '¿Esta seguro de que desea eliminar "${book.title}"? Esta accion no se puede deshacer.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF374151)))),
        ElevatedButton(
          onPressed: () async {
            try {
              await ApiService.deleteBook(book.isbn);
              setState(() => _books.removeWhere((b) => b.isbn == book.isbn));
            } catch (_) {}
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Eliminar'),
        ),
      ],
    ));
  }

  void _exportToPrint() {
    final filtered = _filtered;
    final now = DateTime.now();
    final months = ['','enero','febrero','marzo','abril','mayo','junio',
        'julio','agosto','septiembre','octubre','noviembre','diciembre'];
    final dateStr = '${now.day} de ${months[now.month]} de ${now.year}';
    final totalCopies = filtered.fold(0, (s, b) => s + b.totalCopies);
    final totalAvail  = filtered.fold(0, (s, b) => s + b.availableCopies);

    final rows = filtered.map((b) {
      final color = b.availableCopies == 0
          ? '#EF4444' : b.availableCopies <= 2 ? '#F59E0B' : '#0E7334';
      return '<tr>'
          '<td style="font-weight:600;color:#0E7334">${b.isbn}</td>'
          '<td>${b.title}</td>'
          '<td>${b.author}</td>'
          '<td>${b.topic}</td>'
          '<td>${b.section}</td>'
          '<td>${b.publisher}</td>'
          '<td>\$${b.price.toStringAsFixed(2)}</td>'
          '<td style="color:$color;font-weight:700">${b.availableCopies}</td>'
          '<td>${b.totalCopies}</td>'
          '</tr>';
    }).join('');

    final html = '''<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<style>
  body{font-family:Arial,sans-serif;margin:32px;color:#111}
  h1{text-align:center;color:#0E7334;font-size:22px;margin:0}
  .sub{text-align:center;color:#555;font-size:13px;margin:4px 0 2px}
  .date{text-align:center;color:#888;font-size:11px;margin-bottom:20px}
  hr{border:2px solid #0E7334;margin:12px 0 16px}
  .summary{font-size:13px;margin-bottom:12px}
  table{width:100%;border-collapse:collapse;font-size:11px}
  th{background:#0E7334;color:white;padding:7px 6px;text-align:left;font-size:10px;letter-spacing:.4px}
  td{padding:6px;border-bottom:1px solid #eee}
  .footer{text-align:center;font-size:10px;color:#aaa;margin-top:24px}
</style></head>
<body>
<h1>Universidad Ducky</h1>
<div class="sub">Catálogo de Libros - Sistema de Gestión de Biblioteca</div>
<div class="date">Generado el $dateStr</div>
<hr/>
<div class="summary"><b>Total de libros:</b> ${filtered.length} | <b>Ejemplares totales:</b> $totalCopies | <b>Disponibles:</b> $totalAvail</div>
<table>
<tr><th>ISBN</th><th>TÍTULO</th><th>AUTOR</th><th>TEMA</th><th>SECCIÓN</th><th>EDITORIAL</th><th>PRECIO</th><th>DISP.</th><th>TOTAL</th></tr>
$rows
</table>
<div class="footer">Este documento fue generado automáticamente por el Sistema de Gestión de Biblioteca de la Universidad Ducky.</div>
</body></html>''';

    exportHtml(html, 'catalogo_libros.html');
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
          GestureDetector(onTap: () => context.go('/'),
              child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          const Text('Libros', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),

        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Catalogo de Libros', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const Text('Administrar coleccion de libros de la biblioteca',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ])),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.bookCreate),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Agregar Libro', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 20),

        // Search + filter + export
        Row(children: [
          Expanded(child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: _searchDeco('Buscar por titulo, autor, ISBN o editorial...'),
          )),
          const SizedBox(width: 12),
          const Icon(LucideIcons.filter, size: 18, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          _TopicDropdown(value: _topicFilter, topics: _topics,
              onChanged: (v) => setState(() => _topicFilter = v ?? 'Todos')),
          const SizedBox(width: 12),
          // Export button
          OutlinedButton.icon(
            onPressed: _exportToPrint,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF374151),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(LucideIcons.printer, size: 16),
            label: const Text('Exportar', style: TextStyle(fontSize: 14)),
          ),
        ]),
        const SizedBox(height: 12),

        // View toggle
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Text('Vista:', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(width: 8),
          _ViewToggle(grid: _gridView, onGrid: () => setState(() => _gridView = true),
              onList: () => setState(() => _gridView = false)),
        ]),
        const SizedBox(height: 16),

        // Content
        _gridView ? _GridView(books: filtered, onDelete: _deleteBook) : _ListView(books: filtered, onDelete: _deleteBook),
      ]),
    );
  }

  InputDecoration _searchDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
    prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF9CA3AF)),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0E7334), width: 2)),
  );
}

// ── Grid view ──────────────────────────────────────────────────────────────────
class _GridView extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onDelete;
  const _GridView({required this.books, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final cols = c.maxWidth > 1100 ? 3 : c.maxWidth > 700 ? 2 : 1;
      final w = (c.maxWidth - 20.0 * (cols - 1)) / cols;
      return Wrap(spacing: 20, runSpacing: 20,
        children: books.map((b) => _BookCard(book: b, width: w, onDelete: onDelete)).toList(),
      );
    });
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final double width;
  final void Function(Book) onDelete;
  const _BookCard({required this.book, required this.width, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFF0E7334),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(LucideIcons.book, size: 22, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(book.title, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            Text(book.author, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ])),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _BookMeta('ISBN:', book.isbn)),
          Expanded(child: _BookMeta('Tema:', book.topic)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _BookMeta('Editorial:', book.publisher)),
          Expanded(child: _BookMeta('Ejemplares:', '${book.availableCopies}/${book.totalCopies}')),
        ]),
        const Divider(height: 24, color: Color(0xFFF3F4F6)),
        Row(children: [
          _ActionBtn(icon: LucideIcons.eye,        label: 'Ver',    onTap: () => context.go('/books/${Uri.encodeComponent(book.isbn)}')),
          const SizedBox(width: 4),
          _ActionBtn(icon: LucideIcons.edit2,      label: 'Editar', onTap: () => context.go('/books/${Uri.encodeComponent(book.isbn)}/edit')),
          const Spacer(),
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            icon: const Icon(LucideIcons.shoppingCart, size: 17, color: Color(0xFF9CA3AF)), onPressed: () {}),
          const SizedBox(width: 12),
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            icon: const Icon(LucideIcons.trash2, size: 17, color: Color(0xFFEF4444)), onPressed: () => onDelete(book)),
        ]),
      ]),
    );
  }
}

class _BookMeta extends StatelessWidget {
  final String label, value;
  const _BookMeta(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    Text(value,  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
  ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(children: [
        Icon(icon, size: 15, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
      ])),
  );
}

// ── List view ──────────────────────────────────────────────────────────────────
class _ListView extends StatelessWidget {
  final List<Book> books;
  final void Function(Book) onDelete;
  const _ListView({required this.books, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
          child: Row(children: const [
            Expanded(flex: 2, child: _CH('ISBN')),
            Expanded(flex: 3, child: _CH('TITULO')),
            Expanded(flex: 2, child: _CH('AUTOR')),
            Expanded(flex: 2, child: _CH('TEMA')),
            Expanded(flex: 2, child: _CH('SECCION')),
            Expanded(flex: 1, child: _CH('PRECIO')),
            Expanded(flex: 1, child: _CH('DISPONIBLES')),
            Expanded(flex: 1, child: _CH('TOTAL')),
            Expanded(flex: 2, child: _CH('ACCIONES')),
          ]),
        ),
        ...books.map((b) => _ListRow(book: b, onDelete: onDelete)),
        if (books.isEmpty) const Padding(padding: EdgeInsets.all(32),
            child: Center(child: Text('No se encontraron libros',
                style: TextStyle(color: Color(0xFF9CA3AF))))),
      ]),
    );
  }
}

class _CH extends StatelessWidget {
  final String t;
  const _CH(this.t);
  @override
  Widget build(BuildContext context) => Text(t, style: const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: .5));
}

class _ListRow extends StatelessWidget {
  final Book book;
  final void Function(Book) onDelete;
  const _ListRow({required this.book, required this.onDelete});

  Color get _availColor {
    if (book.availableCopies == 0) return const Color(0xFFEF4444);
    if (book.availableCopies <= 2) return const Color(0xFFF59E0B);
    return const Color(0xFF0E7334);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(book.isbn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827)))),
        Expanded(flex: 3, child: Text(book.title, style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: Text(book.author, style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: Text(book.topic, style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: Text(book.section, style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
        Expanded(flex: 1, child: Text('\$${book.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
        Expanded(flex: 1, child: Text('${book.availableCopies}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _availColor))),
        Expanded(flex: 1, child: Text('${book.totalCopies}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: Row(children: [
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              icon: const Icon(LucideIcons.eye, size: 16, color: Color(0xFF9CA3AF)),
              onPressed: () => context.go('/books/${Uri.encodeComponent(book.isbn)}')),
          const SizedBox(width: 10),
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              icon: const Icon(LucideIcons.edit2, size: 16, color: Color(0xFF9CA3AF)),
              onPressed: () => context.go('/books/${Uri.encodeComponent(book.isbn)}/edit')),
          const SizedBox(width: 10),
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              icon: const Icon(LucideIcons.shoppingCart, size: 16, color: Color(0xFF9CA3AF)),
              onPressed: () {}),
          const SizedBox(width: 10),
          IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFF9CA3AF)),
              onPressed: () => onDelete(book)),
        ])),
      ]),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
class _TopicDropdown extends StatelessWidget {
  final String value;
  final List<String> topics;
  final ValueChanged<String?> onChanged;
  const _TopicDropdown({required this.value, required this.topics, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB))),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value, onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
      items: topics.map((t) => DropdownMenuItem(value: t,
          child: Text(t == 'Todos' ? 'Todos los Temas' : t))).toList(),
    )),
  );
}

class _ViewToggle extends StatelessWidget {
  final bool grid;
  final VoidCallback onGrid, onList;
  const _ViewToggle({required this.grid, required this.onGrid, required this.onList});
  @override
  Widget build(BuildContext context) => Row(children: [
    _ToggleBtn(icon: LucideIcons.layoutGrid, active: grid, onTap: onGrid),
    const SizedBox(width: 4),
    _ToggleBtn(icon: LucideIcons.list, active: !grid, onTap: onList),
  ]);
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0E7334) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: active ? const Color(0xFF0E7334) : const Color(0xFFE5E7EB)),
      ),
      child: Icon(icon, size: 18, color: active ? Colors.white : const Color(0xFF6B7280)),
    ),
  );
}
