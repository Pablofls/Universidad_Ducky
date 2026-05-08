export type UserRole = "Student" | "Professor" | "Librarian" | "Administrator";
export type UserStatus = "Active" | "Inactive" | "Suspended";
export type CopyStatus = "Available" | "Loaned" | "Reserved" | "Internal Use";
export type CopyCondition = "New" | "Good" | "Fair" | "Poor" | "Damaged";
export type PurchaseRequestStatus = "Pending" | "Approved" | "Rejected" | "Purchased";
export type LoanStatus = "Active" | "Overdue" | "Returned";
export type FineStatus = "Pending" | "Paid";

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  status: UserStatus;
  createdAt: string;
  borrowedBooks?: number;
  outstandingFines?: number;
}

export interface Book {
  isbn: string;
  title: string;
  author: string;
  topic: string;
  publisher: string;
  genre?: string;
  price?: number;
  totalCopies: number;
  availableCopies: number;
  createdAt: string;
}

export interface Copy {
  id: string;
  bookIsbn: string;
  bookTitle: string;
  status: CopyStatus;
  location: string;
  condition: CopyCondition;
  createdAt: string;
}

export interface BorrowedBook {
  copyId: string;
  bookTitle: string;
  borrowDate: string;
  dueDate: string;
  status: "Active" | "Overdue";
}

export interface DashboardStats {
  totalBooks: number;
  totalCopies: number;
  activeLoans: number;
  overdueBooks: number;
}

export interface PurchaseRequest {
  id: string;
  bookIsbn?: string;
  bookTitle: string;
  author: string;
  topic: string;
  publisher: string;
  quantity: number;
  price?: number;
  justification: string;
  requestedBy: string;
  status: PurchaseRequestStatus;
  createdAt: string;
  updatedAt?: string;
  notes?: string;
}

export interface Loan {
  id: string;
  userId: string;
  userName: string;
  bookTitle: string;
  bookIsbn: string;
  bookPrice: number;
  copyId: string;
  loanDate: string;
  dueDate: string;
  returnDate?: string;
  status: LoanStatus;
  renewalCount: number;
}

export interface Fine {
  id: string;
  userId: string;
  userName: string;
  loanId: string;
  bookTitle: string;
  daysOverdue: number;
  amount: number;
  status: FineStatus;
  createdAt: string;
  paidAt?: string;
}

export interface WaitlistEntry {
  id: string;
  bookIsbn: string;
  bookTitle: string;
  userId: string;
  userName: string;
  requestDate: string;
  position: number;
}