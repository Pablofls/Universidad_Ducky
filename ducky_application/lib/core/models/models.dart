// ─────────────────────────────────────────────────────────────────────────────
// Helpers for enum parsing & safe numeric conversion
// ─────────────────────────────────────────────────────────────────────────────
T _enumFromString<T extends Enum>(List<T> values, String value) =>
    values.firstWhere((e) => e.name == value);

/// Safely convert a JSON value (num or String) to double.
/// PostgreSQL NUMERIC fields arrive as String via psycopg2.
double _toDouble(dynamic v) => v is num ? v.toDouble() : double.parse(v.toString());
double? _toDoubleOrNull(dynamic v) => v == null ? null : _toDouble(v);

// ─────────────────────────────────────────────────────────────────────────────
// Book
// ─────────────────────────────────────────────────────────────────────────────
class Book {
  final String isbn, title, author, publisher;
  final int year;
  final String topic, section;
  final double price;
  final String? description, imageUrl;
  final int totalCopies, availableCopies;

  const Book({
    required this.isbn, required this.title, required this.author,
    required this.publisher, required this.year, required this.topic,
    required this.section, required this.price,
    this.description, this.imageUrl,
    required this.totalCopies, required this.availableCopies,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    isbn:            json['isbn'] as String,
    title:           json['title'] as String,
    author:          json['author'] as String,
    publisher:       json['publisher'] as String,
    year:            json['year'] as int,
    topic:           json['topic'] as String,
    section:         json['section'] as String,
    price:           _toDouble(json['price']),
    description:     json['description'] as String?,
    imageUrl:        json['image_url'] as String?,
    totalCopies:     json['total_copies'] as int,
    availableCopies: json['available_copies'] as int,
  );

  Map<String, dynamic> toJson() => {
    'isbn':             isbn,
    'title':            title,
    'author':           author,
    'publisher':        publisher,
    'year':             year,
    'topic':            topic,
    'section':          section,
    'price':            price,
    'description':      description,
    'image_url':        imageUrl,
    'total_copies':     totalCopies,
    'available_copies': availableCopies,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// CopyStatus
// ─────────────────────────────────────────────────────────────────────────────
enum CopyStatus { available, borrowed, reserved, internal, damaged, lost }
extension CopyStatusExtension on CopyStatus {
  String get label {
    switch (this) {
      case CopyStatus.available: return 'Disponible';
      case CopyStatus.borrowed:  return 'Prestado';
      case CopyStatus.reserved:  return 'Reservado';
      case CopyStatus.internal:  return 'Uso Interno';
      case CopyStatus.damaged:   return 'Danado';
      case CopyStatus.lost:      return 'Perdido';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BookCopy
// ─────────────────────────────────────────────────────────────────────────────
class BookCopy {
  final String id, isbn, bookTitle;
  final CopyStatus status;
  final String location, condition;
  final String? notes;
  final DateTime acquisitionDate;

  const BookCopy({
    required this.id, required this.isbn, required this.bookTitle,
    required this.status, required this.location, required this.condition,
    this.notes, required this.acquisitionDate,
  });

  factory BookCopy.fromJson(Map<String, dynamic> json) => BookCopy(
    id:              json['id'] as String,
    isbn:            json['isbn'] as String,
    bookTitle:       json['book_title'] as String,
    status:          _enumFromString(CopyStatus.values, json['status'] as String),
    location:        json['location'] as String,
    condition:       json['condition'] as String,
    notes:           json['notes'] as String?,
    acquisitionDate: DateTime.parse(json['acquisition_date'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id':               id,
    'isbn':             isbn,
    'book_title':       bookTitle,
    'status':           status.name,
    'location':         location,
    'condition':        condition,
    'notes':            notes,
    'acquisition_date': acquisitionDate.toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// AppUserRole
// ─────────────────────────────────────────────────────────────────────────────
enum AppUserRole { administrator, librarian, student, professor }
extension AppUserRoleExtension on AppUserRole {
  String get label {
    switch (this) {
      case AppUserRole.administrator: return 'Administrador';
      case AppUserRole.librarian:     return 'Bibliotecario';
      case AppUserRole.student:       return 'Estudiante';
      case AppUserRole.professor:     return 'Profesor';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppUser
// ─────────────────────────────────────────────────────────────────────────────
class AppUser {
  final String id, name, email;
  final AppUserRole role;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  const AppUser({
    required this.id, required this.name, required this.email,
    required this.role, this.phone, required this.isActive,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id:        json['id'] as String,
    name:      json['name'] as String,
    email:     json['email'] as String,
    role:      _enumFromString(AppUserRole.values, json['role'] as String),
    phone:     json['phone'] as String?,
    isActive:  json['is_active'] as bool,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'email':      email,
    'role':       role.name,
    'phone':      phone,
    'is_active':  isActive,
    'created_at': createdAt.toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// LoanStatus
// ─────────────────────────────────────────────────────────────────────────────
enum LoanStatus { active, overdue, returned }
extension LoanStatusExtension on LoanStatus {
  String get label {
    switch (this) {
      case LoanStatus.active:   return 'Activo';
      case LoanStatus.overdue:  return 'Atrasado';
      case LoanStatus.returned: return 'Devuelto';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loan
// ─────────────────────────────────────────────────────────────────────────────
class Loan {
  final String id, userId, userName, copyId, bookTitle, bookIsbn;
  final double bookPrice;
  final DateTime loanDate, dueDate;
  final DateTime? returnDate;
  final LoanStatus status;
  final double? fine;
  final int renewalCount;

  const Loan({
    required this.id, required this.userId, required this.userName,
    required this.copyId, required this.bookTitle, required this.bookIsbn,
    required this.bookPrice,
    required this.loanDate, required this.dueDate, this.returnDate,
    required this.status, this.fine, this.renewalCount = 0,
  });

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id:           json['id'] as String,
    userId:       json['user_id'] as String,
    userName:     json['user_name'] as String,
    copyId:       json['copy_id'] as String,
    bookTitle:    json['book_title'] as String,
    bookIsbn:     json['book_isbn'] as String,
    bookPrice:    _toDouble(json['book_price']),
    loanDate:     DateTime.parse(json['loan_date'] as String),
    dueDate:      DateTime.parse(json['due_date'] as String),
    returnDate:   json['return_date'] != null
        ? DateTime.parse(json['return_date'] as String)
        : null,
    status:       _enumFromString(LoanStatus.values, json['status'] as String),
    fine:         _toDoubleOrNull(json['fine']),
    renewalCount: json['renewal_count'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id':            id,
    'user_id':       userId,
    'user_name':     userName,
    'copy_id':       copyId,
    'book_title':    bookTitle,
    'book_isbn':     bookIsbn,
    'book_price':    bookPrice,
    'loan_date':     loanDate.toIso8601String(),
    'due_date':      dueDate.toIso8601String(),
    'return_date':   returnDate?.toIso8601String(),
    'status':        status.name,
    'fine':          fine,
    'renewal_count': renewalCount,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// FineStatus
// ─────────────────────────────────────────────────────────────────────────────
enum FineStatus { pending, paid }
extension FineStatusExtension on FineStatus {
  String get label {
    switch (this) {
      case FineStatus.pending: return 'Pendiente';
      case FineStatus.paid:    return 'Pagado';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fine
// ─────────────────────────────────────────────────────────────────────────────
class Fine {
  final String id, userId, userName, loanId, bookTitle;
  final int daysOverdue;
  final double amount;
  final FineStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;

  const Fine({
    required this.id, required this.userId, required this.userName,
    required this.loanId, required this.bookTitle, required this.daysOverdue,
    required this.amount, required this.status, required this.createdAt,
    this.paidAt,
  });

  factory Fine.fromJson(Map<String, dynamic> json) => Fine(
    id:          json['id'] as String,
    userId:      json['user_id'] as String,
    userName:    json['user_name'] as String,
    loanId:      json['loan_id'] as String,
    bookTitle:   json['book_title'] as String,
    daysOverdue: json['days_overdue'] as int,
    amount:      _toDouble(json['amount']),
    status:      _enumFromString(FineStatus.values, json['status'] as String),
    createdAt:   DateTime.parse(json['created_at'] as String),
    paidAt:      json['paid_at'] != null
        ? DateTime.parse(json['paid_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id':           id,
    'user_id':      userId,
    'user_name':    userName,
    'loan_id':      loanId,
    'book_title':   bookTitle,
    'days_overdue': daysOverdue,
    'amount':       amount,
    'status':       status.name,
    'created_at':   createdAt.toIso8601String(),
    'paid_at':      paidAt?.toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// WaitlistEntry
// ─────────────────────────────────────────────────────────────────────────────
class WaitlistEntry {
  final String id, bookIsbn, bookTitle, userId, userName;
  final DateTime requestDate;
  final int position;

  const WaitlistEntry({
    required this.id, required this.bookIsbn, required this.bookTitle,
    required this.userId, required this.userName, required this.requestDate,
    required this.position,
  });

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) => WaitlistEntry(
    id:          json['id'] as String,
    bookIsbn:    json['book_isbn'] as String,
    bookTitle:   json['book_title'] as String,
    userId:      json['user_id'] as String,
    userName:    json['user_name'] as String,
    requestDate: DateTime.parse(json['request_date'] as String),
    position:    json['position'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id':           id,
    'book_isbn':    bookIsbn,
    'book_title':   bookTitle,
    'user_id':      userId,
    'user_name':    userName,
    'request_date': requestDate.toIso8601String(),
    'position':     position,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// PurchaseStatus
// ─────────────────────────────────────────────────────────────────────────────
enum PurchaseStatus { pending, approved, rejected, purchased }
extension PurchaseStatusExtension on PurchaseStatus {
  String get label {
    switch (this) {
      case PurchaseStatus.pending:   return 'Pendiente';
      case PurchaseStatus.approved:  return 'Aprobado';
      case PurchaseStatus.rejected:  return 'Rechazado';
      case PurchaseStatus.purchased: return 'Comprado';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PurchaseRequest
// ─────────────────────────────────────────────────────────────────────────────
class PurchaseRequest {
  final String id, isbn, bookTitle, author, requestedBy, justification;
  final int quantity;
  final double unitPrice;
  final PurchaseStatus status;
  final DateTime createdAt;
  final String? reviewedBy, reviewNotes;

  const PurchaseRequest({
    required this.id, required this.isbn, required this.bookTitle,
    required this.author, required this.requestedBy, required this.quantity,
    required this.unitPrice, required this.justification,
    required this.status, required this.createdAt,
    this.reviewedBy, this.reviewNotes,
  });

  double get total => quantity * unitPrice;

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) => PurchaseRequest(
    id:            json['id'] as String,
    isbn:          json['isbn'] as String,
    bookTitle:     json['book_title'] as String,
    author:        json['author'] as String,
    requestedBy:   json['requested_by'] as String,
    quantity:      json['quantity'] as int,
    unitPrice:     _toDouble(json['unit_price']),
    justification: json['justification'] as String,
    status:        _enumFromString(PurchaseStatus.values, json['status'] as String),
    createdAt:     DateTime.parse(json['created_at'] as String),
    reviewedBy:    json['reviewed_by'] as String?,
    reviewNotes:   json['review_notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id':            id,
    'isbn':          isbn,
    'book_title':    bookTitle,
    'author':        author,
    'requested_by':  requestedBy,
    'quantity':      quantity,
    'unit_price':    unitPrice,
    'total':         total,
    'justification': justification,
    'status':        status.name,
    'created_at':    createdAt.toIso8601String(),
    'reviewed_by':   reviewedBy,
    'review_notes':  reviewNotes,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardStats
// ─────────────────────────────────────────────────────────────────────────────
class DashboardStats {
  final int totalBooks, totalCopies, activeLoans, overdueBooks;
  final List<Map<String, dynamic>> loanTrend;
  final List<Map<String, dynamic>> topicDistribution;

  const DashboardStats({
    required this.totalBooks, required this.totalCopies,
    required this.activeLoans, required this.overdueBooks,
    this.loanTrend = const [],
    this.topicDistribution = const [],
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    totalBooks:   json['total_books'] as int,
    totalCopies:  json['total_copies'] as int,
    activeLoans:  json['active_loans'] as int,
    overdueBooks: json['overdue_books'] as int,
    loanTrend: (json['loan_trend'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [],
    topicDistribution: (json['topic_distribution'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'total_books':   totalBooks,
    'total_copies':  totalCopies,
    'active_loans':  activeLoans,
    'overdue_books': overdueBooks,
    'loan_trend':    loanTrend,
    'topic_distribution': topicDistribution,
  };
}
