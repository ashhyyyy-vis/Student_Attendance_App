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
    // Load saved countdown time
    _loadCountdown();
    
    // Save current route to persist on app restart (only once)
    if (!_routeSaved) {
      _saveCurrentRoute();
      _routeSaved = true;
    }
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_countdown > 0) {
        setState(() {
          _countdown--;
          _saveCountdown(); // Save countdown every second
        });
      } else {
        timer.cancel();
        _clearCountdown(); // Clear countdown when done
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }
  
  void _loadCountdown() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCountdown = prefs.getInt('success_countdown');
    final savedTime = prefs.getInt('success_countdown_time');
    
    if (savedCountdown != null && savedTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds = ((now - savedTime) / 1000).floor();
      
      // Calculate remaining countdown, but don't go below 0
      setState(() {
        _countdown = (savedCountdown - elapsedSeconds).clamp(0, 90);
      });
    }
  }
  
  void _saveCountdown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('success_countdown', _countdown);
    await prefs.setInt('success_countdown_time', DateTime.now().millisecondsSinceEpoch);
  }
  
  void _clearCountdown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('success_countdown');
    await prefs.remove('success_countdown_time');
  }
  
  void _saveCurrentRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_route', '/success');
    await prefs.setInt('last_route_time', DateTime.now().millisecondsSinceEpoch);
    
    // Clear the route after a short delay to prevent restoration conflicts
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        prefs.remove('last_route');
        prefs.remove('last_route_time');
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
