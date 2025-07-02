import 'package:ecom_construction/features/buyer/product_list_screen.dart';
import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class BuyerShopListScreen extends StatefulWidget {
  const BuyerShopListScreen({super.key});

  @override
  State<BuyerShopListScreen> createState() => _BuyerShopListScreenState();
}

class _BuyerShopListScreenState extends State<BuyerShopListScreen> {
  List<dynamic> _shops = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      final response = await ApiService.get('shops'); // GET /api/shops

      print('Response from API: $response');


      setState(() {
        _shops = response['data'];
        _isLoading = false;

      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load shops: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Shops')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView.builder(
        itemCount: _shops.length,
        itemBuilder: (context, index) {
          final shop = _shops[index];
          return ListTile(
            title: Text(shop['name'] ?? 'Unnamed Shop'),
            subtitle: Text(shop['category'] ?? 'No Category'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    shopId: shop['id'],
                    shopName: shop['name'] ?? 'Shop',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
