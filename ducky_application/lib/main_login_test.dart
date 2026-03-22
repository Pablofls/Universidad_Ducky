// ═══════════════════════════════════════════════════════════════════════════
//  lib/main.dart  —  versión temporal para probar solo el Login
//  Cuando tengamos todas las páginas, lo reemplazaremos por el main.dart
//  completo con GoRouter.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/theme.dart';
import 'core/auth/auth_provider.dart';
import 'features/auth/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const DuckyApp(),
    ),
  );
}

class DuckyApp extends StatelessWidget {
  const DuckyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión Ducky',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // Por ahora mostramos directo el Login
      home: const LoginPage(),
    );
  }
}
