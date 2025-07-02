import 'dart:io';
import 'package:ecom_construction/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/services/api_service.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({Key? key}) : super(key: key);

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiService.get('buyer');
      final user = response['user'];
      final buyer = response['buyer'];

      setState(() {
        fNameController.text = user['f_name'] ?? '';
        lNameController.text = user['l_name'] ?? '';
        emailController.text = user['email'] ?? '';
        phoneController.text = user['phone'] ?? '';
        companyController.text = buyer['company_name'] ?? '';
        addressController.text = buyer['delivery_address'] ?? '';
        _profileImageUrl = buyer['profile_picture'] != null
            ? 'http://10.0.2.2:8000/storage/${buyer['profile_picture']}'
            : null;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges() async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('http://10.0.2.2:8000/api/buyer');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['_method'] = 'PUT'; // Laravel supports spoofing PUT like this
    request.fields['f_name'] = fNameController.text;
    request.fields['l_name'] = lNameController.text;
    request.fields['email'] = emailController.text;
    request.fields['phone'] = phoneController.text;
    request.fields['company_name'] = companyController.text;
    request.fields['delivery_address'] = addressController.text;

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', _profileImage!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: ${response.statusCode}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    fNameController.dispose();
    lNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_profileImage != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_profileImage!),
                )
              else if (_profileImageUrl != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_profileImageUrl!),
                )
              else
                const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 40)),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Picture'),
              ),
              const SizedBox(height: 20),
              _buildTextField(fNameController, 'First Name'),
              _buildTextField(lNameController, 'Last Name'),
              _buildTextField(emailController, 'Email'),
              _buildTextField(phoneController, 'Phone'),
              _buildTextField(companyController, 'Company'),
              _buildTextField(addressController, 'Delivery Address'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
