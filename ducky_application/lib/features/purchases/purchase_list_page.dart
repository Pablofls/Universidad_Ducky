import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/router.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});
  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'Todos';
  static const _green = Color(0xFF0E7334);

  List<PurchaseRequest> _purchases = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _loadPurchases() async {
    try {
      final list = await ApiService.getPurchases();
      if (mounted) setState(() { _purchases = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PurchaseRequest> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return _purchases.where((p) {
      final ms = q.isEmpty ||
          p.bookTitle.toLowerCase().contains(q) ||
          p.author.toLowerCase().contains(q) ||
          p.requestedBy.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q);
      final mf = _statusFilter == 'Todos' || p.status.label == _statusFilter;
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
          const Text('Solicitudes de Compra',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),

        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Solicitudes de Compra', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            const Text('Gestionar solicitudes de compra de ejemplares',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ])),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.purchaseCreate),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Nueva Solicitud', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 20),

        // Search + filter
        Row(children: [
          Expanded(child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar por titulo, autor, solicitante o ID...',
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
          _StatusDropdown(value: _statusFilter,
              onChanged: (v) => setState(() => _statusFilter = v ?? 'Todos')),
        ]),
        const SizedBox(height: 16),

        // Table
        Container(
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(children: [
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(children: const [
                Expanded(flex: 1, child: _TH('ID')),
                Expanded(flex: 3, child: _TH('TITULO DEL LIBRO')),
                Expanded(flex: 2, child: _TH('AUTOR')),
                Expanded(flex: 1, child: _TH('CANTIDAD')),
                Expanded(flex: 2, child: _TH('PRECIO UNIT.')),
                Expanded(flex: 2, child: _TH('TOTAL')),
                Expanded(flex: 2, child: _TH('SOLICITANTE')),
                Expanded(flex: 2, child: _TH('ESTADO')),
                Expanded(flex: 2, child: _TH('FECHA')),
                Expanded(flex: 1, child: _TH('ACCIONES')),
              ]),
            ),
            ...filtered.map((p) => _PurchaseRow(
              purchase: p,
              onView: () => context.go('/purchases/${p.id}'),
            )),
            if (filtered.isEmpty)
              const Padding(padding: EdgeInsets.all(32),
                  child: Center(child: Text('No se encontraron solicitudes',
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

class _PurchaseRow extends StatelessWidget {
  final PurchaseRequest purchase;
  final VoidCallback onView;
  const _PurchaseRow({required this.purchase, required this.onView});

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(children: [
        Expanded(flex: 1, child: Text(purchase.id,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)))),
        Expanded(flex: 3, child: Text(purchase.bookTitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: Text(purchase.author,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 1, child: Text('${purchase.quantity}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: Text('\$${purchase.unitPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: Text('\$${purchase.total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
        Expanded(flex: 2, child: Text(purchase.requestedBy,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 2, child: _StatusBadge(purchase.status)),
        Expanded(flex: 2, child: Text(_fmtDate(purchase.createdAt),
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(flex: 1, child: IconButton(
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          icon: const Icon(LucideIcons.eye, size: 17, color: Color(0xFF9CA3AF)),
          onPressed: onView,
        )),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PurchaseStatus status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case PurchaseStatus.pending:   bg = const Color(0xFFFEF3C7); fg = const Color(0xFFD97706); break;
      case PurchaseStatus.approved:  bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669); break;
      case PurchaseStatus.rejected:  bg = const Color(0xFFFEE2E2); fg = const Color(0xFFEF4444); break;
      case PurchaseStatus.purchased: bg = const Color(0xFFDBEAFE); fg = const Color(0xFF2563EB); break;
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
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB))),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
        items: ['Todos', 'Pendiente', 'Aprobado', 'Rechazado', 'Comprado']
            .map((s) => DropdownMenuItem(
                value: s, child: Text(s == 'Todos' ? 'Todos los Estados' : s)))
            .toList(),
      ),
    ),
  );
}
