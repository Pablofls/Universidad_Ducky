import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/mock_data.dart';
import '../../core/models/models.dart';

class BookDetailPage extends StatelessWidget {
  final String isbn;
  const BookDetailPage({super.key, required this.isbn});
  static const _green = Color(0xFF0E7334);

  @override
  Widget build(BuildContext context) {
    final book = MockData.books.firstWhere((b) => b.isbn == isbn, orElse: () => MockData.books.first);
    final copies = MockData.copies.where((c) => c.isbn == isbn).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => context.go('/'), child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          GestureDetector(onTap: () => context.go('/books'), child: const Text('Libros', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          Text(book.title, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          GestureDetector(onTap: () => context.go('/books'), child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF374151))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(book.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            Text(book.author, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          ])),
          ElevatedButton.icon(
            onPressed: () => context.go('/books/${book.isbn}/edit'),
            style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            icon: const Icon(LucideIcons.edit2, size: 16),
            label: const Text('Editar Libro', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 24),

        LayoutBuilder(builder: (ctx, c) {
          final mainW  = c.maxWidth * 0.68 - 10;
          final sideW  = c.maxWidth * 0.32 - 10;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Bibliographic info
            Container(width: mainW, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Informacion Bibliografica', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _BibField('ISBN', book.isbn)),
                  Expanded(child: _BibField('Tema', book.topic)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _BibField('Autor', book.author)),
                  Expanded(child: _BibField('Editorial', book.publisher)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _BibField('Seccion', book.section)),
                  Expanded(child: _BibField('Precio', '\$${book.price.toStringAsFixed(2)}')),
                ]),
                const SizedBox(height: 16),
                _BibField('Agregado al Catalogo', DateFormat("d 'de' MMMM 'de' y", 'es').format(DateTime(book.year))),
              ]),
            ),
            const SizedBox(width: 20),
            // Availability
            Container(width: sideW, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Disponibilidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const SizedBox(height: 20),
                _AvailRow('Ejemplares Totales', '${book.totalCopies}', const Color(0xFF111827)),
                const SizedBox(height: 16),
                _AvailRow('Disponibles', '${book.availableCopies}', _green),
                const SizedBox(height: 16),
                _AvailRow('En Prestamo', '${book.totalCopies - book.availableCopies}', const Color(0xFFF59E0B)),
              ]),
            ),
          ]);
        }),
        const SizedBox(height: 20),

        // Copies table
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(LucideIcons.mapPin, size: 16, color: Color(0xFF0E7334)),
                const SizedBox(width: 8),
                const Text('Ubicacion Fisica de Ejemplares', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              ]),
              GestureDetector(onTap: () => context.go('/copies'),
                child: Row(children: const [
                  Icon(LucideIcons.eye, size: 14, color: Color(0xFF9CA3AF)),
                  SizedBox(width: 4),
                  Text('Ver Todos los Ejemplares', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ])),
            ]),
            const SizedBox(height: 16),
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(children: const [
                Expanded(flex: 2, child: _TH('ID EJEMPLAR')),
                Expanded(flex: 2, child: _TH('ESTADO')),
                Expanded(flex: 4, child: _TH('UBICACION')),
                Expanded(flex: 2, child: _TH('CONDICION')),
              ]),
            ),
            ...copies.map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
              child: Row(children: [
                Expanded(flex: 2, child: Text(c.id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)))),
                Expanded(flex: 2, child: _CopyStatusBadge(c.status)),
                Expanded(flex: 4, child: Row(children: [
                  const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Text(c.location, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
                ])),
                Expanded(flex: 2, child: Text(c.condition, style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
              ]),
            )),
            if (copies.isEmpty)
              const Padding(padding: EdgeInsets.all(16),
                child: Text('No hay ejemplares registrados', style: TextStyle(color: Color(0xFF9CA3AF)))),
          ]),
        ),
      ]),
    );
  }
}

class _BibField extends StatelessWidget {
  final String label, value;
  const _BibField(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
  ]);
}

class _AvailRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _AvailRow(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
    const SizedBox(height: 3),
    Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: color)),
  ]);
}

class _TH extends StatelessWidget {
  final String t;
  const _TH(this.t);
  @override
  Widget build(BuildContext context) => Text(t, style: const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF), letterSpacing: .5));
}

class _CopyStatusBadge extends StatelessWidget {
  final CopyStatus status;
  const _CopyStatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case CopyStatus.available: bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669); break;
      case CopyStatus.borrowed:  bg = const Color(0xFFFEF3C7); fg = const Color(0xFFD97706); break;
      case CopyStatus.damaged:   bg = const Color(0xFFFEE2E2); fg = const Color(0xFFEF4444); break;
      case CopyStatus.lost:      bg = const Color(0xFFF3F4F6); fg = const Color(0xFF6B7280); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
