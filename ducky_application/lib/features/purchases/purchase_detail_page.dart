import 'package:flutter/material.dart';

class PurchaseDetailPage extends StatelessWidget {
  final String id;
  const PurchaseDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Detalle de Solicitud',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('En desarrollo...',
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
