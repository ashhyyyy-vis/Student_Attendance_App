import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/scan_page.dart';
import 'screens/success_page.dart';
import 'screens/attendance_page.dart';
import 'service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.isTokenValid();
  
  runApp(MyApp(
    initialRoute: isLoggedIn ? '/home' : '/',
  ));
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
    );
  }
}
