import 'dart:convert';

import 'package:ecom_construction/data/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerProductProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allProducts = [];
  int? _sellerShopId;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> get products => _products;

  List<Map<String, dynamic>> get productsForSeller {
    if (_sellerShopId == null) return [];
    return _allProducts.where((p) => p['shop_id'] == _sellerShopId).toList();
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final response = await ApiService.delete('products/$productId');
      final body = jsonDecode(response.body);
      if (body['message'] == 'Product deleted successfully') {
        _products.removeWhere((product) => product['id'] == productId);
        notifyListeners();
      } else {
        throw Exception('Delete failed: ${body['message']}');
      }
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }


  void setShopId(int shopId) {
    _sellerShopId = shopId;
    notifyListeners();
  }

  Future<int> getSavedShopId() async {
    final prefs = await SharedPreferences.getInstance();
    final shopId = prefs.getInt('shop_id');

    if (shopId == null) {
      throw Exception('Shop ID not found in SharedPreferences');
    }

    return shopId;
  }


  Future<void> fetchSellerProducts() async {
    try {
      final shopId = await getSavedShopId(); // fetch saved shop ID
      final response = await ApiService.get('products');
      final List<dynamic> allProducts = response['data'];

      _products = allProducts
          .where((product) => product['shop_id'] == shopId)
          .cast<Map<String, dynamic>>()
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching seller products: $e');
    }
  }

  Future<void> loadProducts(List<Map<String, dynamic>> fetchedProducts) async {
    _allProducts = fetchedProducts;
    notifyListeners();
  }
}
