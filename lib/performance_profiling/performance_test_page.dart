import 'dart:math';

import 'package:flutter/material.dart';

class PerformanceTestPage extends StatelessWidget {
   PerformanceTestPage({super.key});
    final random = Random();

    final products = List.generate(10000, (index) => Product(id: index));
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Performance Test')),
      body: ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      }
      )
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Product ${product.id}'),
      ),
    );
  }
}

class Product {
  Product({required this.id});

  final int id;
}
