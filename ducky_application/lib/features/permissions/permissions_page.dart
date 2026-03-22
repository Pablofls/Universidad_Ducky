import 'package:flutter/material.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Permisos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('En desarrollo...',
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
