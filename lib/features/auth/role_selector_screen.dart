import 'package:flutter/material.dart';
import 'buyer_login_screen.dart';
import 'seller_login_screen.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuyerLoginScreen()),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('I am a Buyer'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerLoginScreen()),
                );
              },
              icon: const Icon(Icons.store),
              label: const Text('I am a Seller'),
            ),
          ],
        ),
      ),
    );
  }
}
