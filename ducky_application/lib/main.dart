import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/theme.dart';
import 'app/router.dart';
import 'core/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const DuckyApp(),
    ),
  );
}

class DuckyApp extends StatefulWidget {
  const DuckyApp({super.key});
  @override
  State<DuckyApp> createState() => _DuckyAppState();
}

class _DuckyAppState extends State<DuckyApp> {
  late final router = createRouter(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Gestión Ducky',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}