// ─────────────────────────────────────────────────────────────────────────────
// ApiService – Typed methods for every Ducky Library API call
// ─────────────────────────────────────────────────────────────────────────────
import 'api_client.dart';
import 'models/models.dart';

class ApiService {
  static final ApiClient _api = ApiClient();

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static Future<DashboardStats> getDashboard() async {
    final data = await _api.get('/api/dashboard');
    return DashboardStats.fromJson(data as Map<String, dynamic>);
  }

  // ── Books ─────────────────────────────────────────────────────────────────
  static Future<List<Book>> getBooks({String? q, String? topic, String? section}) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (topic != null && topic.isNotEmpty) params['topic'] = topic;
    if (section != null && section.isNotEmpty) params['section'] = section;
    final data = await _api.get('/api/books', queryParams: params.isEmpty ? null : params);
    return (data as List).map((j) => Book.fromJson(j)).toList();
  }

  static Future<Book> getBook(String isbn) async {
    final data = await _api.get('/api/books/${Uri.encodeComponent(isbn)}');
    return Book.fromJson(data as Map<String, dynamic>);
  }

  static Future<Book> createBook(Map<String, dynamic> body) async {
    final data = await _api.post('/api/books', body: body);
    return Book.fromJson(data as Map<String, dynamic>);
  }

  static Future<Book> updateBook(String isbn, Map<String, dynamic> body) async {
    final data = await _api.put('/api/books/${Uri.encodeComponent(isbn)}', body: body);
    return Book.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteBook(String isbn) async {
    await _api.delete('/api/books/${Uri.encodeComponent(isbn)}');
  }

  static Future<List<Book>> searchBooksPublic({String? q, String? topic}) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (topic != null && topic.isNotEmpty) params['topic'] = topic;
    final data = await _api.get('/api/books/search', queryParams: params.isEmpty ? null : params);
    final map = data as Map<String, dynamic>;
    return (map['books'] as List).map((j) => Book.fromJson(j)).toList();
  }

  // ── Users ─────────────────────────────────────────────────────────────────
  static Future<List<AppUser>> getUsers({String? q, String? role}) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (role != null && role.isNotEmpty) params['role'] = role;
    final data = await _api.get('/api/users', queryParams: params.isEmpty ? null : params);
    return (data as List).map((j) => AppUser.fromJson(j)).toList();
  }

  static Future<AppUser> getUser(String id) async {
    final data = await _api.get('/api/users/$id');
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  static Future<AppUser> createUser(Map<String, dynamic> body) async {
    final data = await _api.post('/api/users', body: body);
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteUser(String id) async {
    await _api.delete('/api/users/$id');
  }

  // ── Copies ────────────────────────────────────────────────────────────────
  static Future<List<BookCopy>> getCopies({String? isbn, String? status}) async {
    final params = <String, String>{};
    if (isbn != null && isbn.isNotEmpty) params['isbn'] = isbn;
    if (status != null && status.isNotEmpty) params['status'] = status;
    final data = await _api.get('/api/copies', queryParams: params.isEmpty ? null : params);
    return (data as List).map((j) => BookCopy.fromJson(j)).toList();
  }

  static Future<BookCopy> getCopy(String id) async {
    final data = await _api.get('/api/copies/$id');
    return BookCopy.fromJson(data as Map<String, dynamic>);
  }

  static Future<BookCopy> createCopy(Map<String, dynamic> body) async {
    final data = await _api.post('/api/copies', body: body);
    return BookCopy.fromJson(data as Map<String, dynamic>);
  }

  // ── Loans ─────────────────────────────────────────────────────────────────
  static Future<List<Loan>> getLoans({String? status, String? userId}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (userId != null && userId.isNotEmpty) params['user_id'] = userId;
    final data = await _api.get('/api/loans', queryParams: params.isEmpty ? null : params);
    return (data as List).map((j) => Loan.fromJson(j)).toList();
  }

  static Future<Loan> getLoan(String id) async {
    final data = await _api.get('/api/loans/$id');
    return Loan.fromJson(data as Map<String, dynamic>);
  }

  static Future<Loan> createLoan(Map<String, dynamic> body) async {
    final data = await _api.post('/api/loans', body: body);
    return Loan.fromJson(data as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> returnLoan(String id) async {
    final data = await _api.post('/api/loans/$id/return');
    return data as Map<String, dynamic>;
  }

  static Future<Loan> renewLoan(String id) async {
    final data = await _api.post('/api/loans/$id/renew');
    return Loan.fromJson(data as Map<String, dynamic>);
  }

  // ── Fines ─────────────────────────────────────────────────────────────────
  static Future<List<Fine>> getFines({String? status, String? userId}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (userId != null && userId.isNotEmpty) params['user_id'] = userId;
    final data = await _api.get('/api/fines', queryParams: params.isEmpty ? null : params);
    return (data as List).map((j) => Fine.fromJson(j)).toList();
  }

  static Future<Fine> payFine(String id) async {
    final data = await _api.post('/api/fines/$id/pay');
    return Fine.fromJson(data as Map<String, dynamic>);
  }

  // ── Waitlist ──────────────────────────────────────────────────────────────
  static Future<List<WaitlistEntry>> getWaitlist({String? bookIsbn}) async {
    final params = <String, String>{};
    if (bookIsbn != null && bookIsbn.isNotEmpty) params['book_isbn'] = bookIsbn;
    final data = await _api.get('/api/waitlist', queryParams: params.isEmpty ? null : params);
    return (data as List).map((j) => WaitlistEntry.fromJson(j)).toList();
  }

  static Future<WaitlistEntry> createWaitlistEntry(Map<String, dynamic> body) async {
    final data = await _api.post('/api/waitlist', body: body);
    return WaitlistEntry.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteWaitlistEntry(String id) async {
    await _api.delete('/api/waitlist/$id');
  }

  // ── Purchases ─────────────────────────────────────────────────────────────
  static Future<List<PurchaseRequest>> getPurchases({String? status}) async {
    final params = <String, String>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    final data = await _api.get('/api/purchases', queryParams: params.isEmpty ? null : params);
    return (data as List).map((j) => PurchaseRequest.fromJson(j)).toList();
  }

  static Future<PurchaseRequest> getPurchase(String id) async {
    final data = await _api.get('/api/purchases/$id');
    return PurchaseRequest.fromJson(data as Map<String, dynamic>);
  }

  static Future<PurchaseRequest> createPurchase(Map<String, dynamic> body) async {
    final data = await _api.post('/api/purchases', body: body);
    return PurchaseRequest.fromJson(data as Map<String, dynamic>);
  }

  static Future<PurchaseRequest> reviewPurchase(String id, Map<String, dynamic> body) async {
    final data = await _api.post('/api/purchases/$id/review', body: body);
    return PurchaseRequest.fromJson(data as Map<String, dynamic>);
  }
}
