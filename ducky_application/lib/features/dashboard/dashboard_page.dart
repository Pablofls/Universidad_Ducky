import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/api_service.dart';
import '../../core/models/models.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await ApiService.getDashboard();
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0E7334)));
    }
    if (_error != null || _stats == null) {
      return Center(child: Text(_error ?? 'Error cargando datos',
          style: const TextStyle(color: Color(0xFFEF4444))));
    }
    final stats = _stats!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          const Text('Tablero de Control', style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF111827),
          )),
          const SizedBox(height: 4),
          const Text('Bienvenido al Sistema de Gestión Ducky', style: TextStyle(
            fontSize: 14, color: Color(0xFF6B7280),
          )),
          const SizedBox(height: 28),

          // ── Stat cards ───────────────────────────────────────────────
          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - 48) / 4;
            return Row(children: [
              _StatCard(label: 'Total de Libros',     value: '${stats.totalBooks}',
                icon: LucideIcons.tablet, iconBg: const Color(0xFFEFF6FF), iconColor: const Color(0xFF3B82F6), width: w),
              const SizedBox(width: 16),
              _StatCard(label: 'Total de Ejemplares', value: '${stats.totalCopies}',
                icon: LucideIcons.bookCopy, iconBg: const Color(0xFFD1FAE5), iconColor: const Color(0xFF10B981), width: w),
              const SizedBox(width: 16),
              _StatCard(label: 'Préstamos Activos',   value: '${stats.activeLoans}',
                icon: LucideIcons.bookOpen, iconBg: const Color(0xFFFEF3C7), iconColor: const Color(0xFFF59E0B), width: w),
              const SizedBox(width: 16),
              _StatCard(label: 'Libros Vencidos',     value: '${stats.overdueBooks}',
                icon: LucideIcons.alertCircle, iconBg: const Color(0xFFFEE2E2), iconColor: const Color(0xFFEF4444), width: w),
            ]);
          }),
          const SizedBox(height: 24),

          // ── Charts ───────────────────────────────────────────────────
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Loan trend bar chart (last 7 days)
            Expanded(flex: 3, child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Préstamos (últimos 7 días)', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const SizedBox(height: 20),
                SizedBox(height: 200, child: BarChart(BarChartData(
                  barGroups: stats.loanTrend.asMap().entries.map((e) {
                    return BarChartGroupData(x: e.key, barRods: [
                      BarChartRodData(
                        toY: (e.value['count'] as int).toDouble(),
                        color: const Color(0xFF0E7334),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ]);
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= stats.loanTrend.length) return const SizedBox.shrink();
                        final day = stats.loanTrend[i]['day'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(day.substring(5), style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                        );
                      },
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                          style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                    )),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ))),
              ]),
            )),
            const SizedBox(width: 16),
            // Topic distribution pie chart
            Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Libros por Tema', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const SizedBox(height: 20),
                SizedBox(height: 200, child: PieChart(PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 36,
                  sections: stats.topicDistribution.asMap().entries.map((e) {
                    final colors = [
                      const Color(0xFF0E7334), const Color(0xFF3B82F6), const Color(0xFFF59E0B),
                      const Color(0xFFEF4444), const Color(0xFF8B5CF6), const Color(0xFF10B981),
                      const Color(0xFFF97316), const Color(0xFF06B6D4),
                    ];
                    return PieChartSectionData(
                      value: (e.value['count'] as int).toDouble(),
                      color: colors[e.key % colors.length],
                      radius: 40,
                      title: '${e.value['count']}',
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    );
                  }).toList(),
                ))),
                const SizedBox(height: 16),
                Wrap(spacing: 12, runSpacing: 6, children: stats.topicDistribution.asMap().entries.map((e) {
                  final colors = [
                    const Color(0xFF0E7334), const Color(0xFF3B82F6), const Color(0xFFF59E0B),
                    const Color(0xFFEF4444), const Color(0xFF8B5CF6), const Color(0xFF10B981),
                    const Color(0xFFF97316), const Color(0xFF06B6D4),
                  ];
                  return Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(
                        color: colors[e.key % colors.length], shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(e.value['topic'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ]);
                }).toList()),
              ]),
            )),
          ]),
        ],
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconBg, iconColor;
  final double width;
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.iconBg, required this.iconColor,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(
                fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700,
                color: Color(0xFF111827))),
          ])),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ],
      ),
    );
  }
}
