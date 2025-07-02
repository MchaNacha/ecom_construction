import 'package:ecom_construction/data/providers/seller_product_provider.dart';
import 'package:ecom_construction/data/services/api_service.dart';
import 'package:ecom_construction/features/seller/create_shop_screen.dart';
import 'package:ecom_construction/features/seller/edit_shop_screen.dart';
import 'package:ecom_construction/features/seller/manage_orders_screen.dart';
import 'package:ecom_construction/features/seller/manage_products_screen.dart';
import 'package:ecom_construction/features/seller/seller_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {

  Future<void> _handleManageShop() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await ApiService.get('shops');
      final List shops = response['data'] ?? [];

      // Assume only one shop per seller — look for their shop
      if (shops.isNotEmpty) {
        final sellerRes = await ApiService.get('seller');
        final sellerId = sellerRes['seller']['id'];

        final shopsRes = await ApiService.get('shops');
        final shops = shopsRes['data'];

        final shop = shops.firstWhere(
              (s) => s['seller_id'] == sellerId,
          orElse: () => null,
        );

        if (shop != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('shop_id', shop['id']); // Save it for later access
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditShopScreen(shop: shop)),
          );
          return;
        }
      }

      // No shop found → Create new one
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateShopScreen()),
      );
    } catch (e) {
      debugPrint('Error fetching shop: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load shop. Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardItems = [
      {
        'title': 'Edit Profile',
        'icon': Icons.person,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SellerProfileScreen()),
          );
        },
      },
      {
        'title': 'Manage Shop',
        'icon': Icons.store,
        'onTap': _handleManageShop,
      },
      {
        'title': 'Manage Products',
        'icon': Icons.inventory,
        'onTap': () async {
          try {
            final sellerRes = await ApiService.get('seller');
            final sellerId = sellerRes['seller']['id'];

            final shopsRes = await ApiService.get('shops');
            final shops = shopsRes['data'];

            final shop = shops.firstWhere(
                  (s) => s['seller_id'] == sellerId,
              orElse: () => null,
            );

            if (shop != null) {
              final shopId = shop['id'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => SellerProductProvider()..fetchSellerProducts(),
                    child: ManageProductsScreen(sellerShopId: shopId),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No shop found for this seller.')),
              );
            }
          } catch (e) {
            print('Error fetching shop: $e');
          }
        },
      },
      {
        'title': 'Manage Orders',
        'icon': Icons.receipt_long,
        'onTap': () {
          // TODO: Navigate to Manage Orders Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
          );
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
        children: dashboardItems.map((item) {
          return InkWell(
            onTap: item['onTap'] as void Function(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData, size: 48, color: Colors.blueGrey),
                  const SizedBox(height: 12),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
