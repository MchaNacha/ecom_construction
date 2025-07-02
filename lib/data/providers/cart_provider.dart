import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> product, int quantity) {
    final existingIndex = _items.indexWhere((item) => item['id'] == product['id']);

    if (existingIndex != -1) {
      _items[existingIndex]['quantity'] += quantity;
    } else {
      _items.add({
        ...product,
        'quantity': quantity,
      });
    }

    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item['id'] == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get totalCost {
    return _items.fold(0.0, (sum, item) {
      final price = double.tryParse(item['price_per_unit'].toString()) ?? 0.0;
      return sum + (price * item['quantity']);
    });
  }
}
