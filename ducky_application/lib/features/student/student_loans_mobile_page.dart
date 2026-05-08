import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';
import '../../core/auth/auth_provider.dart';

class StudentLoansMobilePage extends StatefulWidget {
  const StudentLoansMobilePage({super.key});
  @override
  State<StudentLoansMobilePage> createState() => _StudentLoansMobilePageState();
}

class _StudentLoansMobilePageState extends State<StudentLoansMobilePage> {
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
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: _green)));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Container(
          color: _green,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(LucideIcons.calendar, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              const Text('Mis Préstamos', style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 4),
            const Text('Consulta el estado y vencimiento',
                style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13)),
          ]),
        )),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Tienes ${_loans.where((l) => l.status != LoanStatus.returned).length} préstamo(s) activo(s)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        )),
        if (_loans.isEmpty)
          SliverToBoxAdapter(child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(children: const [
              Icon(LucideIcons.checkCircle, size: 36, color: Color(0xFF9CA3AF)),
              SizedBox(height: 12),
              Text('No tienes préstamos', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            ]),
          ))
        else
          SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) => _MobileLoanTile(loan: _loans[i], fmtDate: _fmtDate),
            childCount: _loans.length,
          )),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ]),
    );
  }
}

class _MobileLoanTile extends StatelessWidget {
  final Loan loan;
  final String Function(DateTime) fmtDate;
  const _MobileLoanTile({required this.loan, required this.fmtDate});

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: returned ? const Color(0xFFF9FAFB) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: overdue ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(loan.bookTitle, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: returned ? const Color(0xFF6B7280) : const Color(0xFF111827)))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
            child: Text(badgeLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeFg)),
          ),
        ]),
        const SizedBox(height: 8),
        Text('Copia: ${loan.copyId}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: Text('Fecha: ${fmtDate(loan.loanDate)}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
          Expanded(child: Text('Vence: ${fmtDate(loan.dueDate)}', 
              style: TextStyle(fontSize: 12, 
                fontWeight: overdue ? FontWeight.w700 : FontWeight.w400,
                color: overdue ? const Color(0xFFEF4444) : const Color(0xFF6B7280)))),
        ]),
        if (loan.fine != null && loan.fine! > 0) ...[
          const SizedBox(height: 8),
          Text('Multa: \$${loan.fine!.toStringAsFixed(2)}', 
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
        ],
      ]),
    );
  }
}
