import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.fetchBuyerOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final status = order['status'] ?? 'Unknown';
              final date = order['date'] ?? '';
              final totalCost = order['total_cost'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Order #${order['id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: $date'),
                      Text('Total: $totalCost IQD'),

                    ],
                  ),
                  trailing: Text('Status: $status',
                      style: TextStyle(
                        color: status == 'completed'
                            ? Colors.green
                            : status == 'pending'
                            ? Colors.orange
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              );
            },
          );

        },
      ),
    );
  }
}
// 'package:flutter/src/widgets/navigator.dart': Failed assertion: line 5859 pos 12: '!_debugLocked': is not true.