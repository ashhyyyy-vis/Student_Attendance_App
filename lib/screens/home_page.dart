import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;

class HomePage extends StatelessWidget {

  const HomePage({super.key});
  void _ensureLoggedIn(BuildContext context) {
    if (!globals.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoggedIn(context);
    final user = globals.currentUser ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              globals.isLoggedIn = false;
              globals.currentUser = null;
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            Text('Hello, $user',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // reset scannedToday when entering scanner so user can try again later
                globals.scannedToday = false;
                Navigator.pushNamed(context, '/scan');
              },
              icon: Icon(Icons.qr_code_scanner),
              label: Text('Scan QR for Attendance'),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/attendance');
              },
              icon: Icon(Icons.bar_chart),
              label: Text('Check Attendance'),
            ),
            SizedBox(height: 18),
            // Quick summary
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: Text('Attendance summary'),
                subtitle: Text(
                    '${globals.attendanceCount} / ${globals.totalDays} days'),
                trailing: Text(
                    '${((globals.attendanceCount / globals.totalDays) * 100).toStringAsFixed(1)}%'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
