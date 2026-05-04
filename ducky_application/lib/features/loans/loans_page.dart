import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'active_loans_page.dart';
import 'new_loan_page.dart';
import 'return_book_page.dart';
import 'fines_page.dart';

class LoansPage extends StatefulWidget {
  final int initialTab;
  final String? loanId;
  const LoansPage({super.key, this.initialTab = 0, this.loanId});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  static const _green = Color(0xFF0E7334);

  static const _tabs = [
    (icon: LucideIcons.calendar, label: 'Prestamos Activos'),
    (icon: LucideIcons.plus, label: 'Nuevo Prestamo'),
    (icon: LucideIcons.rotateCcw, label: 'Devoluciones'),
    (icon: LucideIcons.dollarSign, label: 'Multas'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              labelColor: _green,
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: _green,
              indicatorWeight: 2,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: _tabs.map((t) => Tab(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(t.icon, size: 16),
                  const SizedBox(width: 8),
                  Text(t.label),
                ]),
              )).toList(),
            ),
          ),
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const ActiveLoansPage(),
            const NewLoanPage(),
            ReturnBookPage(prefilledLoanId: widget.loanId),
            const FinesPage(),
          ],
        ),
      ),
    ]);
  }
}
