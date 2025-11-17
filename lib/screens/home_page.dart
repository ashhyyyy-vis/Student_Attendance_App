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
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    elevation: 8,  // Added shadow for depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),  // More rounded corners
    ),
    child: Container(
      padding: const EdgeInsets.only(top:70,bottom:70,left:15),  // Increased padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 50,  // Increased from 40
            backgroundColor: Colors.grey[300],
            backgroundImage: globals.studentLogo != null 
                ? NetworkImage(globals.studentLogo!)
                : AssetImage(globals.userPic),
            onBackgroundImageError: (exception, stackTrace) {
            },
          ),
          const SizedBox(width: 24),  // Increased spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  globals.currentUser ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 22,  // Increased from 16
                    fontWeight: FontWeight.bold,
                    //color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.badge, 'MIS: ${globals.MIS ?? 'N/A'}'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.school, globals.department ?? 'N/A'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, globals.classs ?? 'N/A'),
                const SizedBox(height:8),
                _buildInfoRow(Icons.class_, 'Semester ${globals.semester ?? 'N/A'}'),

              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper method to create consistent info rows with icons
Widget _buildInfoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.blue[700]),
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
    return ElevatedButton.icon(
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
      label: Text(isLoading ? 'Fetching Data...' : label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Image.asset(
                    globals.logoLarge,
                    height: 100,
                    fit: BoxFit.contain,
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
