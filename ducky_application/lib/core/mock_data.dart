// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/mock_data.dart
//  Datos de prueba — se reemplazarán por llamadas a la BD.
// ═══════════════════════════════════════════════════════════════════════════

import 'models/models.dart';

class MockData {
  // ── Dashboard ───────────────────────────────────────────────────────────
  static const DashboardStats dashboardStats = DashboardStats(
    totalBooks: 248,
    totalCopies: 612,
    activeLoans: 43,
    overdueBooks: 7,
  );

  static const List<Map<String, dynamic>> loanTrend = [
    {'month': 'Oct', 'loans': 45},
    {'month': 'Nov', 'loans': 52},
    {'month': 'Dic', 'loans': 38},
    {'month': 'Ene', 'loans': 61},
    {'month': 'Feb', 'loans': 55},
    {'month': 'Mar', 'loans': 48},
  ];

  static const List<Map<String, dynamic>> categoryDistribution = [
    {'name': 'Ciencias de la Computación', 'value': 35},
    {'name': 'Ing. de Software',            'value': 25},
    {'name': 'Bases de Datos',              'value': 15},
    {'name': 'Gestión de TI',              'value': 10},
    {'name': 'Otros',                       'value': 15},
  ];

  // ── Books ───────────────────────────────────────────────────────────────
  static final List<Book> books = [
    const Book(
      isbn: '978-0-13-110362-7',
      title: 'The C Programming Language',
      author: 'Brian W. Kernighan, Dennis M. Ritchie',
      publisher: 'Prentice Hall',
      year: 1988,
      topic: 'Ciencias de la Computación',
      description: 'El libro de referencia definitivo para el lenguaje C.',
      totalCopies: 5,
      availableCopies: 3,
    ),
    const Book(
      isbn: '978-0-201-63361-0',
      title: 'Design Patterns',
      author: 'Gang of Four',
      publisher: 'Addison-Wesley',
      year: 1994,
      topic: 'Ingeniería de Software',
      description: 'Patrones de diseño reutilizables en software orientado a objetos.',
      totalCopies: 4,
      availableCopies: 2,
    ),
    const Book(
      isbn: '978-0-13-468599-1',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      publisher: 'Prentice Hall',
      year: 2008,
      topic: 'Ingeniería de Software',
      description: 'Guía para escribir código limpio y mantenible.',
      totalCopies: 6,
      availableCopies: 4,
    ),
    const Book(
      isbn: '978-0-07-352332-3',
      title: 'Database System Concepts',
      author: 'Abraham Silberschatz',
      publisher: 'McGraw-Hill',
      year: 2019,
      topic: 'Bases de Datos',
      description: 'Fundamentos de sistemas de bases de datos.',
      totalCopies: 3,
      availableCopies: 1,
    ),
    const Book(
      isbn: '978-0-13-235088-4',
      title: 'Introduction to Algorithms',
      author: 'Thomas H. Cormen',
      publisher: 'MIT Press',
      year: 2009,
      topic: 'Ciencias de la Computación',
      description: 'Referencia comprensiva de algoritmos y estructuras de datos.',
      totalCopies: 4,
      availableCopies: 0,
    ),
    const Book(
      isbn: '978-1-491-95038-9',
      title: 'Fluent Python',
      author: 'Luciano Ramalho',
      publisher: "O'Reilly",
      year: 2022,
      topic: 'Ciencias de la Computación',
      description: 'Python idiomático y de alto rendimiento.',
      totalCopies: 3,
      availableCopies: 2,
    ),
  ];

  // ── Users ───────────────────────────────────────────────────────────────
  static final List<AppUser> users = [
    AppUser(
      id: 'admin-001',
      name: 'Ana García',
      email: 'ana.garcia@ducky.edu',
      role: AppUserRole.administrator,
      phone: '555-0001',
      isActive: true,
      createdAt: DateTime(2023, 1, 15),
    ),
    AppUser(
      id: 'lib-001',
      name: 'Carlos Mendoza',
      email: 'carlos.mendoza@ducky.edu',
      role: AppUserRole.librarian,
      phone: '555-0002',
      isActive: true,
      createdAt: DateTime(2023, 3, 10),
    ),
    AppUser(
      id: 'student-001',
      name: 'María López',
      email: 'maria.lopez@ducky.edu',
      role: AppUserRole.student,
      isActive: true,
      createdAt: DateTime(2024, 8, 20),
    ),
    AppUser(
      id: 'student-002',
      name: 'Juan Pérez',
      email: 'juan.perez@ducky.edu',
      role: AppUserRole.student,
      isActive: true,
      createdAt: DateTime(2024, 8, 20),
    ),
    AppUser(
      id: 'prof-001',
      name: 'Dr. Roberto Silva',
      email: 'roberto.silva@ducky.edu',
      role: AppUserRole.professor,
      phone: '555-0010',
      isActive: true,
      createdAt: DateTime(2022, 9, 1),
    ),
  ];

  // ── Copies ──────────────────────────────────────────────────────────────
  static final List<BookCopy> copies = [
    BookCopy(
      id: 'COPY-001',
      isbn: '978-0-13-110362-7',
      bookTitle: 'The C Programming Language',
      status: CopyStatus.available,
      location: 'Estante A-1',
      acquisitionDate: DateTime(2020, 3, 1),
    ),
    BookCopy(
      id: 'COPY-002',
      isbn: '978-0-13-110362-7',
      bookTitle: 'The C Programming Language',
      status: CopyStatus.borrowed,
      location: 'Estante A-1',
      acquisitionDate: DateTime(2020, 3, 1),
    ),
    BookCopy(
      id: 'COPY-003',
      isbn: '978-0-201-63361-0',
      bookTitle: 'Design Patterns',
      status: CopyStatus.available,
      location: 'Estante B-2',
      acquisitionDate: DateTime(2021, 6, 15),
    ),
    BookCopy(
      id: 'COPY-004',
      isbn: '978-0-13-468599-1',
      bookTitle: 'Clean Code',
      status: CopyStatus.damaged,
      location: 'Estante B-3',
      notes: 'Páginas dañadas por humedad',
      acquisitionDate: DateTime(2021, 1, 10),
    ),
  ];

  // ── Loans ───────────────────────────────────────────────────────────────
  static final List<Loan> loans = [
    Loan(
      id: 'LOAN-001',
      userId: 'student-001',
      userName: 'María López',
      copyId: 'COPY-002',
      bookTitle: 'The C Programming Language',
      bookIsbn: '978-0-13-110362-7',
      loanDate: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(days: 9)),
      status: LoanStatus.active,
      renewalCount: 0,
    ),
    Loan(
      id: 'LOAN-002',
      userId: 'student-002',
      userName: 'Juan Pérez',
      copyId: 'COPY-003',
      bookTitle: 'Design Patterns',
      bookIsbn: '978-0-201-63361-0',
      loanDate: DateTime.now().subtract(const Duration(days: 20)),
      dueDate: DateTime.now().subtract(const Duration(days: 6)),
      status: LoanStatus.overdue,
      fine: 12.0,
      renewalCount: 1,
    ),
  ];

  // ── Purchase Requests ───────────────────────────────────────────────────
  static final List<PurchaseRequest> purchaseRequests = [
    PurchaseRequest(
      id: 'PR-001',
      isbn: '978-0-13-468599-1',
      bookTitle: 'Clean Architecture',
      requestedBy: 'Carlos Mendoza',
      quantity: 3,
      justification: 'Alta demanda por parte de alumnos de Ingeniería de Software.',
      status: PurchaseStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PurchaseRequest(
      id: 'PR-002',
      isbn: '978-1-491-95038-9',
      bookTitle: 'Fluent Python',
      requestedBy: 'Dr. Roberto Silva',
      quantity: 2,
      justification: 'Material de apoyo para el curso de Programación Avanzada.',
      status: PurchaseStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      reviewedBy: 'Ana García',
      reviewNotes: 'Aprobado. Presupuesto disponible.',
    ),
  ];
}
