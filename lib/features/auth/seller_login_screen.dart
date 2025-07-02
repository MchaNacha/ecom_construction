import 'package:ecom_construction/features/seller/seller_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/api_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'seller_register_screen.dart';

class SellerLoginScreen extends StatefulWidget {
  const SellerLoginScreen({super.key});

  @override
  State<SellerLoginScreen> createState() => _SellerLoginScreenState();
}

class _SellerLoginScreenState extends State<SellerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });


    try {
      final response = await ApiService.post('auth/login/seller', {
        'email': _email.text.trim(),
        'password': _password.text,
      });

      print('Login response: $response');

      final token = response['token'];
      final isActive = response['seller']['is_active'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (!mounted) return;

        if (isActive) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SellerDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,

            MaterialPageRoute(builder: (_) => const SellerPendingApprovalScreen()),
          );
        }
      } else {
        setState(() {
          _error = 'Login failed: No token received.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed: ${e.toString()}';
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
      appBar: AppBar(title: const Text('Seller Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.contains('@') ? null : 'Invalid email',
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 8 ? null : 'Min 8 characters',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SellerRegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Register here"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Goes back to role selection
                },
                child: const Text("← Back to Role Selection"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}



class SellerPendingApprovalScreen extends StatelessWidget {
  const SellerPendingApprovalScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SellerLoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approval'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Your account is under review.\nPlease wait for admin approval.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
