// ═══════════════════════════════════════════════════════════════════════════
//  lib/features/_placeholders.dart
//  Páginas temporales para que el router no truene.
//  Cada una se irá reemplazando con la implementación real.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../app/theme.dart';

// Helper widget
class _ComingSoon extends StatelessWidget {
  final String title;
  final IconData icon;
  const _ComingSoon({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
          child: Icon(icon, size: 36, color: AppTheme.primary),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.gray900,
        )),
        const SizedBox(height: 8),
        const Text('Esta pantalla se implementará próximamente.',
            style: TextStyle(color: AppTheme.gray500)),
      ],
    ),
  );
}
