import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final List<Product> products = [
  Product(name: 'Laptop', price: 25000.0),
  Product(name: 'Smartphone', price: 15000.0),
  Product(name: 'Headphones', price: 1200.0),
  Product(name: 'Keyboard', price: 800.0),
  Product(name: 'Mouse', price: 450.0),
  Product(name: 'Monitor', price: 6500.0),
  Product(name: 'Tablet', price: 9000.0),
  Product(name: 'Smartwatch', price: 2200.0),
  Product(name: 'Charger', price: 350.0),
  Product(name: 'USB Cable', price: 150.0),
  Product(name: 'Power Bank', price: 1100.0),
  Product(name: 'Bluetooth Speaker', price: 1800.0),
  Product(name: 'Webcam', price: 1400.0),
  Product(name: 'Microphone', price: 2000.0),
  Product(name: 'Printer', price: 5000.0),
  Product(name: 'External SSD', price: 3200.0),
  Product(name: 'Router', price: 1700.0),
  Product(name: 'Gaming Controller', price: 1600.0),
  Product(name: 'Laptop Stand', price: 600.0),
  Product(name: 'Desk Lamp', price: 500.0),
];

class RebuildOptimization extends StatelessWidget {
  const RebuildOptimization({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Selector<PriceNotifier, double>(
          selector: (_, notifier) => notifier.total,
          builder: (_, price, __) {
            return Text('Total Price: ${price.toStringAsFixed(2)}');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }
}

class Product {
  final String name;
  final double price;
  Product({required this.name, required this.price});
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    debugPrint('ProductCard ${product.name} rebuilt');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Text(' ${product.name}')),
            Text(' ${product.price.toStringAsFixed(2)}'),
            QuantityText(product: product),
            const SizedBox(width: 8),
            Buttons(product: product),
          ],
        ),
      ),
    );
  }
}

class QuantityText extends StatelessWidget {
  const QuantityText({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final quantity = context.select<PriceNotifier, int>(
      (n) => n.quantityOf(product),
    );
    return Text(' $quantity', style: const TextStyle(color: Colors.red));
  }
}

class Buttons extends StatelessWidget {
  const Buttons({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            context.read<PriceNotifier>().add(product);
          },
          child: const Text('+'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<PriceNotifier>().remove(product);
          },
          child: const Text('-'),
        ),
      ],
    );
  }
}

class PriceNotifier extends ChangeNotifier {
  final Map<String, int> _quantities = {};

  int quantityOf(Product p) => _quantities[p.name] ?? 0;

  double get total => _quantities.entries.fold(0, (sum, e) {
    final product = products.firstWhere((p) => p.name == e.key);
    return sum + product.price * e.value;
  });

  void add(Product p) {
    _quantities[p.name] = quantityOf(p) + 1;
    notifyListeners();
  }

  void remove(Product p) {
    final q = quantityOf(p);
    if (q <= 0) return;
    _quantities[p.name] = q - 1;
    notifyListeners();
  }
}
