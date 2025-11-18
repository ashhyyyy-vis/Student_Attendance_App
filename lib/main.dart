import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/scan_page.dart';
import 'screens/success_page.dart';
import 'screens/attendance_page.dart';
import 'service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.isTokenValid();
  
  String initialRoute = '/';
  if (isLoggedIn) {
    initialRoute = '/home';
  }
  
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/scan': (context) => ScanPage(),
        '/success': (context) => SuccessPage(),
        '/attendance': (context) => AttendancePage(),
      },
      onGenerateRoute: (settings) {
        // Save the current route when navigating (except success page which handles it itself)
        if (settings.name != null && settings.name != '/' && settings.name != '/success') {
          _saveCurrentRoute(settings.name!);
        }
        return null;
      },
    );
  }
  
  static void _saveCurrentRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_route', route);
    await prefs.setInt('last_route_time', DateTime.now().millisecondsSinceEpoch);
  }
}
