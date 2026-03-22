import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/mock_data.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              _StatCard(label: 'Total de Libros',     value: '${MockData.dashboardStats.totalBooks}',
                icon: LucideIcons.tablet, iconBg: const Color(0xFFEFF6FF), iconColor: const Color(0xFF3B82F6), width: w),
              const SizedBox(width: 16),
              _StatCard(label: 'Total de Ejemplares', value: '${MockData.dashboardStats.totalCopies}',
                icon: LucideIcons.bookCopy, iconBg: const Color(0xFFD1FAE5), iconColor: const Color(0xFF10B981), width: w),
              const SizedBox(width: 16),
              _StatCard(label: 'Préstamos Activos',   value: '${MockData.dashboardStats.activeLoans}',
                icon: LucideIcons.bookOpen, iconBg: const Color(0xFFFEF3C7), iconColor: const Color(0xFFF59E0B), width: w),
              const SizedBox(width: 16),
              _StatCard(label: 'Libros Vencidos',     value: '${MockData.dashboardStats.overdueBooks}',
                icon: LucideIcons.alertCircle, iconBg: const Color(0xFFFEE2E2), iconColor: const Color(0xFFEF4444), width: w),
            ]);
          }),
          const SizedBox(height: 24),

          // ── Charts ───────────────────────────────────────────────────
          LayoutBuilder(builder: (context, c) {
            final half = (c.maxWidth - 20) / 2;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoanTrendChart(width: half),
                const SizedBox(width: 20),
                _CategoryPieChart(width: half),
              ],
            );
          }),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(
                fontSize: 12, color: Color(0xFF6B7280))),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700,
                color: Color(0xFF111827))),
          ]),
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

// ── Loan trend bar chart ───────────────────────────────────────────────────────
class _LoanTrendChart extends StatelessWidget {
  final double width;
  const _LoanTrendChart({required this.width});

  @override
  Widget build(BuildContext context) {
    final data = MockData.loanTrend;
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tendencia de Préstamos', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 2),
        const Text('Actividad mensual de préstamos', style: TextStyle(
            fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        SizedBox(
          height: 240,
          child: BarChart(BarChartData(
            gridData: FlGridData(
              show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFE5E7EB), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 28,
                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              )),
              rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  return Text(data[i]['month'] as String,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)));
                },
              )),
            ),
            barGroups: data.asMap().entries.map((e) => BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(
                toY: (e.value['loans'] as int).toDouble(),
                color: const Color(0xFF3B82F6),
                width: 32,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              )],
            )).toList(),
          )),
        ),
      ]),
    );
  }
}

// ── Category pie chart ─────────────────────────────────────────────────────────
class _CategoryPieChart extends StatelessWidget {
  final double width;
  const _CategoryPieChart({required this.width});

  static const _colors = [
    Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFF8B5CF6), Color(0xFF6B7280),
  ];

  @override
  Widget build(BuildContext context) {
    final data  = MockData.categoryDistribution;
    final total = data.fold<int>(0, (s, e) => s + (e['value'] as int));

    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Categorías de Libros', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 2),
        const Text('Distribución por tema', style: TextStyle(
            fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        SizedBox(
          height: 240,
          child: PieChart(PieChartData(
            sections: data.asMap().entries.map((e) {
              final pct = (e.value['value'] as int) / total * 100;
              return PieChartSectionData(
                value: (e.value['value'] as int).toDouble(),
                color: _colors[e.key % _colors.length],
                radius: 90,
                title: '${pct.toStringAsFixed(0)}%',
                titleStyle: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.white),
                titlePositionPercentageOffset: 0.6,
                badgeWidget: _PieBadge(
                  label: e.value['name'] as String,
                  color: _colors[e.key % _colors.length],
                  pct: pct,
                ),
                badgePositionPercentageOffset: 1.35,
              );
            }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 0,
          )),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(spacing: 12, runSpacing: 6,
          children: data.asMap().entries.map((e) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 10, height: 10,
                decoration: BoxDecoration(
                  color: _colors[e.key % _colors.length],
                  shape: BoxShape.circle,
                )),
              const SizedBox(width: 4),
              Text(e.value['name'] as String,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          )).toList(),
        ),
      ]),
    );
  }
}

class _PieBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double pct;
  const _PieBadge({required this.label, required this.color, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${label} ${pct.toStringAsFixed(0)}%',
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
    );
  }
}
