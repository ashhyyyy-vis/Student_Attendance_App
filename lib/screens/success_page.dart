import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});
  @override
  Widget build(BuildContext context) {
    final user = globals.currentUser ?? 'Student';
    return Scaffold(
      appBar: AppBar(title: Text('Success')),
      body: Center(
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
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
