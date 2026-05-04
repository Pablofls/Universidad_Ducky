import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_provider.dart';
import '../features/auth/login_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/users/user_list_page.dart';
import '../features/users/user_detail_page.dart';
import '../features/users/create_user_page.dart';
import '../features/books/book_list_page.dart';
import '../features/books/book_detail_page.dart';
import '../features/books/create_book_page.dart';
import '../features/books/edit_book_page.dart';
import '../features/copies/copy_list_page.dart';
import '../features/copies/copy_detail_page.dart';
import '../features/copies/create_copy_page.dart';
import '../features/loans/loans_page.dart';
import '../features/loans/loan_detail_page.dart';
import '../features/loans/waitlist_page.dart';
import '../features/purchases/purchase_list_page.dart';
import '../features/purchases/purchase_detail_page.dart';
import '../features/purchases/create_purchase_page.dart';
import '../features/permissions/permissions_page.dart';
import '../features/student/student_search_page.dart';
import '../features/student/student_search_mobile_page.dart';
import '../shared/widgets/app_scaffold.dart';
import '../shared/widgets/app_layout.dart';

class AppRoutes {
  static const login          = '/login';
  static const dashboard      = '/';
  static const users          = '/users';
  static const userCreate     = '/users/create';
  static const userDetail     = '/users/:id';
  static const books          = '/books';
  static const bookCreate     = '/books/create';
  static const bookDetail     = '/books/:isbn';
  static const bookEdit       = '/books/:isbn/edit';
  static const copies         = '/copies';
  static const copyCreate     = '/copies/create';
  static const copyDetail     = '/copies/:id';
  static const loans          = '/loans';
  static const loansNew       = '/loans/new';
  static const loansReturn    = '/loans/return';
  static const loansFines     = '/loans/fines';
  static const loansWaitlist  = '/loans/waitlist';
  static const loanDetail     = '/loans/:id';
  static const purchases      = '/purchases';
  static const purchaseCreate = '/purchases/create';
  static const purchaseDetail = '/purchases/:id';
  static const permissions    = '/permissions';
  static const studentSearch  = '/student/search';
}

// Sin animación — transición instantánea
Page<dynamic> _noAnimPage(Widget child) => CustomTransitionPage(
  child: child,
  transitionsBuilder: (_, __, ___, child) => child,
  transitionDuration: Duration.zero,
);

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final loggedIn     = authProvider.isAuthenticated;
      final goingToLogin = state.matchedLocation == AppRoutes.login;
      if (!loggedIn && !goingToLogin) return AppRoutes.login;
      if (loggedIn && goingToLogin) {
        return authProvider.currentUser!.role == UserRole.student
            ? AppRoutes.studentSearch : AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login,
          pageBuilder: (_, __) => _noAnimPage(const LoginPage())),

      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: AppRoutes.dashboard,
              pageBuilder: (_, __) => _noAnimPage(const DashboardPage())),

          GoRoute(path: AppRoutes.users,
              pageBuilder: (_, __) => _noAnimPage(const UserListPage())),
          GoRoute(path: AppRoutes.userCreate,
              pageBuilder: (_, __) => _noAnimPage(const CreateUserPage())),
          GoRoute(path: AppRoutes.userDetail,
              pageBuilder: (_, s) => _noAnimPage(UserDetailPage(userId: s.pathParameters['id']!))),

          GoRoute(path: AppRoutes.books,
              pageBuilder: (_, __) => _noAnimPage(const BookListPage())),
          GoRoute(path: AppRoutes.bookCreate,
              pageBuilder: (_, __) => _noAnimPage(const CreateBookPage())),
          GoRoute(path: AppRoutes.bookDetail,
              pageBuilder: (_, s) => _noAnimPage(BookDetailPage(isbn: Uri.decodeComponent(s.pathParameters['isbn']!)))),
          GoRoute(path: AppRoutes.bookEdit,
              pageBuilder: (_, s) => _noAnimPage(EditBookPage(isbn: Uri.decodeComponent(s.pathParameters['isbn']!)))),

          GoRoute(path: AppRoutes.copies,
              pageBuilder: (_, __) => _noAnimPage(const CopyListPage())),
          GoRoute(path: AppRoutes.copyCreate,
              pageBuilder: (_, __) => _noAnimPage(const CreateCopyPage())),
          GoRoute(path: AppRoutes.copyDetail,
              pageBuilder: (_, s) => _noAnimPage(CopyDetailPage(copyId: s.pathParameters['id']!))),

          GoRoute(path: AppRoutes.loans,
              pageBuilder: (_, __) => _noAnimPage(const LoansPage())),
          GoRoute(path: AppRoutes.loansNew,
              pageBuilder: (_, __) => _noAnimPage(const LoansPage(initialTab: 1))),
          GoRoute(path: AppRoutes.loansReturn,
              pageBuilder: (_, s) {
                final loanId = s.uri.queryParameters['loanId'];
                return _noAnimPage(LoansPage(initialTab: 2, loanId: loanId));
              }),
          GoRoute(path: AppRoutes.loansFines,
              pageBuilder: (_, __) => _noAnimPage(const LoansPage(initialTab: 3))),
          GoRoute(path: AppRoutes.loansWaitlist,
              pageBuilder: (_, __) => _noAnimPage(const WaitlistPage())),
          GoRoute(path: AppRoutes.loanDetail,
              pageBuilder: (_, s) => _noAnimPage(LoanDetailPage(loanId: s.pathParameters['id']!))),

          GoRoute(path: AppRoutes.purchases,
              pageBuilder: (_, __) => _noAnimPage(const PurchaseListPage())),
          GoRoute(path: AppRoutes.purchaseCreate,
              pageBuilder: (_, __) => _noAnimPage(const CreatePurchasePage())),
          GoRoute(path: AppRoutes.purchaseDetail,
              pageBuilder: (_, s) => _noAnimPage(PurchaseDetailPage(id: s.pathParameters['id']!))),

          GoRoute(path: AppRoutes.permissions,
              pageBuilder: (_, __) => _noAnimPage(const PermissionsPage())),
          GoRoute(path: AppRoutes.studentSearch,
              pageBuilder: (_, __) => _noAnimPage(const StudentSearchPage())),
        ],
      ),

      // ── Mobile app shell ─────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppLayout(child: child),
        routes: [
          GoRoute(
            path: '/app',
            pageBuilder: (_, __) => _noAnimPage(const StudentSearchMobilePage()),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Pagina no encontrada: ${state.error}')),
    ),
  );
}
