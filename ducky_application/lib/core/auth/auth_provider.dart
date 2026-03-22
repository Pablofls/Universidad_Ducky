import 'package:flutter/foundation.dart';

// ── Enum de roles ─────────────────────────────────────────────────────────────
enum UserRole { administrator, librarian, student, professor }

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.administrator: return 'Administrador';
      case UserRole.librarian:    return 'Bibliotecario';
      case UserRole.student:      return 'Alumno';
      case UserRole.professor:    return 'Profesor';
    }
  }

  /// ¿Puede ver el panel administrativo (web)?
  bool get isAdmin => this == UserRole.administrator || this == UserRole.librarian;
}

// ── Modelo de usuario autenticado ─────────────────────────────────────────────
class AuthUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Provider de autenticación ─────────────────────────────────────────────────
/// Equivalente al AuthContext.tsx del prototipo React.
/// Cuando conectes la BD, sólo tienes que modificar [login] para hacer
/// la llamada HTTP y rellenar el [AuthUser] con la respuesta.
class AuthProvider extends ChangeNotifier {
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // ── Mock de usuarios (reemplazar por API call) ────────────────────────────
  static const _mockUsers = [
    {
      'id': 'admin-001',
      'name': 'Usuario Admin',
      'email': 'admin@ducky.edu',
      'password': 'admin',
      'role': UserRole.administrator,
    },
    {
      'id': 'lib-001',
      'name': 'Bibliotecario Demo',
      'email': 'biblio@ducky.edu',
      'password': 'biblio',
      'role': UserRole.librarian,
    },
    {
      'id': 'student-001',
      'name': 'Alumno Demo',
      'email': 'alumno@ducky.edu',
      'password': 'alumno',
      'role': UserRole.student,
    },
  ];

  /// Intenta autenticar. Devuelve null si ok, o un mensaje de error.
  /// TODO: Reemplazar el cuerpo de este método con tu llamada a la BD.
  Future<String?> login(String email, String password) async {
    // --- Simulación de delay de red ---
    await Future.delayed(const Duration(milliseconds: 400));

    final found = _mockUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (found.isEmpty) {
      return 'Correo electrónico o contraseña incorrectos';
    }

    _currentUser = AuthUser(
      id: found['id'] as String,
      name: found['name'] as String,
      email: found['email'] as String,
      role: found['role'] as UserRole,
    );
    notifyListeners();
    return null; // null = sin error
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
