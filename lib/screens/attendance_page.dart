import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<globals.AttendanceData> attendanceList = globals.attendanceData;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Attendance')),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(globals.wallpaperImage), // 🔥 Your background image
            fit: BoxFit.cover,                 // Makes it fill the screen
            opacity: 0.25,                     // Slight dim so text is readable
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attendance Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: attendanceList.isEmpty
                    ? const Center(
                        child: Text('No attendance records found'),
                      )
                    : ListView.builder(
                        itemCount: attendanceList.length,
                        itemBuilder: (context, index) {
                          final data = attendanceList[index];
                          final percent = data.total == 0
                              ? 0.0
                              : (data.present / data.total) * 100;

                          return Card(
                            color: Colors.grey[900]?.withOpacity(0.85), // for readability
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.courseName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              data.courseCode,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${percent.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${data.present} / ${data.total} classes',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    //Used for progress bar
                                    value: data.total == 0
                                        ? 0.0
                                        : data.present / data.total,
                                    minHeight: 10,
                                    backgroundColor: Colors.black26,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
