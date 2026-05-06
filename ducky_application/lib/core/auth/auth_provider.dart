import 'package:flutter/foundation.dart';
import '../api_client.dart';

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

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id:    json['id'] as String,
    name:  json['name'] as String,
    email: json['email'] as String,
    role:  UserRole.values.firstWhere((e) => e.name == json['role']),
  );

  Map<String, dynamic> toJson() => {
    'id':    id,
    'name':  name,
    'email': email,
    'role':  role.name,
  };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ── Provider de autenticación ─────────────────────────────────────────────────
/// Conecta con el endpoint POST /api/auth/login del Flask backend.
/// El JWT devuelto se almacena en ApiClient para que todas las peticiones
/// posteriores lo envíen automáticamente en el header Authorization.
class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Getter for the raw JWT token (useful for debugging).
  String? get token => _api.token;

  /// Intenta autenticar contra la API real.
  /// Devuelve null si ok, o un mensaje de error.
  Future<String?> login(String email, String password) async {
    try {
      final data = await _api.post('/api/auth/login', body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      // Store the JWT so subsequent API calls are authenticated
      _api.token = data['token'] as String;

      // Build the AuthUser from the response
      _currentUser = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

      notifyListeners();
      return null; // null = sin error
    } on ApiException catch (e) {
      // Backend returned a structured error (401, 400, etc.)
      return e.message;
    } catch (e) {
      // Network error, DNS failure, timeout, etc.
      return 'Error de conexión: no se pudo contactar al servidor';
    }
  }

  void logout() {
    _currentUser = null;
    _api.clearToken();
    notifyListeners();
  }
}
