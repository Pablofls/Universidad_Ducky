import 'models/models.dart';

class MockData {
  static const dashboardStats = DashboardStats(
    totalBooks: 18, totalCopies: 102, activeLoans: 15, overdueBooks: 3,
  );

  static const loanTrend = [
    {'month': 'Oct', 'loans': 45}, {'month': 'Nov', 'loans': 52},
    {'month': 'Dic', 'loans': 38}, {'month': 'Ene', 'loans': 61},
    {'month': 'Feb', 'loans': 55}, {'month': 'Mar', 'loans': 48},
  ];

  static const categoryDistribution = [
    {'name': 'Ciencias de la Computacion', 'value': 35},
    {'name': 'Ingenieria de Software',      'value': 25},
    {'name': 'Bases de Datos',              'value': 15},
    {'name': 'Gestion de TI',              'value': 10},
    {'name': 'Otros',                       'value': 15},
  ];

  static final List<Book> books = [
    const Book(isbn: '978-0134685991', title: 'Effective Java',                       author: 'Joshua Bloch',          publisher: 'Addison-Wesley',      year: 2018, topic: 'Ciencias de la Computacion', section: 'Programacion',           price: 45.99, totalCopies: 5, availableCopies: 3),
    const Book(isbn: '978-0596517748', title: 'JavaScript: The Good Parts',           author: 'Douglas Crockford',     publisher: "O'Reilly Media",      year: 2008, topic: 'Ciencias de la Computacion', section: 'Programacion',           price: 32.50, totalCopies: 3, availableCopies: 1),
    const Book(isbn: '978-0321125217', title: 'Domain-Driven Design',                 author: 'Eric Evans',            publisher: 'Addison-Wesley',      year: 2003, topic: 'Ingenieria de Software',      section: 'Ingenieria',             price: 54.99, totalCopies: 4, availableCopies: 2),
    const Book(isbn: '978-0262033848', title: 'Introduction to Algorithms',           author: 'Thomas H. Cormen',      publisher: 'MIT Press',           year: 2009, topic: 'Ciencias de la Computacion', section: 'Algoritmos',             price: 89.99, totalCopies: 8, availableCopies: 5),
    const Book(isbn: '978-0134494166', title: 'Clean Architecture',                   author: 'Robert C. Martin',      publisher: 'Prentice Hall',       year: 2017, topic: 'Ingenieria de Software',      section: 'Ingenieria',             price: 42.00, totalCopies: 6, availableCopies: 4),
    const Book(isbn: '978-1449355739', title: 'Designing Data-Intensive Applications',author: 'Martin Kleppmann',      publisher: "O'Reilly Media",      year: 2017, topic: 'Sistemas de Bases de Datos', section: 'Bases de Datos',         price: 62.50, totalCopies: 4, availableCopies: 0),
    const Book(isbn: '978-0201633610', title: 'Design Patterns',                      author: 'Erich Gamma',           publisher: 'Addison-Wesley',      year: 1994, topic: 'Ingenieria de Software',      section: 'Ingenieria',             price: 49.99, totalCopies: 5, availableCopies: 3),
    const Book(isbn: '978-0137081073', title: 'The Pragmatic Programmer',             author: 'David Thomas',          publisher: 'Addison-Wesley',      year: 2019, topic: 'Ingenieria de Software',      section: 'Ingenieria',             price: 38.75, totalCopies: 7, availableCopies: 6),
    const Book(isbn: '978-0596007126', title: 'Head First Design Patterns',           author: 'Eric Freeman',          publisher: "O'Reilly Media",      year: 2004, topic: 'Ingenieria de Software',      section: 'Ingenieria',             price: 44.50, totalCopies: 3, availableCopies: 2),
    const Book(isbn: '978-0135957059', title: 'The Phoenix Project',                  author: 'Gene Kim',              publisher: 'IT Revolution Press', year: 2013, topic: 'Gestion de TI',              section: 'Gestion',                price: 28.99, totalCopies: 4, availableCopies: 1),
    const Book(isbn: '978-0-13-468599-1', title: 'Fundamentos de Programacion',       author: 'Luis Joyanes Aguilar',  publisher: 'McGraw-Hill',         year: 2008, topic: 'Ciencias de la Computacion', section: 'Programacion',           price: 52.00, totalCopies: 6, availableCopies: 4),
    const Book(isbn: '978-607-15-0349-0', title: 'Calculo Diferencial',               author: 'Granville',             publisher: 'Limusa',              year: 2010, topic: 'Matematicas',                section: 'Matematicas',            price: 38.00, totalCopies: 8, availableCopies: 6),
    const Book(isbn: '978-0-262-03384-8', title: 'Inteligencia Artificial Moderna',   author: 'Stuart Russell',        publisher: 'Pearson',             year: 2020, topic: 'Ciencias de la Computacion', section: 'Inteligencia Artificial', price: 95.00, totalCopies: 3, availableCopies: 0),
    const Book(isbn: '978-0-321-75640-4', title: 'Fisica Universitaria Vol. 1',       author: 'Sears y Zemansky',      publisher: 'Pearson',             year: 2013, topic: 'Fisica',                     section: 'Ciencias',               price: 68.00, totalCopies: 10, availableCopies: 7),
    const Book(isbn: '978-607-15-0567-8', title: 'Quimica Organica',                  author: 'Morrison y Boyd',       publisher: 'Pearson',             year: 2015, topic: 'Quimica',                    section: 'Ciencias',               price: 72.00, totalCopies: 5, availableCopies: 3),
    const Book(isbn: '978-968-18-6071-5', title: 'Historia Universal Contemporanea',  author: 'Gloria M. Delgado',     publisher: 'Pearson',             year: 2006, topic: 'Historia',                   section: 'Humanidades',            price: 42.00, totalCopies: 7, availableCopies: 5),
    const Book(isbn: '978-970-10-6104-6', title: 'Estructuras de Datos en Java',      author: 'Mark Allen Weiss',      publisher: 'Pearson',             year: 2012, topic: 'Ciencias de la Computacion', section: 'Programacion',           price: 58.00, totalCopies: 5, availableCopies: 3),
    const Book(isbn: '978-607-32-1444-4', title: 'Algebra Lineal',                    author: 'Stanley I. Grossman',   publisher: 'McGraw-Hill',         year: 2014, topic: 'Matematicas',                section: 'Matematicas',            price: 48.00, totalCopies: 9, availableCopies: 6),
  ];

  static final List<AppUser> users = [
    AppUser(id: 'U001', name: 'Emily Johnson',       email: 'emily.johnson@university.edu',  role: AppUserRole.student,       isActive: true,  createdAt: DateTime(2024, 1, 14)),
    AppUser(id: 'U002', name: 'Dr. Michael Chen',    email: 'm.chen@university.edu',         role: AppUserRole.professor,     isActive: true,  createdAt: DateTime(2023, 9, 1)),
    AppUser(id: 'U003', name: 'Sarah Williams',      email: 's.williams@university.edu',     role: AppUserRole.librarian,     isActive: true,  createdAt: DateTime(2023, 3, 10)),
    AppUser(id: 'U004', name: 'James Rodriguez',     email: 'j.rodriguez@university.edu',    role: AppUserRole.student,       isActive: true,  createdAt: DateTime(2024, 8, 20)),
    AppUser(id: 'U005', name: 'Dr. Lisa Anderson',   email: 'l.anderson@university.edu',     role: AppUserRole.professor,     isActive: true,  createdAt: DateTime(2022, 9, 1)),
    AppUser(id: 'U006', name: 'Robert Taylor',       email: 'r.taylor@university.edu',       role: AppUserRole.student,       isActive: false, createdAt: DateTime(2024, 8, 20)),
    AppUser(id: 'U007', name: 'Maria Garcia',        email: 'm.garcia@university.edu',       role: AppUserRole.administrator, isActive: true,  createdAt: DateTime(2021, 1, 1)),
    AppUser(id: 'U008', name: 'David Kim',           email: 'd.kim@university.edu',          role: AppUserRole.student,       isActive: true,  createdAt: DateTime(2024, 8, 20)),
    AppUser(id: 'student-001', name: 'Maria Garcia Lopez',   email: 'm.garcial@ducky.edu',  role: AppUserRole.student,       isActive: true,  createdAt: DateTime(2024, 8, 20)),
    AppUser(id: 'student-002', name: 'Carlos Rodriguez Perez', email: 'c.rodriguez@ducky.edu', role: AppUserRole.student,    isActive: true,  createdAt: DateTime(2024, 8, 20)),
    AppUser(id: 'professor-001', name: 'Dr. Juan Martinez',  email: 'j.martinez@ducky.edu', role: AppUserRole.professor,     isActive: true,  createdAt: DateTime(2022, 9, 1)),
  ];

  static final List<BookCopy> copies = [
    BookCopy(id: 'C001', isbn: '978-0134685991', bookTitle: 'Effective Java',               status: CopyStatus.available, location: 'Seccion A, Estante 3, Fila 2', condition: 'Bueno',   acquisitionDate: DateTime(2020, 1, 1)),
    BookCopy(id: 'C002', isbn: '978-0134685991', bookTitle: 'Effective Java',               status: CopyStatus.borrowed,  location: 'Seccion A, Estante 3, Fila 2', condition: 'Bueno',   acquisitionDate: DateTime(2020, 1, 1)),
    BookCopy(id: 'C003', isbn: '978-0134685991', bookTitle: 'Effective Java',               status: CopyStatus.available, location: 'Seccion A, Estante 3, Fila 2', condition: 'Regular', acquisitionDate: DateTime(2021, 3, 1)),
    BookCopy(id: 'C004', isbn: '978-0596517748', bookTitle: 'JavaScript: The Good Parts',   status: CopyStatus.available, location: 'Seccion A, Estante 5, Fila 1', condition: 'Bueno',   acquisitionDate: DateTime(2020, 6, 1)),
    BookCopy(id: 'C005', isbn: '978-0596517748', bookTitle: 'JavaScript: The Good Parts',   status: CopyStatus.borrowed,  location: 'Seccion A, Estante 5, Fila 1', condition: 'Bueno',   acquisitionDate: DateTime(2020, 6, 1)),
    BookCopy(id: 'C006', isbn: '978-0321125217', bookTitle: 'Domain-Driven Design',         status: CopyStatus.reserved,  location: 'Seccion B, Estante 2, Fila 3', condition: 'Nuevo',   acquisitionDate: DateTime(2022, 1, 1)),
    BookCopy(id: 'C007', isbn: '978-0321125217', bookTitle: 'Domain-Driven Design',         status: CopyStatus.available, location: 'Seccion B, Estante 2, Fila 3', condition: 'Bueno',   acquisitionDate: DateTime(2022, 1, 1)),
    BookCopy(id: 'C008', isbn: '978-0262033848', bookTitle: 'Introduction to Algorithms',   status: CopyStatus.available, location: 'Seccion A, Estante 1, Fila 1', condition: 'Bueno',   acquisitionDate: DateTime(2021, 5, 1)),
    BookCopy(id: 'C009', isbn: '978-0262033848', bookTitle: 'Introduction to Algorithms',   status: CopyStatus.borrowed,  location: 'Seccion A, Estante 1, Fila 1', condition: 'Regular', acquisitionDate: DateTime(2021, 5, 1)),
    BookCopy(id: 'C010', isbn: '978-0134494166', bookTitle: 'Clean Architecture',           status: CopyStatus.internal,  location: 'Sala de Referencia, Estante 1', condition: 'Nuevo',  acquisitionDate: DateTime(2023, 2, 1)),
    BookCopy(id: 'COPY-001', isbn: '978-0-13-468599-1', bookTitle: 'Fundamentos de Programacion', status: CopyStatus.available, location: 'Seccion B, Estante 4, Fila 1', condition: 'Bueno', acquisitionDate: DateTime(2021, 1, 1)),
    BookCopy(id: 'COPY-002', isbn: '978-0201633610', bookTitle: 'Design Patterns',          status: CopyStatus.available, location: 'Seccion B, Estante 3, Fila 2', condition: 'Bueno',   acquisitionDate: DateTime(2020, 8, 1)),
    BookCopy(id: 'COPY-003', isbn: '978-0201633610', bookTitle: 'Design Patterns',          status: CopyStatus.borrowed,  location: 'Seccion B, Estante 3, Fila 2', condition: 'Regular', acquisitionDate: DateTime(2020, 8, 1)),
  ];

  static final List<Loan> loans = [
    Loan(id: 'L001', userId: 'U001', userName: 'Emily Johnson', copyId: 'C002', bookTitle: 'Effective Java',            bookIsbn: '978-0134685991', loanDate: DateTime(2026, 2, 19), dueDate: DateTime(2026, 3, 19), status: LoanStatus.active,  renewalCount: 0),
    Loan(id: 'L002', userId: 'U001', userName: 'Emily Johnson', copyId: 'C005', bookTitle: 'JavaScript: The Good Parts', bookIsbn: '978-0596517748', loanDate: DateTime(2026, 2, 14), dueDate: DateTime(2026, 3, 14), status: LoanStatus.active,  renewalCount: 0),
    Loan(id: 'L003', userId: 'U001', userName: 'Emily Johnson', copyId: 'C009', bookTitle: 'Introduction to Algorithms', bookIsbn: '978-0262033848', loanDate: DateTime(2026, 1, 29), dueDate: DateTime(2026, 2, 28), status: LoanStatus.overdue, renewalCount: 0),
    Loan(id: 'L004', userId: 'U004', userName: 'James Rodriguez', copyId: 'C004', bookTitle: 'JavaScript: The Good Parts', bookIsbn: '978-0596517748', loanDate: DateTime(2026, 3, 1), dueDate: DateTime(2026, 3, 31), status: LoanStatus.active, renewalCount: 0),
  ];

  static final List<PurchaseRequest> purchaseRequests = [
    PurchaseRequest(id: 'PR-001', isbn: '978-0134494166', bookTitle: 'Clean Architecture',  requestedBy: 'Sarah Williams',    quantity: 3, justification: 'Alta demanda.', status: PurchaseStatus.pending,  createdAt: DateTime(2026, 3, 20)),
    PurchaseRequest(id: 'PR-002', isbn: '978-1449355739', bookTitle: 'Designing Data-Intensive Applications', requestedBy: 'Dr. Michael Chen', quantity: 2, justification: 'Material de apoyo.', status: PurchaseStatus.approved, createdAt: DateTime(2026, 3, 10), reviewedBy: 'Maria Garcia', reviewNotes: 'Aprobado.'),
  ];
}
