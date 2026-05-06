import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/api_service.dart';
import '../../core/models/models.dart';

class WaitlistPage extends StatefulWidget {
  const WaitlistPage({super.key});
  @override
  State<WaitlistPage> createState() => _WaitlistPageState();
}

class _WaitlistPageState extends State<WaitlistPage> {
  final _searchCtrl = TextEditingController();
  static const _green = Color(0xFF0E7334);

  List<WaitlistEntry> _waitlist = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWaitlist();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _loadWaitlist() async {
    try {
      final list = await ApiService.getWaitlist();
      if (mounted) setState(() { _waitlist = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<WaitlistEntry> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    return _waitlist.where((e) =>
        q.isEmpty ||
        e.bookTitle.toLowerCase().contains(q) ||
        e.userName.toLowerCase().contains(q) ||
        e.userId.toLowerCase().contains(q)).toList();
  }

  String _fmtDate(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _green));
    final filtered = _filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Lista de Espera', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Gestiona las solicitudes de libros sin copias disponibles',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),

        // Search
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Buscar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
            const SizedBox(height: 8),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Libro, Usuario...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFD1D5DB)),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF9CA3AF)),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _green, width: 2)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        Text('Mostrando ${filtered.length} de ${_waitlist.length} solicitudes',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 12),

        // Table
        Container(
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: const Row(children: [
                Expanded(flex: 1, child: _TH('POSICION')),
                Expanded(flex: 3, child: _TH('LIBRO')),
                Expanded(flex: 2, child: _TH('ISBN')),
                Expanded(flex: 3, child: _TH('USUARIO')),
                Expanded(flex: 2, child: _TH('FECHA DE SOLICITUD')),
                Expanded(flex: 2, child: _TH('ACCIONES')),
              ]),
            ),
            ...filtered.map((e) => _WaitlistRow(entry: e, fmtDate: _fmtDate,
              onNotify: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notificacion enviada a ${e.userName}')));
              },
              onRemove: () async {
                try {
                  await ApiService.deleteWaitlistEntry(e.id);
                  _loadWaitlist();
                } catch (_) {}
              },
            )),
            if (filtered.isEmpty)
              Padding(padding: const EdgeInsets.all(48),
                child: Column(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(LucideIcons.clock, size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 16),
                  Text('No hay solicitudes en lista de espera',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 24),

        // Info box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            border: Border.all(color: const Color(0xFFBFDBFE)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Icon(LucideIcons.bell, size: 18, color: Color(0xFF2563EB)),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Como funciona la lista de espera',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
              SizedBox(height: 4),
              Text(
                'Cuando un usuario solicita un libro sin copias disponibles, se agrega a la lista de espera. '
                'Los usuarios en primera posicion pueden ser notificados cuando una copia este disponible.',
                style: TextStyle(fontSize: 13, color: Color(0xFF1D4ED8)),
              ),
            ])),
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

class _WaitlistRow extends StatelessWidget {
  final WaitlistEntry entry;
  final String Function(DateTime) fmtDate;
  final VoidCallback onNotify, onRemove;
  const _WaitlistRow({required this.entry, required this.fmtDate, required this.onNotify, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF0E7334);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(children: [
        Expanded(flex: 1, child: Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(color: green, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('${entry.position}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        )),
        Expanded(flex: 3, child: Text(entry.bookTitle,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827)))),
        Expanded(flex: 2, child: Text(entry.bookIsbn,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
          Text(entry.userId, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ])),
        Expanded(flex: 2, child: Row(children: [
          const Icon(LucideIcons.clock, size: 14, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Text(fmtDate(entry.requestDate), style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ])),
        Expanded(flex: 2, child: Row(children: [
          if (entry.position == 1)
            IconButton(
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              icon: const Icon(LucideIcons.bell, size: 17, color: green),
              tooltip: 'Notificar usuario',
              onPressed: onNotify,
            ),
          const SizedBox(width: 4),
          IconButton(
            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
            icon: const Icon(LucideIcons.trash2, size: 17, color: Color(0xFFEF4444)),
            tooltip: 'Eliminar solicitud',
            onPressed: onRemove,
          ),
        ])),
      ]),
    );
  }
}
