import 'dart:io';
import 'package:ecom_construction/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditShopScreen extends StatefulWidget {
  final Map<String, dynamic> shop;

  const EditShopScreen({super.key, required this.shop});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _categoryController;
  File? _logo;
  bool _isLoading = false;
  String? _error;
  String? _shopLogoUrl;

  Future<void> _loadShop() async {
    try {
      final response = await ApiService.get('shops/${widget.shop['id']}'); // replace with actual shop ID logic
      final shop = response['data'];

      setState(() {
        _nameController.text = shop['name'] ?? '';
        _locationController.text = shop['location'] ?? '';
        _categoryController.text = shop['category'] ?? '';
        _shopLogoUrl = shop['logo'] != null
            ? 'http://10.0.2.2:8000/storage/${shop['logo']}'
            : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load shop: $e')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _loadShop();
    _nameController = TextEditingController(text: widget.shop['name'] ?? '');
    _locationController = TextEditingController(text: widget.shop['location'] ?? '');
    _categoryController = TextEditingController(text: widget.shop['category'] ?? '');
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _logo = File(picked.path));
  }

  Future<void> _updateShop() async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('http://10.0.2.2:8000/api/shops/${widget.shop['id']}');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['_method'] = 'PATCH';
    request.fields['name'] = _nameController.text.trim();
    request.fields['location'] = _locationController.text.trim();
    request.fields['category'] = _categoryController.text.trim();

    if (_logo != null) {
      request.files.add(await http.MultipartFile.fromPath('logo', _logo!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop updated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Shop')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Logo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateShop,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
