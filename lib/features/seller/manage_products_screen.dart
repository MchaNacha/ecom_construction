import 'dart:convert';

import 'package:ecom_construction/data/services/api_service.dart';
import 'package:ecom_construction/features/seller/add_product_screen.dart';
import 'package:ecom_construction/features/seller/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/seller_product_provider.dart';

class ManageProductsScreen extends StatefulWidget {
  final int sellerShopId; // you’ll pass this from the seller’s dashboard

  const ManageProductsScreen({super.key, required this.sellerShopId});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<SellerProductProvider>(context, listen: false);
    await provider.fetchSellerProducts();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final sellerProducts = context.watch<SellerProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );

              // Refresh product list if a new product was added
              if (result == true) {
                Provider.of<SellerProductProvider>(context, listen: false).fetchSellerProducts();
              }
            },
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : sellerProducts.isEmpty
          ? const Center(child: Text('No products found.'))
          : ListView.builder(
        itemCount: sellerProducts.length,
        itemBuilder: (context, index) {
          final product = sellerProducts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: product['picture'] != null
                  ? Image.network(
                'http://10.0.2.2:8000/storage/${product['picture']}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image_not_supported),
              title: Text(product['name']),
              subtitle: Text('Qty: ${product['quantity']} • IQD ${product['price_per_unit']}'),
              trailing: Container(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProductScreen(product: product),
                          ),
                        ).then((updated) {
                          if (updated == true) {
                            Provider.of<SellerProductProvider>(context, listen: false).fetchSellerProducts();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Product',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text('Are you sure you want to delete this product?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            final response = await ApiService.delete('products/${product['id']}');

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Product deleted successfully')),
                              );

                              // Refresh list after deletion
                              await Provider.of<SellerProductProvider>(context, listen: false)
                                  .fetchSellerProducts();
                            } else {
                              final decoded = jsonDecode(response.body);
                              throw Exception(decoded['message'] ?? 'Delete failed');
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Delete failed: $e')),
                            );
                          }
                        }
                      },
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
