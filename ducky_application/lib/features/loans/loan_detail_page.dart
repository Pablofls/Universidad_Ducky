import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/mock_data.dart';
import '../../core/models/models.dart';

class LoanDetailPage extends StatefulWidget {
  final String loanId;
  const LoanDetailPage({super.key, required this.loanId});
  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  static const _green = Color(0xFF0E7334);

  Loan? get _loan => MockData.loans.where((l) => l.id == widget.loanId).firstOrNull;

  String _fmtDateLong(DateTime d) {
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  DateTime _getNewDueDate() {
    return _loan!.dueDate.add(const Duration(days: 14));
  }

  void _showRenewDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: _green.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(LucideIcons.refreshCw, size: 32, color: _green),
        ),
        const SizedBox(height: 16),
        const Text('Confirmar Renovacion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Estas seguro de renovar este prestamo?', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            _InfoRow('Prestamo:', _loan!.id),
            _InfoRow('Vencimiento actual:', _fmtDateLong(_loan!.dueDate)),
            _InfoRow('Nuevo vencimiento:', _fmtDateLong(_getNewDueDate()), valueColor: _green),
            _InfoRow('Renovaciones:', '${_loan!.renewalCount + 1} de 2'),
          ]),
        ),
      ]),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prestamo renovado exitosamente')));
            context.go('/loans');
          },
          style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
          child: const Text('Confirmar'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final loan = _loan;
    if (loan == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.alertCircle, size: 48, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          const Text('Prestamo no encontrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('No se encontro el prestamo con ID: ${widget.loanId}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () => context.go('/loans'), child: const Text('Volver a Prestamos')),
        ])),
      );
    }

    final canRenew = loan.status == LoanStatus.active && loan.renewalCount < 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Back
        TextButton.icon(
          onPressed: () => context.go('/loans'),
          icon: const Icon(LucideIcons.arrowLeft, size: 16),
          label: const Text('Volver a Prestamos'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Detalle del Prestamo', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            Text(loan.id, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ])),
          _StatusBadge(loan.status),
        ]),
        const SizedBox(height: 24),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Main content
          Expanded(flex: 2, child: Column(children: [
            // Loan info
            _Card('Informacion del Prestamo', child: Column(children: [
              Row(children: [
                Expanded(child: _LabelValue('ID de Prestamo', loan.id)),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Estado', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  _StatusBadge(loan.status),
                ])),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _LabelValue('Fecha de Prestamo', _fmtDateLong(loan.loanDate))),
                Expanded(child: _LabelValue('Fecha de Vencimiento', _fmtDateLong(loan.dueDate))),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                if (loan.returnDate != null)
                  Expanded(child: _LabelValue('Fecha de Devolucion', _fmtDateLong(loan.returnDate!))),
                Expanded(child: _LabelValue('Renovaciones Realizadas', '${loan.renewalCount} de 2')),
              ]),
            ])),
            const SizedBox(height: 24),
            _Card('Informacion del Usuario', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _LabelValue('Nombre', loan.userName),
              const SizedBox(height: 12),
              _LabelValue('ID de Usuario', loan.userId),
            ])),
            const SizedBox(height: 24),
            _Card('Informacion del Libro', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _LabelValue('Titulo', loan.bookTitle),
              const SizedBox(height: 12),
              _LabelValue('ID de Copia', loan.copyId),
            ])),
          ])),

          const SizedBox(width: 24),

          // Sidebar
          Expanded(flex: 1, child: Column(children: [
            if (loan.status == LoanStatus.active)
              _Card('Renovar Prestamo', icon: LucideIcons.refreshCw, child: canRenew
                ? Column(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: const [
                        Icon(LucideIcons.checkCircle2, size: 18, color: Color(0xFF16A34A)),
                        SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Renovacion Disponible', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF14532D))),
                          Text('Puedes renovar este prestamo', style: TextStyle(fontSize: 12, color: Color(0xFF166534))),
                        ])),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow('Vencimiento actual:', _fmtDateLong(loan.dueDate)),
                    _InfoRow('Nuevo vencimiento:', _fmtDateLong(_getNewDueDate()), valueColor: _green),
                    _InfoRow('Renovaciones:', '${loan.renewalCount} de 2'),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      onPressed: _showRenewDialog,
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Renovar Prestamo'),
                      style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
                    )),
                  ])
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2),
                        border: Border.all(color: const Color(0xFFFECACA)),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(LucideIcons.alertCircle, size: 18, color: Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('No se puede renovar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7F1D1D))),
                        Text(
                          loan.renewalCount >= 2 ? 'Se alcanzo el limite de renovaciones (2)' : 'El prestamo esta vencido',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                        ),
                      ])),
                    ]),
                  ),
              ),
            const SizedBox(height: 24),
            _Card('Acciones Rapidas', child: Column(children: [
              if (loan.status != LoanStatus.returned)
                SizedBox(width: double.infinity, child: OutlinedButton.icon(
                  onPressed: () => context.go('/loans/return?loanId=${loan.id}'),
                  icon: const Icon(LucideIcons.checkCircle2, size: 16),
                  label: const Text('Registrar Devolucion'),
                )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(
                onPressed: () => context.go('/users/${loan.userId}'),
                icon: const Icon(LucideIcons.user, size: 16),
                label: const Text('Ver Perfil del Usuario'),
              )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(
                onPressed: () => context.go('/copies/${loan.copyId}'),
                icon: const Icon(LucideIcons.copy, size: 16),
                label: const Text('Ver Detalle de Copia'),
              )),
            ])),
          ])),
        ]),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  const _Card(this.title, {this.icon, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        if (icon != null) ...[Icon(icon!, size: 18), const SizedBox(width: 8)],
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
      ]),
      const SizedBox(height: 16),
      child,
    ]),
  );
}

class _LabelValue extends StatelessWidget {
  final String label, value;
  const _LabelValue(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
  ]);
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor ?? const Color(0xFF111827))),
    ]),
  );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
