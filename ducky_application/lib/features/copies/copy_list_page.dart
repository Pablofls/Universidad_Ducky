import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/router.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class CopyListPage extends StatefulWidget {
  const CopyListPage({super.key});
  @override
  State<CopyListPage> createState() => _CopyListPageState();
}

class _CopyListPageState extends State<CopyListPage> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'Todos';
  List<BookCopy> _copies = [];
  static const _green = Color(0xFF0E7334);

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCopies();
  }

  Future<void> _loadCopies() async {
    try {
      final copies = await ApiService.getCopies();
      if (mounted) setState(() { _copies = copies; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<BookCopy> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return _copies.where((c) {
      final ms = q.isEmpty ||
          c.id.toLowerCase().contains(q) ||
          c.bookTitle.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q);
      final mf = _statusFilter == 'Todos' || c.status.label == _statusFilter;
      return ms && mf;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _green));
    final filtered = _filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Breadcrumb
        Row(children: [
          GestureDetector(onTap: () => context.go('/'),
              child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          const Text('Ejemplares', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),

        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Gestion de Ejemplares', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const Text('Administrar copias fisicas de libros e inventario',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ])),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.copyCreate),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Agregar Ejemplar', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 20),

        // Search + filter
        Row(children: [
          Expanded(child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar por ID de ejemplar, titulo de libro o ubicacion...',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
              prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF9CA3AF)),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _green, width: 2)),
            ),
          )),
          const SizedBox(width: 12),
          const Icon(LucideIcons.filter, size: 18, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          _StatusDropdown(
            value: _statusFilter,
            onChanged: (v) => setState(() => _statusFilter = v ?? 'Todos'),
          ),
        ]),
        const SizedBox(height: 16),

        // Table
        Container(
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(children: const [
                Expanded(flex: 2, child: _TH('ID EJEMPLAR')),
                Expanded(flex: 4, child: _TH('TITULO DEL LIBRO')),
                Expanded(flex: 2, child: _TH('ESTADO')),
                Expanded(flex: 4, child: _TH('UBICACION')),
                Expanded(flex: 2, child: _TH('CONDICION')),
                Expanded(flex: 1, child: _TH('ACCIONES')),
              ]),
            ),
            // Rows
            ...filtered.map((c) => _CopyRow(
              copy: c,
              onView: () => context.go('/copies/${c.id}'),
            )),
            if (filtered.isEmpty)
              const Padding(padding: EdgeInsets.all(32),
                  child: Center(child: Text('No se encontraron ejemplares',
                      style: TextStyle(color: Color(0xFF9CA3AF))))),
          ]),
        ),
      ]),
    );
  }
}

class _TH extends StatelessWidget {
  final String t;
  const _TH(this.t);
  @override
  Widget build(BuildContext context) => Text(t, style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: Color(0xFF9CA3AF), letterSpacing: 0.5));
}

class _CopyRow extends StatelessWidget {
  final BookCopy copy;
  final VoidCallback onView;
  const _CopyRow({required this.copy, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(copy.id,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)))),
        Expanded(flex: 4, child: Text(copy.bookTitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: _StatusBadge(copy.status)),
        Expanded(flex: 4, child: Row(children: [
          const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 4),
          Expanded(child: Text(copy.location,
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        ])),
        Expanded(flex: 2, child: Text(copy.condition,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 1, child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(LucideIcons.eye, size: 17, color: Color(0xFF9CA3AF)),
          onPressed: onView,
        )),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CopyStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case CopyStatus.available: bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669); break;
      case CopyStatus.borrowed:  bg = const Color(0xFFFEF3C7); fg = const Color(0xFFD97706); break;
      case CopyStatus.reserved:  bg = const Color(0xFFDBEAFE); fg = const Color(0xFF2563EB); break;
      case CopyStatus.internal:  bg = const Color(0xFFE0E7FF); fg = const Color(0xFF4338CA); break;
      case CopyStatus.damaged:   bg = const Color(0xFFFEE2E2); fg = const Color(0xFFEF4444); break;
      case CopyStatus.lost:      bg = const Color(0xFFF3F4F6); fg = const Color(0xFF6B7280); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        items: ['Todos', 'Disponible', 'Prestado', 'Reservado', 'Uso Interno', 'Danado', 'Perdido']
            .map((s) => DropdownMenuItem(
                value: s, child: Text(s == 'Todos' ? 'Todos los Estados' : s)))
            .toList(),
      ),
    ),
  );
}
