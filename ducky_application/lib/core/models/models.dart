// ═══════════════════════════════════════════════════════════════════════════
//  lib/core/models/models.dart
//  Modelos de dominio — equivalente a los tipos TypeScript del prototipo.
//  Cuando conectes la BD, agrega los constructores fromJson / toJson.
// ═══════════════════════════════════════════════════════════════════════════

// ── Book ──────────────────────────────────────────────────────────────────────
class Book {
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final int year;
  final String topic;
  final String? description;
  final String? imageUrl;
  final int totalCopies;
  final int availableCopies;

  const Book({
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    required this.year,
    required this.topic,
    this.description,
    this.imageUrl,
    required this.totalCopies,
    required this.availableCopies,
  });

  // TODO: factory Book.fromJson(Map<String, dynamic> json) => ...
}

// ── Copy (Ejemplar) ───────────────────────────────────────────────────────────
enum CopyStatus { available, borrowed, damaged, lost }

extension CopyStatusExtension on CopyStatus {
  String get label {
    switch (this) {
      case CopyStatus.available: return 'Disponible';
      case CopyStatus.borrowed:  return 'Prestado';
      case CopyStatus.damaged:   return 'Dañado';
      case CopyStatus.lost:      return 'Perdido';
    }
  }
}

class BookCopy {
  final String id;
  final String isbn;
  final String bookTitle;
  final CopyStatus status;
  final String location;
  final String? notes;
  final DateTime acquisitionDate;

  const BookCopy({
    required this.id,
    required this.isbn,
    required this.bookTitle,
    required this.status,
    required this.location,
    this.notes,
    required this.acquisitionDate,
  });
}

// ── User ──────────────────────────────────────────────────────────────────────
enum AppUserRole { administrator, librarian, student, professor }

extension AppUserRoleExtension on AppUserRole {
  String get label {
    switch (this) {
      case AppUserRole.administrator: return 'Administrador';
      case AppUserRole.librarian:     return 'Bibliotecario';
      case AppUserRole.student:       return 'Alumno';
      case AppUserRole.professor:     return 'Profesor';
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final AppUserRole role;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });
}

// ── Loan (Préstamo) ───────────────────────────────────────────────────────────
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
  final String id;
  final String userId;
  final String userName;
  final String copyId;
  final String bookTitle;
  final String bookIsbn;
  final DateTime loanDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final LoanStatus status;
  final double? fine;
  final int renewalCount;

  const Loan({
    required this.id,
    required this.userId,
    required this.userName,
    required this.copyId,
    required this.bookTitle,
    required this.bookIsbn,
    required this.loanDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
    this.fine,
    this.renewalCount = 0,
  });
}

// ── PurchaseRequest (Solicitud de compra) ─────────────────────────────────────
enum PurchaseStatus { pending, approved, rejected }

extension PurchaseStatusExtension on PurchaseStatus {
  String get label {
    switch (this) {
      case PurchaseStatus.pending:  return 'Pendiente';
      case PurchaseStatus.approved: return 'Aprobada';
      case PurchaseStatus.rejected: return 'Rechazada';
    }
  }
}

class PurchaseRequest {
  final String id;
  final String isbn;
  final String bookTitle;
  final String requestedBy;
  final int quantity;
  final String justification;
  final PurchaseStatus status;
  final DateTime createdAt;
  final String? reviewedBy;
  final String? reviewNotes;

  const PurchaseRequest({
    required this.id,
    required this.isbn,
    required this.bookTitle,
    required this.requestedBy,
    required this.quantity,
    required this.justification,
    required this.status,
    required this.createdAt,
    this.reviewedBy,
    this.reviewNotes,
  });
}

// ── Dashboard Stats ───────────────────────────────────────────────────────────
class DashboardStats {
  final int totalBooks;
  final int totalCopies;
  final int activeLoans;
  final int overdueBooks;

  const DashboardStats({
    required this.totalBooks,
    required this.totalCopies,
    required this.activeLoans,
    required this.overdueBooks,
  });
}
