import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;

class AttendancePage extends StatelessWidget {

  const AttendancePage({super.key});
  @override
  Widget build(BuildContext context) {
    final attended = globals.attendanceCount;
    final total = globals.totalDays;
    final percent = total == 0 ? 0.0 : (attended / total) * 100;

    return Scaffold(
      appBar: AppBar(title: Text('Your Attendance')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Attendance Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Card(
              color: Colors.grey[900],
              child: ListTile(
                title: Text('$attended / $total days attended'),
                subtitle: LinearProgressIndicator(
                  value: total == 0 ? 0.0 : attended / total,
                  minHeight: 10,
                ),
                trailing: Text('${percent.toStringAsFixed(1)}%'),
              ),
            ),
            SizedBox(height: 18),
            Text(
              globals.scannedToday
                  ? 'You have marked attendance today.'
                  : 'You have not marked attendance today.',
            ),
            SizedBox(height: 18),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back')),
          ],
        ),
      ),
    );
  }
}
