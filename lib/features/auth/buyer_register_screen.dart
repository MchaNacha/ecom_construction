import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/api_service.dart';
import '../dashboard/dashboard_screen.dart';

class BuyerRegisterScreen extends StatefulWidget {
  const BuyerRegisterScreen({super.key});

  @override
  State<BuyerRegisterScreen> createState() => _BuyerRegisterScreenState();
}

class _BuyerRegisterScreenState extends State<BuyerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fName = TextEditingController();
  final TextEditingController _lName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _company = TextEditingController();
  final TextEditingController _address = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.post('auth/register/buyer', {
        'f_name': _fName.text.trim(),
        'l_name': _lName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'password': _password.text,
        'company_name': _company.text.trim().isEmpty ? null : _company.text.trim(),
        'delivery_address': _address.text.trim(),
      });

      final token = response['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _error = 'Registration failed: no token received';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Registration failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _fName,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: _lName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@') ? null : 'Invalid email',
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v != null && v.length >= 7 ? null : 'Invalid phone',
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 8 ? null : 'Min 8 characters',
              ),
              TextFormField(
                controller: _company,
                decoration: const InputDecoration(labelText: 'Company Name (optional)'),
              ),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Delivery Address'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Register as Buyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
