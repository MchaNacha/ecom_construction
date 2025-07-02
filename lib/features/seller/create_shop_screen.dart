import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _logo;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _logo = File(picked.path));
  }

  Future<void> _submitShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      print(' Creating shop with token: $token');
      print(' Fields: ${{
        'name': _nameController.text,
        'location': _locationController.text,
        'category': _categoryController.text,
      }}');

      final request = await ApiService.multipartRequest(
        'shops',
        token: token,
        fields: {
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'category': _categoryController.text.trim(),
        },
        fileField: _logo != null ? {'logo': _logo!} : null,
      );

      if (request.statusCode == 201) {
        final shopData = jsonDecode(await request.stream.bytesToString())['shop'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('shop_id', shopData['id']); // Save it here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop created successfully')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _error = 'Failed: ${request.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Shop')),
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
                decoration: const InputDecoration(labelText: 'Category (Description)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Select Logo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitShop,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
