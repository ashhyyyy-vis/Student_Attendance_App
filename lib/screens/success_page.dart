import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import 'dart:async';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});
  
  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  bool _canGoBack = false;
  
  @override
  void initState() {
    super.initState();
    // Allow back navigation after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _canGoBack = true;
        });
        // Auto-redirect to home after 3 seconds
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final user = globals.currentUser ?? 'Student';
    return WillPopScope(
      onWillPop: () async {
        return _canGoBack;
      },
      child: Scaffold(
        body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(globals.wallpaperImage),
            fit: BoxFit.cover,
            opacity: 0.25,
          ),
        ),
        child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 84, color: Colors.greenAccent),
              SizedBox(height: 12),
              Text('Attendance marked!', style: TextStyle(fontSize: 22)),
              SizedBox(height: 8),
              Text('Thanks, $user. Your presence has been recorded.'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _canGoBack ? () {
                  Navigator.pushReplacementNamed(context, '/home');
                } : null,
                child: Text('Back to Home'),
              ),
              if (!_canGoBack)
                Text(
                  'Please wait 3 seconds...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  }
}
