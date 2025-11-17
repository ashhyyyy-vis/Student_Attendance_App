import 'package:flutter/material.dart';
import '../utils/globals.dart' as globals;
import '../service/auth_service.dart';
import '../service/attendance_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   bool _isFetchingAttendance = false;
  @override
  void initState() {
    super.initState();
    _ensureLoggedIn();
  }

  void _ensureLoggedIn() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!globals.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),//56
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppBar(
          leading: const Icon(Icons.home),
          title: StreamBuilder<DateTime>(
            stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              return Text(
                DateFormat('MMM d, yyyy • hh:mm a').format(now),
                style: const TextStyle(fontSize: 16),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService.logout();
                if (!context.mounted) return;
                globals.isLoggedIn = false;
                globals.currentUser = null;
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
Widget _buildStudentCard() {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
    elevation: 12,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.grey.shade900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Profile picture
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 110,
              height: 110,
              color: Colors.grey[800],
              child: globals.studentLogo != null
                  ? Image.network(
                      globals.studentLogo!,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      globals.userPic,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          const SizedBox(width: 24),

          // Info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  globals.currentUser ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                _buildElegantInfo("MIS", globals.MIS),
                const SizedBox(height: 8),
                _buildElegantInfo("Department", globals.department),
                const SizedBox(height: 8),
                _buildElegantInfo("Class", globals.classs),
                const SizedBox(height: 8),
                _buildElegantInfo("Semester", globals.semester.toString()),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildElegantInfo(String label, String? value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        "$label:",
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value ?? 'N/A',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}


// Helper method to create consistent info rows with icons
Widget _buildInfoRow( String text) {
  return Row(
    children: [
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(fontSize: 16),  // Increased from 14
      ),
    ],
  );
}
  Widget _buildActionButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
  bool isLoading = false, 
}) {
  return SizedBox(
    width: 300, // Fixed width for both buttons
    child: ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
          : Icon(icon),
      label: Text(
        isLoading ? 'Fetching Data...' : label,
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      // ★ ONLY CHANGE: Background added with Stack ★
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              globals.wallpaperImage, // replace this
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              children: [
                _buildStudentCard(),
                const SizedBox(height: 20),
                _buildActionButton(
                  label: 'Scan QR for Attendance',
                  icon: Icons.qr_code_scanner,
                  onPressed: () {
                    Navigator.pushNamed(context, '/scan');
                  },
                ),
                const SizedBox(height: 20),
                _buildActionButton(
                  label: 'Check Attendance',
                  icon: Icons.bar_chart,
                  isLoading: _isFetchingAttendance, // Pass the loading state
                  onPressed: () async {
                    if (_isFetchingAttendance || !context.mounted) return;

                    setState(() {
                      _isFetchingAttendance = true;
                    });

                    try {
                      // CRUCIAL: Await the API call to ensure data is populated before navigating.
                      await AttendanceService.fetchAttendance();

                      if (context.mounted) {
                        Navigator.pushNamed(context, '/attendance');
                      }
                    } catch (e) {
                      // Optional: Add a mechanism to show an error message if the fetch fails
                      print('Attendance fetch failed: $e');
                    } finally {
                      if (context.mounted) {
                        setState(() {
                          _isFetchingAttendance = false;
                        });
                      }
                    }
                  },
                ),
                const Spacer(),
              // In the build method, replace the existing Align widget with:
                Container(
                  width: 400,
                  color: Colors.black,
                  padding: const EdgeInsets.only(left:1,right:1,top:1,bottom:1),
                  child: Center(
                    child: Image.asset(
                      globals.logoLarge,
                      height: 80,  // Slightly reduced height
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
