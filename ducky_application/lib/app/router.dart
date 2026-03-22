// ═══════════════════════════════════════════════════════════════════════════
//  lib/app/router.dart
//  Equivalente a routes.ts del prototipo React.
//  Usa go_router con redirección automática según autenticación.
// ═══════════════════════════════════════════════════════════════════════════

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
import '../features/purchases/purchase_list_page.dart';
import '../features/purchases/purchase_detail_page.dart';
import '../features/purchases/create_purchase_page.dart';
import '../features/permissions/permissions_page.dart';
import '../features/student/student_search_page.dart';
import '../shared/widgets/app_scaffold.dart';

// ── Nombre de las rutas (constantes para evitar strings sueltos) ──────────────
class AppRoutes {
  static const login        = '/login';
  static const dashboard    = '/';
  static const users        = '/users';
  static const userCreate   = '/users/create';
  static const userDetail   = '/users/:id';
  static const books        = '/books';
  static const bookCreate   = '/books/create';
  static const bookDetail   = '/books/:isbn';
  static const bookEdit     = '/books/:isbn/edit';
  static const copies       = '/copies';
  static const copyCreate   = '/copies/create';
  static const copyDetail   = '/copies/:id';
  static const loans        = '/loans';
  static const purchases    = '/purchases';
  static const purchaseCreate = '/purchases/create';
  static const purchaseDetail = '/purchases/:id';
  static const permissions  = '/permissions';
  static const studentSearch = '/student/search';
}

// ── Router ────────────────────────────────────────────────────────────────────
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: authProvider,

    // Redirige al login si no hay sesión, o al dashboard si ya hay sesión
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final goingToLogin = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !goingToLogin) return AppRoutes.login;
      if (isLoggedIn && goingToLogin) {
        final user = authProvider.currentUser!;
        return user.role == UserRole.student
            ? AppRoutes.studentSearch
            : AppRoutes.dashboard;
      }
      return null;
    },

    routes: [
      // ── Login (sin scaffold) ───────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),

      // ── Shell con Sidebar (todas las páginas admin) ────────────────────
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const DashboardPage(),
          ),

          // Users
          GoRoute(path: AppRoutes.users,      builder: (_, __) => const UserListPage()),
          GoRoute(path: AppRoutes.userCreate,  builder: (_, __) => const CreateUserPage()),
          GoRoute(
            path: AppRoutes.userDetail,
            builder: (_, state) => UserDetailPage(userId: state.pathParameters['id']!),
          ),

          // Books
          GoRoute(path: AppRoutes.books,      builder: (_, __) => const BookListPage()),
          GoRoute(path: AppRoutes.bookCreate,  builder: (_, __) => const CreateBookPage()),
          GoRoute(
            path: AppRoutes.bookDetail,
            builder: (_, state) => BookDetailPage(isbn: state.pathParameters['isbn']!),
          ),
          GoRoute(
            path: AppRoutes.bookEdit,
            builder: (_, state) => EditBookPage(isbn: state.pathParameters['isbn']!),
          ),

          // Copies
          GoRoute(path: AppRoutes.copies,     builder: (_, __) => const CopyListPage()),
          GoRoute(path: AppRoutes.copyCreate,  builder: (_, __) => const CreateCopyPage()),
          GoRoute(
            path: AppRoutes.copyDetail,
            builder: (_, state) => CopyDetailPage(copyId: state.pathParameters['id']!),
          ),

          // Loans
          GoRoute(path: AppRoutes.loans,      builder: (_, __) => const LoansPage()),

          // Purchases
          GoRoute(path: AppRoutes.purchases,      builder: (_, __) => const PurchaseListPage()),
          GoRoute(path: AppRoutes.purchaseCreate,  builder: (_, __) => const CreatePurchasePage()),
          GoRoute(
            path: AppRoutes.purchaseDetail,
            builder: (_, state) => PurchaseDetailPage(id: state.pathParameters['id']!),
          ),

          // Permissions
          GoRoute(path: AppRoutes.permissions, builder: (_, __) => const PermissionsPage()),

          // Student
          GoRoute(path: AppRoutes.studentSearch, builder: (_, __) => const StudentSearchPage()),
        ],
      ),
    ],

    // Página 404
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );
}
