import 'package:ecom_construction/features/buyer/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/wishlist_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlistItems = wishlistProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: wishlistItems.isEmpty
          ? const Center(child: Text('Your wishlist is empty.'))
          : ListView.builder(
        itemCount: wishlistItems.length,
        itemBuilder: (context, index) {
          final product = wishlistItems[index];

          return ListTile(
            leading: Image.network(
              product['image_url'] ?? '',
              width: 50,
              height: 50,
              errorBuilder: (_, __, ___) => const Icon(Icons.image),
            ),
            title: Text(product['name'] ?? 'Unnamed Product'),
            subtitle: Text('${product['price_per_unit']} IQD'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                wishlistProvider.removeFromWishlist(product['id']);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
