import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class PurchaseDetailPage extends StatefulWidget {
  final String id;
  const PurchaseDetailPage({super.key, required this.id});
  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  static const _green = Color(0xFF0E7334);
  PurchaseRequest? _purchase;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final p = await ApiService.getPurchase(widget.id);
      if (mounted) setState(() { _purchase = p; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _green));
    if (_purchase == null) return const Center(child: Text('Solicitud no encontrada'));
    final p = _purchase!;

    Color statusBg, statusFg;
    switch (p.status) {
      case PurchaseStatus.pending:   statusBg = const Color(0xFFFEF3C7); statusFg = const Color(0xFFD97706); break;
      case PurchaseStatus.approved:  statusBg = const Color(0xFFD1FAE5); statusFg = const Color(0xFF059669); break;
      case PurchaseStatus.rejected:  statusBg = const Color(0xFFFEE2E2); statusFg = const Color(0xFFEF4444); break;
      case PurchaseStatus.purchased: statusBg = const Color(0xFFDBEAFE); statusFg = const Color(0xFF2563EB); break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => context.go('/'),
              child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          GestureDetector(onTap: () => context.go('/purchases'),
              child: const Text('Solicitudes de Compra',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          Text(p.id, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          GestureDetector(onTap: () => context.go('/purchases'),
              child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF374151))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Solicitud ${p.id}', style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            Text(_fmtDate(p.createdAt),
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Text(p.status.label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: statusFg)),
          ),
        ]),
        const SizedBox(height: 24),

        LayoutBuilder(builder: (ctx, c) {
          final mainW = c.maxWidth * 0.65 - 10;
          final sideW = c.maxWidth * 0.35 - 10;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Book info
            _Card(width: mainW, title: 'Informacion del Libro', child: Column(children: [
              const SizedBox(height: 12),
              _Row2('Titulo',    p.bookTitle,  'Autor',     p.author),
              const SizedBox(height: 16),
              _Row2('ISBN',      p.isbn,       'Solicitante', p.requestedBy),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF3F4F6)),
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerLeft,
                  child: Text('Justificacion', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)))),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft,
                  child: Text(p.justification,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
              if (p.reviewNotes != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6)),
                const SizedBox(height: 12),
                const Align(alignment: Alignment.centerLeft,
                    child: Text('Notas de Revision',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)))),
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerLeft,
                    child: Text(p.reviewNotes!,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
                if (p.reviewedBy != null) ...[
                  const SizedBox(height: 4),
                  Align(alignment: Alignment.centerLeft,
                      child: Text('Revisado por: ${p.reviewedBy}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)))),
                ],
              ],
            ])),
            const SizedBox(width: 20),
            // Summary
            _Card(width: sideW, title: 'Resumen de Compra', child: Column(children: [
              const SizedBox(height: 12),
              _SummaryRow('Cantidad', '${p.quantity} ejemplares'),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _SummaryRow('Precio Unitario', '\$${p.unitPrice.toStringAsFixed(2)}'),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                Text('\$${p.total.toStringAsFixed(2)}', style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: _green)),
              ]),
              const Divider(height: 24, color: Color(0xFFF3F4F6)),
              _SummaryRow('Fecha Solicitud', _fmtDate(p.createdAt)),
            ])),
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
      Text(title, style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      child,
    ]),
  );
}

class _Row2 extends StatelessWidget {
  final String l1, v1, l2, v2;
  const _Row2(this.l1, this.v1, this.l2, this.v2);
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l1, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      const SizedBox(height: 3),
      Text(v1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
    ])),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l2, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      const SizedBox(height: 3),
      Text(v2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
    ])),
  ]);
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      Text(value,  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
    ],
  );
}
