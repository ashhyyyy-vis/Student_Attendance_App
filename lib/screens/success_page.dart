import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/globals.dart' as globals;
import 'dart:async';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});
  
  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  bool _canGoBack = false;
  bool _routeSaved = false;
  final double timer=globals.timer;
  int _countdown = 90;
  
  @override
  void initState() {
    super.initState();
    // Save current route to persist on app restart (only once)
    if (!_routeSaved) {
      _saveCurrentRoute();
      _routeSaved = true;
    }
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _canGoBack = true;
            timer.cancel();
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      }
    });
  }
  
  void _saveCurrentRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_route', '/success');
    await prefs.setInt('last_route_time', DateTime.now().millisecondsSinceEpoch);
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
              if (!_canGoBack)
                Text(
                  'Redirecting in $_countdown seconds...',
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
