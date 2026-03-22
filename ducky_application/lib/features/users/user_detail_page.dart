import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/mock_data.dart';
import '../../core/models/models.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;
  const UserDetailPage({super.key, required this.userId});

  static const _green = Color(0xFF0E7334);

  @override
  Widget build(BuildContext context) {
    final user = MockData.users.firstWhere(
      (u) => u.id == userId, orElse: () => MockData.users.first);
    final loans = MockData.loans.where((l) => l.userId == userId).toList();
    final fines = loans.where((l) => l.fine != null && l.fine! > 0)
        .fold(0.0, (s, l) => s + l.fine!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Breadcrumb
        Row(children: [
          GestureDetector(onTap: () => context.go('/'),
            child: const Icon(LucideIcons.home, size: 14, color: Color(0xFF9CA3AF))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          GestureDetector(onTap: () => context.go('/users'),
            child: const Text('Users', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF9CA3AF)),
          Text(user.name, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 12),

        // Header
        Row(children: [
          GestureDetector(onTap: () => context.go('/users'),
            child: const Icon(LucideIcons.arrowLeft, size: 20, color: Color(0xFF374151))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user.name, style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            Text('${user.role.label} - ${user.id}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ])),
          _statusBadge(user.isActive),
        ]),
        const SizedBox(height: 24),

        LayoutBuilder(builder: (ctx, c) {
          final half = (c.maxWidth - 20) / 2;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Profile info
            _card(half, 'Profile Information', null,
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 8),
                _infoRow(LucideIcons.mail, 'Email', user.email),
                const Divider(height: 24, color: Color(0xFFF3F4F6)),
                _infoRow(LucideIcons.calendar, 'Member Since',
                    DateFormat('MMMM d, y').format(user.createdAt)),
                if (user.phone != null) ...[
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _infoRow(LucideIcons.phone, 'Phone', user.phone!),
                ],
              ]),
            ),
            const SizedBox(width: 20),
            // Borrowed books
            _card(half, 'Borrowed Books',
              Text('${loans.length} active loans',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              loans.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay prestamos activos',
                        style: TextStyle(color: Color(0xFF9CA3AF))))
                : Column(children: loans.map((loan) {
                    final overdue = loan.status == LoanStatus.overdue;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(loan.bookTitle, style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                          const SizedBox(height: 2),
                          Text('Copy ID: ${loan.copyId}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          Text(
                            'Borrowed: ${DateFormat('M/d/y').format(loan.loanDate)} - '
                            'Due: ${DateFormat('M/d/y').format(loan.dueDate)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: overdue ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(overdue ? 'Vencido' : 'Activo',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                              color: overdue ? const Color(0xFFEF4444) : const Color(0xFF059669))),
                        ),
                      ]),
                    );
                  }).toList()),
            ),
          ]);
        }),
        const SizedBox(height: 20),

        // Account status
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Account Status', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Account Status',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                _statusBadge(user.isActive),
              ])),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total Books Borrowed',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                Text('${loans.length}', style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              ])),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Outstanding Fines',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                Text('\$${fines.toStringAsFixed(2)}', style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700,
                    color: fines > 0 ? const Color(0xFFEF4444) : _green)),
              ])),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _statusBadge(bool active) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(active ? 'Activo' : 'Suspendido', style: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: active ? const Color(0xFF059669) : const Color(0xFFEF4444))),
  );

  Widget _card(double width, String title, Widget? trailing, Widget body) =>
    Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          if (trailing != null) trailing,
        ]),
        body,
      ]),
    );

  Widget _infoRow(IconData icon, String label, String value) =>
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF111827))),
      ]),
    ]);
}