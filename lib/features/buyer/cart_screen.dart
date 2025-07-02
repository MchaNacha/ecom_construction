import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cart_provider.dart';
import '../../data/services/api_service.dart';
import 'dart:async';

void showOrderConfirmationDialog(
    BuildContext context,
    List<Map<String, dynamic>> products,
    VoidCallback onConfirmed,
    ) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      int countdown = 30;
      Timer? timer;

      return StatefulBuilder(
        builder: (context, setState) {
          // Start timer only once
          if (timer == null) {
            timer = Timer.periodic(const Duration(seconds: 1), (t) {
              countdown--;
              if (countdown <= 0) {
                t.cancel();
                Navigator.of(dialogContext).pop();

                // Delay ensures Navigator.pop completes before order is placed
                Future.delayed(const Duration(milliseconds: 100), onConfirmed);
              } else {
                setState(() {}); // update countdown
              }
            });
          }

          return AlertDialog(
            title: const Text('Confirm Order'),
            content: Text('Order will be placed in $countdown seconds.'),
            actions: [
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel Order'),
              ),
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Navigator.of(dialogContext).pop();
                  Future.delayed(const Duration(milliseconds: 100), onConfirmed);
                },
                child: const Text('Place Now'),
              ),
            ],
          );
        },
      );
    },
  );
}


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items;
    final total = cart.totalCost;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body:
          items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: Text(item['name']),
                      subtitle: Text(
                        'Qty: ${item['quantity']} × ${item['price_per_unit']} IQD',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          cart.removeItem(item['id']);
                        },
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar:
          items.isEmpty
              ? null
              : Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    final cartItems = context.read<CartProvider>().items;

                    showOrderConfirmationDialog(context, cartItems, () async {
                      try {
                        final order = await ApiService.placeOrder(
                          cartItems.map((item) {
                            return {
                              'id': item['id'],
                              'quantity': item['quantity'],
                            };
                          }).toList(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully'),
                          ),
                        );

                        context.read<CartProvider>().clear();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order failed: $e')),
                        );
                      }
                    });
                  },
                  child: const Text('Place Order'),
                ),
              ),
    );
  }
}
