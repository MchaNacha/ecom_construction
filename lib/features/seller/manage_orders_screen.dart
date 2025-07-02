import 'package:ecom_construction/features/seller/order_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('orders/seller');
      final orders = response['data'] as List<dynamic>;

      setState(() {
        _orders = orders.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final buyer = order['buyer']?['user'] ?? {};
          final products = order['products'] as List<dynamic>;

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Order #${order['id']} - ${buyer['f_name'] ?? 'Unknown'}'),
              subtitle: Text(
                '${products.length} product(s) - Status: ${order['status']}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellerOrderDetailScreen(order: order),
                  ),
                );
              },

            ),
          );
        },
      ),
    );
  }
}
