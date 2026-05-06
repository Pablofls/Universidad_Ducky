import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/api_service.dart';
import '../../core/models/models.dart';

class NewLoanPage extends StatefulWidget {
  const NewLoanPage({super.key});
  @override
  State<NewLoanPage> createState() => _NewLoanPageState();
}

class _NewLoanPageState extends State<NewLoanPage> {
  static const _green = Color(0xFF0E7334);

  final _userSearchCtrl = TextEditingController();
  final _bookSearchCtrl = TextEditingController();
  AppUser? _selectedUser;
  Book? _selectedBook;
  BookCopy? _selectedCopy;

  @override
  void dispose() { _userSearchCtrl.dispose(); _bookSearchCtrl.dispose(); super.dispose(); }

  List<AppUser> _allUsers = [];
  List<Book> _allBooks = [];
  List<BookCopy> _allCopies = [];
  List<Loan> _allLoans = [];
  List<Fine> _allFines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getUsers(),
        ApiService.getBooks(),
        ApiService.getCopies(),
        ApiService.getLoans(),
        ApiService.getFines(),
      ]);
      if (mounted) setState(() {
        _allUsers  = results[0] as List<AppUser>;
        _allBooks  = results[1] as List<Book>;
        _allCopies = results[2] as List<BookCopy>;
        _allLoans  = results[3] as List<Loan>;
        _allFines  = results[4] as List<Fine>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AppUser> get _userResults {
    final q = _userSearchCtrl.text.toLowerCase();
    if (q.isEmpty || _selectedUser != null) return [];
    return _allUsers.where((u) =>
        u.id.toLowerCase().contains(q) || u.name.toLowerCase().contains(q)).take(5).toList();
  }

  List<Book> get _bookResults {
    final q = _bookSearchCtrl.text.toLowerCase();
    if (q.isEmpty || _selectedBook != null) return [];
    return _allBooks.where((b) =>
        b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q) || b.isbn.toLowerCase().contains(q)).take(5).toList();
  }

  List<BookCopy> get _availableCopies {
    if (_selectedBook == null) return [];
    return _allCopies.where((c) =>
        c.isbn == _selectedBook!.isbn && c.status == CopyStatus.available).toList();
  }

  ({bool isEligible, int activeLoans, bool hasOverdue, bool hasFines, double finesAmount}) _getEligibility(AppUser user) {
    final userLoans = _allLoans.where((l) => l.userId == user.id && l.status != LoanStatus.returned).toList();
    final activeLoans = userLoans.length;
    final hasOverdue = userLoans.any((l) => l.status == LoanStatus.overdue);
    final userFines = _allFines.where((f) => f.userId == user.id && f.status == FineStatus.pending).toList();
    final hasFines = userFines.isNotEmpty;
    final finesAmount = userFines.fold<double>(0, (s, f) => s + f.amount);
    return (isEligible: !hasFines && !hasOverdue && activeLoans < 3, activeLoans: activeLoans, hasOverdue: hasOverdue, hasFines: hasFines, finesAmount: finesAmount);
  }

  String _fmtDateLong(DateTime d) {
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  DateTime get _today => DateTime.now();
  DateTime get _dueDate => _today.add(const Duration(days: 14));

  void _showConfirmDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirmar Prestamo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _InfoRow('Usuario:', _selectedUser!.name),
        _InfoRow('Libro:', _selectedBook!.title),
        _InfoRow('ID de Copia:', _selectedCopy!.id),
        _InfoRow('Fecha de prestamo:', _fmtDateLong(_today)),
        _InfoRow('Fecha de vencimiento:', _fmtDateLong(_dueDate)),
      ]),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            try {
              final loan = await ApiService.createLoan({
                'user_id': _selectedUser!.id,
                'copy_id': _selectedCopy!.id,
                'due_date': _dueDate.toIso8601String(),
              });
              _showReceiptDialog(loan.id);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al crear prestamo: $e'),
                      backgroundColor: const Color(0xFFEF4444)));
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
          child: const Text('Confirmar Prestamo'),
        ),
      ],
    ));
  }

  void _showReceiptDialog(String loanId) {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(color: Color(0xFFD1FAE5), shape: BoxShape.circle),
          child: const Icon(LucideIcons.checkCircle2, size: 32, color: Color(0xFF059669)),
        ),
        const SizedBox(height: 16),
        const Text('Prestamo Registrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Recibo de Prestamo', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
          child: Column(children: [
            _InfoRow('ID del prestamo:', loanId),
            _InfoRow('Nombre del usuario:', _selectedUser!.name),
            _InfoRow('Titulo del libro:', _selectedBook!.title),
            _InfoRow('ID de copia:', _selectedCopy!.id),
            _InfoRow('Fecha de prestamo:', _fmtDateLong(_today)),
            _InfoRow('Fecha de vencimiento:', _fmtDateLong(_dueDate)),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, child: const Text('Imprimir Recibo'))),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, child: const Text('Enviar por Correo'))),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, child: const Text('Enviar por WhatsApp'))),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () { Navigator.pop(ctx); context.go('/loans'); },
          style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
          child: const Text('Finalizar'),
        )),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _green));
    final eligibility = _selectedUser != null ? _getEligibility(_selectedUser!) : null;
    final canSubmit = _selectedUser != null && _selectedCopy != null && (eligibility?.isEligible ?? false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Registrar Nuevo Prestamo', style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
        const SizedBox(height: 4),
        const Text('Busca el usuario y selecciona el libro a prestar',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Left - User
          Expanded(child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(LucideIcons.user, size: 18, color: _green),
                SizedBox(width: 8),
                Text('Informacion del Usuario', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              ]),
              const SizedBox(height: 16),
              const Text('Buscar Usuario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              TextField(
                controller: _userSearchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ID de usuario o nombre...',
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
              if (_userResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 192),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                  child: ListView(shrinkWrap: true, children: _userResults.map((u) => InkWell(
                    onTap: () => setState(() { _selectedUser = u; _userSearchCtrl.clear(); }),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(u.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                        Text('${u.id} - ${u.role.label}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      ]),
                    ),
                  )).toList()),
                ),
              if (_selectedUser != null && eligibility != null) ...[
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_selectedUser!.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                    Text(_selectedUser!.id, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ]),
                  IconButton(icon: const Icon(LucideIcons.x, size: 18), onPressed: () => setState(() => _selectedUser = null)),
                ]),
                const SizedBox(height: 12),
                _InfoRow('Tipo de usuario:', _selectedUser!.role.label),
                _InfoRow('Libros prestados:', '${eligibility.activeLoans}'),
                _InfoRow('Multas pendientes:', '\$${eligibility.finesAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: eligibility.isEligible ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                    border: Border.all(color: eligibility.isEligible ? const Color(0xFF22C55E) : const Color(0xFFEF4444), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(eligibility.isEligible ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
                          size: 18, color: eligibility.isEligible ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      Text(eligibility.isEligible ? 'Autorizado' : 'No Autorizado',
                          style: TextStyle(fontWeight: FontWeight.w600,
                              color: eligibility.isEligible ? const Color(0xFF14532D) : const Color(0xFF7F1D1D))),
                    ]),
                    if (!eligibility.isEligible) ...[
                      const SizedBox(height: 8),
                      if (eligibility.hasFines) Text('• Tiene multas pendientes', style: TextStyle(fontSize: 13, color: Colors.red[800])),
                      if (eligibility.hasOverdue) Text('• Tiene prestamos vencidos', style: TextStyle(fontSize: 13, color: Colors.red[800])),
                      if (eligibility.activeLoans >= 3) Text('• Tiene mas de 2 libros prestados', style: TextStyle(fontSize: 13, color: Colors.red[800])),
                    ],
                  ]),
                ),
              ],
              if (_selectedUser == null) ...[
                const SizedBox(height: 32),
                Center(child: Column(children: const [
                  Icon(LucideIcons.user, size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 8),
                  Text('Busca y selecciona un usuario', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ])),
              ],
            ]),
          )),

          const SizedBox(width: 24),

          // Right - Book
          Expanded(child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(LucideIcons.bookOpen, size: 18, color: _green),
                SizedBox(width: 8),
                Text('Seleccion del Libro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              ]),
              const SizedBox(height: 16),
              const Text('Buscar Libro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
              const SizedBox(height: 8),
              TextField(
                controller: _bookSearchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Titulo, autor o ISBN...',
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
              if (_bookResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 192),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                  child: ListView(shrinkWrap: true, children: _bookResults.map((b) => InkWell(
                    onTap: () => setState(() { _selectedBook = b; _bookSearchCtrl.clear(); }),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                        Text('${b.author} - ISBN: ${b.isbn}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      ]),
                    ),
                  )).toList()),
                ),
              if (_selectedBook != null) ...[
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_selectedBook!.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                    Text(_selectedBook!.author, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ]),
                  IconButton(icon: const Icon(LucideIcons.x, size: 18), onPressed: () => setState(() { _selectedBook = null; _selectedCopy = null; })),
                ]),
                const SizedBox(height: 12),
                Text('Copias Disponibles (${_availableCopies.length})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                const SizedBox(height: 8),
                if (_availableCopies.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: const Color(0xFFF9FAFB),
                        child: const Row(children: [
                          Expanded(flex: 2, child: Text('ID COPIA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
                          Expanded(flex: 3, child: Text('UBICACION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
                          Expanded(flex: 2, child: Text('ESTADO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
                          Expanded(flex: 2, child: SizedBox()),
                        ]),
                      ),
                      ..._availableCopies.map((c) => Container(
                        color: _selectedCopy?.id == c.id ? const Color(0xFFF0FDF4) : null,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(children: [
                          Expanded(flex: 2, child: Text(c.id, style: const TextStyle(fontSize: 13, color: Color(0xFF111827)))),
                          Expanded(flex: 3, child: Text(c.location, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
                          Expanded(flex: 2, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(20)),
                            child: const Text('Disponible', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF059669))),
                          )),
                          Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child:
                            _selectedCopy?.id == c.id
                              ? ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero), child: const Text('Seleccionado', style: TextStyle(fontSize: 12)))
                              : OutlinedButton(onPressed: () => setState(() => _selectedCopy = c), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero), child: const Text('Seleccionar', style: TextStyle(fontSize: 12))),
                          )),
                        ]),
                      )),
                    ]),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                    child: Column(children: [
                      const Text('No hay copias disponibles', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: () {}, child: const Text('Agregar a lista de espera', style: TextStyle(fontSize: 12))),
                    ]),
                  ),
              ],
              if (_selectedBook == null) ...[
                const SizedBox(height: 32),
                Center(child: Column(children: const [
                  Icon(LucideIcons.bookOpen, size: 48, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 8),
                  Text('Busca y selecciona un libro', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ])),
              ],
            ]),
          )),
        ]),

        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: () => context.go('/loans'), child: const Text('Cancelar')),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: canSubmit ? _showConfirmDialog : null,
            style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB)),
            child: const Text('Registrar Prestamo'),
          ),
        ]),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
    ]),
  );
}
