import 'package:ecom_construction/data/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<WishlistProvider>(context, listen: false).loadWishlist());
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final category = product['category']?['name'] ?? 'Unknown';
    final imageUrl = product['picture'] != null
        ? 'http://10.0.2.2:8000/storage/${product['picture']}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Product'),
        actions: [
          Builder(
            builder: (context) {
              final productId = product['id'];
              if (productId == null) return SizedBox();

              return Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, _) {
                  final isWishlisted = wishlistProvider.isInWishlist(productId);
                  return IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      wishlistProvider.toggleWishlistStatus(product);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Center(
                child: Image.network(
                  imageUrl,
                  height: 200,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 16),
            Text('Category: $category'),
            Text('Price: ${product['price_per_unit']} IQD'),
            Text('Available: ${product['quantity']}'),
            const SizedBox(height: 12),
            Text(product['description'] ?? ''),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Quantity:'),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (quantity > 1) setState(() => quantity--);
                  },
                ),
                Text('$quantity'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (quantity < product['quantity']) {
                      setState(() => quantity++);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                onPressed: () {
                  print('Add to cart pressed');
                  Provider.of<CartProvider>(context, listen: false)
                      .addItem(product, quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
