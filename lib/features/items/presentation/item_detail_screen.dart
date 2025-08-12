import 'package:flutter/material.dart';

/// Item detail screen
class ItemDetailScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: Center(
        child: Text('Item Detail Screen - Item ID: $itemId'),
      ),
    );
  }
}
