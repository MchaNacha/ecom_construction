import 'package:ecom_construction/features/buyer/product_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  final int shopId;
  final String shopName;

  const ProductListScreen({
    super.key,
    required this.shopId,
    required this.shopName,
  });



  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _error;

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      // build your query string
      final queryParams = _searchQuery.isNotEmpty ? '?search=$_searchQuery' : '';

      // build the endpoint path
      final endpoint = 'shops/${widget.shopId}$queryParams';

      // ← INSERT the debug print here
      print('Fetching products with URL: ${ApiService.baseUrl}/$endpoint');

      // now fire the request
      final response = await ApiService.get(endpoint);

      print('Shop data: $response');

      setState(() {
        _products = response['data']['products'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load products: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            _fetchProducts();
          },
        )
            : Text('Products'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _fetchProducts();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _products.isEmpty
          ? const Center(child: Text('No products found.'))
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            title: Text(product['name'] ?? 'Unnamed Product'),
            subtitle: Text(
              'Category: ${product['category']?['name'] ?? 'Unknown'}',
            ),
            trailing: Text('${product['price'] ?? 0} IQD'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product) ));
            },
          );
        },
      ),
    );
  }
}
