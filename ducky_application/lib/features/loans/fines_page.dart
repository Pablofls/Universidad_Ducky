import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/mock_data.dart';
import '../../core/models/models.dart';

class FinesPage extends StatefulWidget {
  const FinesPage({super.key});
  @override
  State<FinesPage> createState() => _FinesPageState();
}

class _FinesPageState extends State<FinesPage> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'Todos';
  static const _green = Color(0xFF0E7334);

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Fine> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return MockData.fines.where((f) {
      final ms = q.isEmpty ||
          f.id.toLowerCase().contains(q) ||
          f.userId.toLowerCase().contains(q) ||
          f.userName.toLowerCase().contains(q) ||
          f.bookTitle.toLowerCase().contains(q);
      final mf = _statusFilter == 'Todos' || f.status.label == _statusFilter;
      return ms && mf;
    }).toList();
  }

  String _fmtDate(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final totalPending = MockData.fines.where((f) => f.status == FineStatus.pending).fold<double>(0, (s, f) => s + f.amount);
    final totalPaid = MockData.fines.where((f) => f.status == FineStatus.paid).fold<double>(0, (s, f) => s + f.amount);
    final pendingCount = MockData.fines.where((f) => f.status == FineStatus.pending).length;
    final paidCount = MockData.fines.where((f) => f.status == FineStatus.paid).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Gestion de Multas', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Administra las multas por devoluciones tardias',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),

        // Stats
        Row(children: [
          Expanded(child: _StatCard(
            label: 'Multas Pendientes',
            value: '\$${totalPending.toStringAsFixed(0)}',
            subtitle: '$pendingCount multas',
            icon: LucideIcons.dollarSign,
            iconColor: const Color(0xFFF59E0B),
          )),
          const SizedBox(width: 24),
          Expanded(child: _StatCard(
            label: 'Multas Pagadas',
            value: '\$${totalPaid.toStringAsFixed(0)}',
            subtitle: '$paidCount multas',
            icon: LucideIcons.checkCircle,
            iconColor: const Color(0xFF22C55E),
          )),
          const SizedBox(width: 24),
          Expanded(child: _StatCard(
            label: 'Total Recaudado',
            value: '\$${totalPaid.toStringAsFixed(0)}',
            subtitle: 'Este mes',
            icon: LucideIcons.dollarSign,
            iconColor: _green,
          )),
        ]),
        const SizedBox(height: 24),

        // Search + filter
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
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter, isExpanded: true,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                    onChanged: (v) => setState(() => _statusFilter = v ?? 'Todos'),
                    items: ['Todos', 'Pendiente', 'Pagado'].map((s) => DropdownMenuItem(
                        value: s, child: Text(s == 'Todos' ? 'Todos los estados' : s))).toList(),
                  ),
                ),
              ),
            ])),
          ]),
        ),
        const SizedBox(height: 16),

        Text('Mostrando ${filtered.length} de ${MockData.fines.length} multas',
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
                Expanded(flex: 2, child: _TH('ID MULTA')),
                Expanded(flex: 3, child: _TH('USUARIO')),
                Expanded(flex: 3, child: _TH('LIBRO')),
                Expanded(flex: 2, child: _TH('DIAS DE RETRASO')),
                Expanded(flex: 2, child: _TH('MONTO')),
                Expanded(flex: 2, child: _TH('FECHA CREACION')),
                Expanded(flex: 2, child: _TH('ESTADO')),
                Expanded(flex: 2, child: _TH('ACCIONES')),
              ]),
            ),
            ...filtered.map((f) => _FineRow(fine: f, fmtDate: _fmtDate,
              onViewLoan: () => context.go('/loans/${f.loanId}'),
              onMarkPaid: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Multa ${f.id} marcada como pagada')));
              },
            )),
            if (filtered.isEmpty)
              Padding(padding: const EdgeInsets.all(48),
                child: Column(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(LucideIcons.dollarSign, size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 16),
                  Text('No se encontraron multas',
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

class _StatCard extends StatelessWidget {
  final String label, value, subtitle;
  final IconData icon;
  final Color iconColor;
  const _StatCard({required this.label, required this.value, required this.subtitle,
      required this.icon, required this.iconColor});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Icon(icon, size: 20, color: iconColor),
      ]),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
    ]),
  );
}

class _FineRow extends StatelessWidget {
  final Fine fine;
  final String Function(DateTime) fmtDate;
  final VoidCallback onViewLoan, onMarkPaid;
  const _FineRow({required this.fine, required this.fmtDate, required this.onViewLoan, required this.onMarkPaid});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
    child: Row(children: [
      Expanded(flex: 2, child: Text(fine.id,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)))),
      Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(fine.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
        Text(fine.userId, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      ])),
      Expanded(flex: 3, child: Text(fine.bookTitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF111827)))),
      Expanded(flex: 2, child: Text('${fine.daysOverdue} dias',
          style: const TextStyle(fontSize: 13, color: Color(0xFF111827)))),
      Expanded(flex: 2, child: Text('\$${fine.amount.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)))),
      Expanded(flex: 2, child: Text(fmtDate(fine.createdAt),
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
      Expanded(flex: 2, child: _FineStatusBadge(fine.status)),
      Expanded(flex: 2, child: Row(children: [
        IconButton(
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          icon: const Icon(LucideIcons.eye, size: 17, color: Color(0xFF9CA3AF)),
          tooltip: 'Ver prestamo relacionado',
          onPressed: onViewLoan,
        ),
        if (fine.status == FineStatus.pending) ...[
          const SizedBox(width: 4),
          IconButton(
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            icon: const Icon(LucideIcons.checkCircle, size: 17, color: Color(0xFF22C55E)),
            tooltip: 'Marcar como pagado',
            onPressed: onMarkPaid,
          ),
        ],
      ])),
    ]),
  );
}

class _FineStatusBadge extends StatelessWidget {
  final FineStatus status;
  const _FineStatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final isPending = status == FineStatus.pending;
    return Align(alignment: Alignment.centerLeft, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
              color: isPending ? const Color(0xFFD97706) : const Color(0xFF059669))),
    ));
  }
}
