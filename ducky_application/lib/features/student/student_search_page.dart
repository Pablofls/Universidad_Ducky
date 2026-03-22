import 'package:flutter/material.dart';

class StudentSearchPage extends StatelessWidget {
  const StudentSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Buscar Libros',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('En desarrollo...',
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
