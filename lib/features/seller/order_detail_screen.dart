import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateOrderStatus(BuildContext context, int orderId, String status) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.patch(
    Uri.parse('http://10.0.2.2:8000/api/orders/$orderId/status'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: '{"status": "$status"}',
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status updated')),
    );
    Navigator.pop(context); // Optionally go back
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update status: ${response.body}')),
    );
  }
}

class SellerOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const SellerOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final buyer = order['buyer']?['user'] ?? {};
    final products = order['products'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Order ID: ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Buyer: ${buyer['f_name'] ?? ''} ${buyer['l_name'] ?? ''}'),
            Text('Phone: ${buyer['phone'] ?? 'N/A'}'),
            const Divider(height: 32),

            const Text('Products:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...products.map((product) {
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('Quantity: ${product['pivot']['quantity']}'),
                trailing: Text('${product['price_per_unit']} IQD'),
              );
            }).toList(),

            const Divider(height: 32),
            Text('Total: ${order['total_cost']} IQD'),
            const SizedBox(height: 8),
            Text('Status: ${order['status']}', style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      updateOrderStatus(context, order['id'], 'completed');
                    },
                    child: const Text('Mark as Completed'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      updateOrderStatus(context, order['id'], 'canceled');
                    },
                    child: const Text('Cancel Order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
