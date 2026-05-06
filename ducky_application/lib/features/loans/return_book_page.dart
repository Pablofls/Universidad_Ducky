import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/api_service.dart';
import '../../core/models/models.dart';

class ReturnBookPage extends StatefulWidget {
  final String? prefilledLoanId;
  const ReturnBookPage({super.key, this.prefilledLoanId});
  @override
  State<ReturnBookPage> createState() => _ReturnBookPageState();
}

class _ReturnBookPageState extends State<ReturnBookPage> {
  static const _green = Color(0xFF0E7334);
  final _searchCtrl = TextEditingController();
  Loan? _selectedLoan;
  String _bookCondition = 'Buena';

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledLoanId != null) {
      _loading = true;
      _loadLoan(widget.prefilledLoanId!);
    }
  }

  Future<void> _loadLoan(String id) async {
    try {
      final loan = await ApiService.getLoan(id);
      if (mounted) setState(() { _selectedLoan = loan; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _handleSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() => _loading = true);
    try {
      final loans = await ApiService.getLoans();
      final loan = loans.where((l) =>
          (l.id.toLowerCase() == q.toLowerCase() ||
           l.userId.toLowerCase() == q.toLowerCase() ||
           l.copyId.toLowerCase() == q.toLowerCase()) &&
          l.status != LoanStatus.returned).firstOrNull;
      if (loan != null) {
        setState(() { _selectedLoan = loan; _loading = false; });
      } else {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se encontro un prestamo activo con esa informacion')));
        }
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  int _calculateBusinessDays(DateTime start, DateTime end) {
    int count = 0;
    var current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (current.weekday <= 5) count++;
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  int get _daysOverdue {
    if (_selectedLoan == null) return 0;
    final today = DateTime.now();
    if (!today.isAfter(_selectedLoan!.dueDate)) return 0;
    return _calculateBusinessDays(_selectedLoan!.dueDate, today);
  }

  double get _lateFine => _daysOverdue * 10.0;

  double get _damageFine {
    if (_bookCondition == 'Danada' && _selectedLoan != null) return _selectedLoan!.bookPrice;
    return 0;
  }

  double get _totalFine => _lateFine + _damageFine;

  String _fmtDateLong(DateTime d) {
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  void _showConfirmDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirmar Devolucion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Estas seguro de registrar la devolucion de este libro?',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            _InfoRow('Usuario:', _selectedLoan!.userName),
            _InfoRow('Libro:', _selectedLoan!.bookTitle),
            _InfoRow('Condicion:', _bookCondition),
            if (_daysOverdue > 0 || _damageFine > 0) ...[
              const Divider(height: 16),
              if (_daysOverdue > 0) _InfoRow('Multa por retraso:', '\$${_lateFine.toStringAsFixed(2)}'),
              if (_damageFine > 0) _InfoRow('Multa por libro danado:', '\$${_damageFine.toStringAsFixed(2)}'),
              const Divider(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total de multas:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C))),
                Text('\$${_totalFine.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF7F1D1D))),
              ]),
            ],
          ]),
        ),
      ]),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            try {
              await ApiService.returnLoan(_selectedLoan!.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Devolucion registrada exitosamente')));
                context.go('/loans');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444)));
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
          child: const Text('Confirmar'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Devolver Libro', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Registra la devolucion de un libro prestado',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),

        // Search
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Buscar Prestamo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(
                controller: _searchCtrl,
                onSubmitted: (_) => _handleSearch(),
                decoration: InputDecoration(
                  hintText: 'ID de prestamo, ID de usuario o ID de copia...',
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
              ElevatedButton(
                onPressed: _handleSearch,
                style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                child: const Text('Buscar'),
              ),
            ]),
          ]),
        ),

        if (_selectedLoan != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Informacion del Prestamo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              const SizedBox(height: 24),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _LabelValue('ID de Prestamo', _selectedLoan!.id),
                  const SizedBox(height: 16),
                  _LabelValue('Usuario', _selectedLoan!.userName, subtitle: _selectedLoan!.userId),
                  const SizedBox(height: 16),
                  _LabelValue('Libro', _selectedLoan!.bookTitle, subtitle: 'Copia: ${_selectedLoan!.copyId}'),
                ])),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _LabelValue('Fecha de Prestamo', _fmtDateLong(_selectedLoan!.loanDate)),
                  const SizedBox(height: 16),
                  _LabelValue('Fecha de Vencimiento', _fmtDateLong(_selectedLoan!.dueDate)),
                  const SizedBox(height: 16),
                  const Text('Estado', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  _LoanStatusBadge(_selectedLoan!.status),
                ])),
              ]),
              const SizedBox(height: 24),

              // Condition
              const Text('Condicion del Libro al Regresar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _bookCondition, isExpanded: true,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                    onChanged: (v) => setState(() => _bookCondition = v ?? 'Buena'),
                    items: [
                      const DropdownMenuItem(value: 'Buena', child: Text('Buena - Sin danos')),
                      const DropdownMenuItem(value: 'Regular', child: Text('Regular - Danos menores')),
                      const DropdownMenuItem(value: 'Mala', child: Text('Mala - Danos moderados')),
                      DropdownMenuItem(value: 'Danada', child: Text('Danada - Danos severos (Multa: \$${_selectedLoan!.bookPrice.toStringAsFixed(2)})')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fines summary
              if (_daysOverdue > 0 || _damageFine > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    border: Border.all(color: const Color(0xFFEF4444), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(LucideIcons.alertCircle, size: 18, color: Color(0xFFDC2626)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Multas Generadas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF7F1D1D))),
                      const SizedBox(height: 12),
                      if (_daysOverdue > 0) ...[
                        const Text('Multa por Retraso', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
                        const SizedBox(height: 4),
                        _FineRow('Dias habiles de retraso:', '$_daysOverdue dias'),
                        _FineRow('Costo por dia habil:', '\$10'),
                        _FineRow('Subtotal:', '\$${_lateFine.toStringAsFixed(2)}', bold: true),
                        if (_damageFine > 0) const Divider(color: Color(0xFFFCA5A5)),
                      ],
                      if (_damageFine > 0) ...[
                        const Text('Multa por Libro Danado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
                        const SizedBox(height: 4),
                        const _FineRow('Condicion:', 'Danada'),
                        _FineRow('Costo del libro:', '\$${_selectedLoan!.bookPrice.toStringAsFixed(2)}'),
                        _FineRow('Subtotal:', '\$${_damageFine.toStringAsFixed(2)}', bold: true),
                      ],
                      const Divider(color: Color(0xFFEF4444), thickness: 2),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total de Multas:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF991B1B))),
                        Text('\$${_totalFine.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF7F1D1D))),
                      ]),
                      const SizedBox(height: 12),
                      Text(
                        '${_daysOverdue > 0 ? "El periodo maximo de prestamo es de 5 dias habiles. " : ""}'
                        '${_damageFine > 0 ? "La multa por libro danado corresponde al costo completo del libro. " : ""}'
                        'Estas multas seran registradas y deberan ser pagadas antes de realizar nuevos prestamos.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                      ),
                    ])),
                  ]),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(color: const Color(0xFF22C55E), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(LucideIcons.checkCircle2, size: 18, color: Color(0xFF16A34A)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Devolucion Sin Multas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF14532D))),
                      const SizedBox(height: 4),
                      Text(
                        _bookCondition == 'Buena'
                            ? 'El libro fue devuelto a tiempo y en buenas condiciones. No se generaran multas.'
                            : 'El libro fue devuelto a tiempo. Solo se aplica multa por danos severos (libro danado).',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF166534)),
                      ),
                    ])),
                  ]),
                ),
            ]),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () => context.go('/loans'), child: const Text('Cancelar')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _showConfirmDialog,
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
              child: const Text('Confirmar Devolucion'),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label, value;
  final String? subtitle;
  const _LabelValue(this.label, this.value, {this.subtitle});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
    if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
  ]);
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
    ]),
  );
}

class _FineRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _FineRow(this.label, this.value, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, color: bold ? const Color(0xFF991B1B) : const Color(0xFFB91C1C))),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: const Color(0xFF7F1D1D))),
    ]),
  );
}

class _LoanStatusBadge extends StatelessWidget {
  final LoanStatus status;
  const _LoanStatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case LoanStatus.active:   bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669);
      case LoanStatus.overdue:  bg = const Color(0xFFFEE2E2); fg = const Color(0xFFEF4444);
      case LoanStatus.returned: bg = const Color(0xFFF3F4F6); fg = const Color(0xFF6B7280);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
