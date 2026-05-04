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
}

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
}

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
}

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
}

enum FineStatus { pending, paid }
extension FineStatusExtension on FineStatus {
  String get label {
    switch (this) {
      case FineStatus.pending: return 'Pendiente';
      case FineStatus.paid:    return 'Pagado';
    }
  }
}

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
}

class WaitlistEntry {
  final String id, bookIsbn, bookTitle, userId, userName;
  final DateTime requestDate;
  final int position;
  const WaitlistEntry({
    required this.id, required this.bookIsbn, required this.bookTitle,
    required this.userId, required this.userName, required this.requestDate,
    required this.position,
  });
}

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
}

class DashboardStats {
  final int totalBooks, totalCopies, activeLoans, overdueBooks;
  const DashboardStats({
    required this.totalBooks, required this.totalCopies,
    required this.activeLoans, required this.overdueBooks,
  });
}
