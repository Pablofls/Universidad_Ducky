import 'package:flutter/material.dart';

class CopyDetailPage extends StatelessWidget {
  final String copyId;
  const CopyDetailPage({super.key, required this.copyId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.copy_all, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Detalle de Ejemplar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('En desarrollo...',
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
