import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  final String isbn;
  const BookDetailPage({super.key, required this.isbn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Detalle de Libro',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('En desarrollo...',
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
