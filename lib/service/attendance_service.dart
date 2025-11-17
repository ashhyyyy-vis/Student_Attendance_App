import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../utils/globals.dart' as globals;

class AttendanceService {
  
  // Fetch attendance from API
  static Future<void> fetchAttendance() async {
  try {
    final token = await AuthService.getToken();
    final id = await AuthService.getID();
    final response = await http.get(
      Uri.parse('${globals.baseurl}/api/report/student/${id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (kDebugMode) {
      print('Attendance API Response: ${response.body}');
    }

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['attendance'] != null) {
        final attendanceList = responseData['attendance'] as List;
        // Clear existing data to avoid duplicates
        globals.attendanceData.clear();
        // Add new data
        for (var item in attendanceList) {
          globals.attendanceData.add(globals.AttendanceData.fromJson(item));
        }
      } else {
        throw Exception('Invalid response format or no attendance data');
      }
    } else {
      throw Exception(
        'Failed to load attendance. Status code: ${response.statusCode}'
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error in fetchAttendance: $e');
    }
    rethrow;
  }
}
}