import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class CopyDetailPage extends StatefulWidget {
  final String copyId;
  const CopyDetailPage({super.key, required this.copyId});
  @override
  State<CopyDetailPage> createState() => _CopyDetailPageState();
}

class _CopyDetailPageState extends State<CopyDetailPage> {
  static const _green = Color(0xFF0E7334);
  BookCopy? _copy;
  Book? _book;
  Loan? _loan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final copy = await ApiService.getCopy(widget.copyId);
      final book = await ApiService.getBook(copy.isbn);
      final loans = await ApiService.getLoans();
      final activeLoan = loans.where((l) => l.copyId == widget.copyId && l.status != LoanStatus.returned).firstOrNull;
      if (mounted) setState(() {
        _copy = copy;
        _book = book;
        _loan = activeLoan;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _green));
    if (_copy == null) return const Center(child: Text('Ejemplar no encontrado'));
    final copy = _copy!;
    final book = _book!;
    final loan = _loan;

    Color statusBg, statusFg;
    switch (copy.status) {
      case CopyStatus.available: statusBg = const Color(0xFFD1FAE5); statusFg = const Color(0xFF059669); break;
      case CopyStatus.borrowed:  statusBg = const Color(0xFFFEF3C7); statusFg = const Color(0xFFD97706); break;
      case CopyStatus.reserved:  statusBg = const Color(0xFFDBEAFE); statusFg = const Color(0xFF2563EB); break;
      case CopyStatus.internal:  statusBg = const Color(0xFFE0E7FF); statusFg = const Color(0xFF4338CA); break;
      default:                   statusBg = const Color(0xFFFEE2E2); statusFg = const Color(0xFFEF4444);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Breadcrumb
        Row(children: [
          GestureDetector(onTap: () => context.go('/'),
              child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          GestureDetector(onTap: () => context.go('/copies'),
              child: const Text('Ejemplares', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          Text(copy.id, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),

        // Header
        Row(children: [
          GestureDetector(onTap: () => context.go('/copies'),
              child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF374151))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ejemplar ${copy.id}', style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            Text(copy.bookTitle, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Text(copy.status.label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: statusFg)),
          ),
        ]),
        const SizedBox(height: 24),

        LayoutBuilder(builder: (ctx, c) {
          final half = (c.maxWidth - 20) / 2;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Copy info
            _Card(width: half, title: 'Informacion del Ejemplar', child: Column(children: [
              const SizedBox(height: 8),
              _InfoRow(LucideIcons.hash,       'ID Ejemplar',    copy.id),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _InfoRow(LucideIcons.book,       'Libro',          copy.bookTitle),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _InfoRow(LucideIcons.hash,    'ISBN',           copy.isbn),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _InfoRow(LucideIcons.mapPin,     'Ubicacion',      copy.location),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _InfoRow(LucideIcons.star,       'Condicion',      copy.condition),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _InfoRow(LucideIcons.calendar,   'Fecha de Adquisicion',
                  '${copy.acquisitionDate.day}/${copy.acquisitionDate.month}/${copy.acquisitionDate.year}'),
              if (copy.notes != null) ...[
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _InfoRow(LucideIcons.fileText, 'Notas', copy.notes!),
              ],
            ])),
            const SizedBox(width: 20),
            // Loan info / Book info
            Column(children: [
              if (loan != null)
                _Card(width: half, title: 'Prestamo Activo', child: Column(children: [
                  const SizedBox(height: 8),
                  _InfoRow(LucideIcons.user,     'Usuario',        loan.userName),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _InfoRow(LucideIcons.calendar, 'Fecha Prestamo',
                      '${loan.loanDate.day}/${loan.loanDate.month}/${loan.loanDate.year}'),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _InfoRow(LucideIcons.calendarX, 'Fecha Vencimiento',
                      '${loan.dueDate.day}/${loan.dueDate.month}/${loan.dueDate.year}'),
                ]))
              else
                _Card(width: half, title: 'Informacion del Libro', child: Column(children: [
                  const SizedBox(height: 8),
                  _InfoRow(LucideIcons.user,      'Autor',      book.author),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _InfoRow(LucideIcons.building2, 'Editorial',  book.publisher),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _InfoRow(LucideIcons.tag,       'Tema',       book.topic),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Disponibles', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      Text('${book.availableCopies}', style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700, color: _green)),
                    ])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      Text('${book.totalCopies}', style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                    ])),
                  ]),
                ])),
            ]),
          ]);
        }),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final double width;
  final String title;
  final Widget child;
  const _Card({required this.width, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      child,
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 15, color: const Color(0xFF9CA3AF)),
    const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
    ]),
  ]);
}