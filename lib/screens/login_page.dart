import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import '../service/auth_service.dart';

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

  late AuthService auth;

  @override
  void initState() {
    super.initState();

    // Dependency Injected Auth Service
    auth = AuthService(
      client: http.Client(),
      storage: const FlutterSecureStorage(),
    );
  }

  void _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);
  
  try {
      final success = await auth.login(
      _userController.text.trim(),
      _passController.text,
    );

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      //modify likewise
      globals.isLoggedIn = true;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: ${e.toString()}')),
    );
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
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
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(globals.wallpaperImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      globals.logoSmall,
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _userController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      obscureText: true,
                      validator: (v) =>

                    Align(
                      alignment: Alignment.centerRight,
                    ),
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight,
                     child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: const Text(
                                  "Forgot Password",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  "Password Services under development currently.\n Please contact the admin\n admin@iitp.ac.in",
                                  style: TextStyle(color: Colors.white),
                                ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "Close",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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
