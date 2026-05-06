import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/api_service.dart';
import '../../core/models/models.dart';

class ActiveLoansPage extends StatefulWidget {
  const ActiveLoansPage({super.key});
  @override
  State<ActiveLoansPage> createState() => _ActiveLoansPageState();
}

class _ActiveLoansPageState extends State<ActiveLoansPage> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'Todos';
  String _sortOrder = 'asc';
  static const _green = Color(0xFF0E7334);

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Loan> _loans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    try {
      final loans = await ApiService.getLoans();
      if (mounted) setState(() { _loans = loans; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Loan> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    var list = _loans.where((l) {
      final ms = q.isEmpty ||
          l.id.toLowerCase().contains(q) ||
          l.userId.toLowerCase().contains(q) ||
          l.userName.toLowerCase().contains(q) ||
          l.bookTitle.toLowerCase().contains(q) ||
          l.copyId.toLowerCase().contains(q);
      final mf = _statusFilter == 'Todos' || l.status.label == _statusFilter;
      return ms && mf;
    }).toList();
    list.sort((a, b) => _sortOrder == 'asc'
        ? a.dueDate.compareTo(b.dueDate)
        : b.dueDate.compareTo(a.dueDate));
    return list;
  }

  String _fmtDate(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _green));
    final filtered = _filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Prestamos Activos', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Gestiona todos los prestamos de la biblioteca',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),

        // Filters
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Buscar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ID, Usuario, Libro...',
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
                  prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF9CA3AF)),
                  filled: true, fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _green, width: 2)),
                ),
              ),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Estado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              _Dropdown(value: _statusFilter,
                  items: ['Todos', 'Activo', 'Atrasado', 'Devuelto'],
                  onChanged: (v) => setState(() => _statusFilter = v ?? 'Todos')),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ordenar por vencimiento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              _Dropdown(value: _sortOrder,
                  items: ['asc', 'desc'],
                  labels: {'asc': 'Mas proximos primero', 'desc': 'Mas lejanos primero'},
                  onChanged: (v) => setState(() => _sortOrder = v ?? 'asc')),
            ])),
          ]),
        ),
        const SizedBox(height: 16),

        Text('Mostrando ${filtered.length} de ${_loans.length} prestamos',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 12),

        // Table
        Container(
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: const Row(children: [
                Expanded(flex: 2, child: _TH('ID PRESTAMO')),
                Expanded(flex: 2, child: _TH('ID USUARIO')),
                Expanded(flex: 3, child: _TH('NOMBRE USUARIO')),
                Expanded(flex: 3, child: _TH('TITULO DEL LIBRO')),
                Expanded(flex: 2, child: _TH('ID COPIA')),
                Expanded(flex: 2, child: _TH('FECHA PRESTAMO')),
                Expanded(flex: 2, child: _TH('FECHA VENCIMIENTO')),
                Expanded(flex: 2, child: _TH('ESTADO')),
                Expanded(flex: 2, child: _TH('ACCIONES')),
              ]),
            ),
            ...filtered.map((l) => _LoanRow(loan: l, fmtDate: _fmtDate)),
            if (filtered.isEmpty)
              Padding(padding: const EdgeInsets.all(48),
                child: Column(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(LucideIcons.calendar, size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 16),
                  Text('No se encontraron prestamos',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ]),
              ),
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

class _LoanRow extends StatelessWidget {
  final Loan loan;
  final String Function(DateTime) fmtDate;
  const _LoanRow({required this.loan, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(loan.id,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)))),
        Expanded(flex: 2, child: Text(loan.userId,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)))),
        Expanded(flex: 3, child: Text(loan.userName,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)))),
        Expanded(flex: 3, child: Text(loan.bookTitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)))),
        Expanded(flex: 2, child: Text(loan.copyId,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)))),
        Expanded(flex: 2, child: Text(fmtDate(loan.loanDate),
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
        Expanded(flex: 2, child: Text(fmtDate(loan.dueDate),
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
        Expanded(flex: 2, child: _StatusBadge(loan.status)),
        Expanded(flex: 2, child: Row(children: [
          IconButton(
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            icon: const Icon(LucideIcons.eye, size: 17, color: Color(0xFF9CA3AF)),
            tooltip: 'Ver detalles',
            onPressed: () => context.go('/loans/${loan.id}'),
          ),
          if (loan.status == LoanStatus.active) ...[
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              icon: const Icon(LucideIcons.refreshCw, size: 17, color: Color(0xFF9CA3AF)),
              tooltip: 'Renovar prestamo',
              onPressed: () => context.go('/loans/${loan.id}'),
            ),
          ],
          if (loan.status == LoanStatus.active || loan.status == LoanStatus.overdue) ...[
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              icon: const Icon(LucideIcons.checkCircle, size: 17, color: Color(0xFF9CA3AF)),
              tooltip: 'Registrar devolucion',
              onPressed: () => context.go('/loans/return?loanId=${loan.id}'),
            ),
          ],
        ])),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final LoanStatus status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case LoanStatus.active:   bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669);
      case LoanStatus.overdue:  bg = const Color(0xFFFEE2E2); fg = const Color(0xFFEF4444);
      case LoanStatus.returned: bg = const Color(0xFFF3F4F6); fg = const Color(0xFF6B7280);
    }
    return Align(alignment: Alignment.centerLeft, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    ));
  }
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Map<String, String>? labels;
  final ValueChanged<String?> onChanged;
  const _Dropdown({required this.value, required this.items, this.labels, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, onChanged: onChanged, isExpanded: true,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        items: items.map((s) => DropdownMenuItem(
            value: s, child: Text(labels?[s] ?? (s == 'Todos' ? 'Todos los estados' : s)))).toList(),
      ),
    ),
  );
}
