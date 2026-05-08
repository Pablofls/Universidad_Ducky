import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';
import '../../core/auth/auth_provider.dart';

class StudentLoansPage extends StatefulWidget {
  const StudentLoansPage({super.key});
  @override
  State<StudentLoansPage> createState() => _StudentLoansPageState();
}

class _StudentLoansPageState extends State<StudentLoansPage> {
  static const _green = Color(0xFF0E7334);
  List<Loan> _loans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final loans = await ApiService.getLoans(userId: user.id);
        if (mounted) {
          setState(() {
            // Sort active / overdue first, then by date
            _loans = loans;
            _loans.sort((a, b) {
               if (a.status == LoanStatus.returned && b.status != LoanStatus.returned) return 1;
               if (a.status != LoanStatus.returned && b.status == LoanStatus.returned) return -1;
               return a.dueDate.compareTo(b.dueDate);
            });
            _loading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _green));

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Green header ────────────────────────────────────────────
        Container(
          width: double.infinity,
          color: _green,
          padding: const EdgeInsets.fromLTRB(48, 40, 48, 48),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(LucideIcons.calendar, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text('Mis Préstamos', style: TextStyle(
                  color: Colors.white, fontSize: 28,
                  fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 6),
            const Text('Consulta el estado de tus libros y fechas de vencimiento',
                style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14)),
          ]),
        ),

        // ── Content ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 32, 48, 16),
          child: Text('Tienes ${_loans.where((l) => l.status != LoanStatus.returned).length} préstamo(s) activo(s)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: _loans.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Column(children: const [
                  Icon(LucideIcons.checkCircle, size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 16),
                  Text('No tienes préstamos registrados.',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
                ]),
              )
            : Column(
                children: _loans.map((l) => _StudentLoanCard(loan: l, fmtDate: _fmtDate)).toList(),
              ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }
}

class _StudentLoanCard extends StatelessWidget {
  final Loan loan;
  final String Function(DateTime) fmtDate;
  const _StudentLoanCard({required this.loan, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    final overdue = loan.status == LoanStatus.overdue;
    final returned = loan.status == LoanStatus.returned;

    Color badgeBg = const Color(0xFFD1FAE5);
    Color badgeFg = const Color(0xFF059669);
    String badgeLabel = 'Activo';

    if (overdue) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeFg = const Color(0xFFEF4444);
      badgeLabel = 'Vencido';
    } else if (returned) {
      badgeBg = const Color(0xFFF3F4F6);
      badgeFg = const Color(0xFF6B7280);
      badgeLabel = 'Devuelto';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: returned ? const Color(0xFFF9FAFB) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: overdue ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 72,
          decoration: BoxDecoration(
              color: returned ? const Color(0xFF9CA3AF) : const Color(0xFF0E7334), 
              borderRadius: BorderRadius.circular(6)),
          child: const Icon(LucideIcons.bookOpen, size: 28, color: Colors.white),
        ),
        const SizedBox(width: 20),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(loan.bookTitle, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: returned ? const Color(0xFF6B7280) : const Color(0xFF111827)))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
              child: Text(badgeLabel,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: badgeFg)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _MetaField('ID Copia:', loan.copyId)),
            Expanded(child: _MetaField('Fecha Préstamo:', fmtDate(loan.loanDate))),
            Expanded(child: _MetaField('Vencimiento:', fmtDate(loan.dueDate), 
                highlight: overdue, color: overdue ? const Color(0xFFEF4444) : null)),
          ]),
          if (loan.fine != null && loan.fine! > 0) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(LucideIcons.alertTriangle, size: 14, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Text('Multa pendiente: \$${loan.fine!.toStringAsFixed(2)}', 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
            ]),
          ]
        ])),
      ]),
    );
  }
}

class _MetaField extends StatelessWidget {
  final String label, value;
  final bool highlight;
  final Color? color;
  const _MetaField(this.label, this.value, {this.highlight = false, this.color});
  
  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: const TextStyle(fontSize: 13),
      children: [
        TextSpan(text: label,
            style: const TextStyle(color: Color(0xFF6B7280))),
        const TextSpan(text: '  '),
        TextSpan(text: value,
            style: TextStyle(
                color: color ?? const Color(0xFF374151), 
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500)),
      ],
    ),
  );
}
