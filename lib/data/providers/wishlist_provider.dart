import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WishlistProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _wishlistItems = [];

  List<Map<String, dynamic>> get items => _wishlistItems;

  bool isInWishlist(int productId) {
    return _wishlistItems.any((item) => item['id'] == productId);
  }

  Future<void> loadWishlist() async {
    try {
      final wishlistItems = await ApiService.getWishlist();
      _wishlistItems.clear();
      _wishlistItems.addAll(wishlistItems.cast<Map<String, dynamic>>());
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  Future<void> toggleWishlistStatus(Map<String, dynamic> product) async {
    final productId = product['id'];

    if (isInWishlist(productId)) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(product);
    }
  }

  Future<void> addToWishlist(Map<String, dynamic> product) async {
    try {
      await ApiService.addToWishlist(product['id']);
      _wishlistItems.add(product);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
    }
  }


  Future<void> removeFromWishlist(int productId) async {
    try {
      await ApiService.removeFromWishlist(productId);
      _wishlistItems.removeWhere((item) => item['id'] == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
    }
  }
}

