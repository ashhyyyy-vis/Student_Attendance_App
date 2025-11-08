import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));

    globals.currentUser = _userController.text.trim();
    globals.isLoggedIn = true;

    if (!mounted) return; // ✅

    setState(() => _loading = false);
    _userController.clear();
    _passController.clear();
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            color: Colors.grey[900],
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Welcome',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _userController,
                      decoration:
                      const InputDecoration(labelText: 'Username'),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passController,
                      decoration:
                      const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 18),
                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                        onPressed: _login, child: const Text('Sign in')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
