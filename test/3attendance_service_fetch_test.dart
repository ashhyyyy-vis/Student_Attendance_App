import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart' as http_testing;
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';
import '../lib/service/auth_service.dart';
import '../lib/service/attendance_service.dart';
import '../lib/utils/globals.dart' as globals;

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    AuthService.storageForTests = mockStorage;

    // Reset attendance data before each test
    globals.attendanceData.clear();
  });

  test('fetchAttendance loads and parses attendance data successfully', () async {
    // Fake token & ID
    when(mockStorage.read(key: 'auth_token'))
        .thenAnswer((_) async => 'mock_token');
    when(mockStorage.read(key: 'auth_id'))
        .thenAnswer((_) async => '42');

    // Mock API response
    final fakeResponse = {
      "success": true,
      "attendance": [
        {
          "courseName": "Maths",
          "courseCode": "M101",
          "present": 20,
          "total": 25
        },
        {
          "courseName": "Physics",
          "courseCode": "P202",
          "present": 18,
          "total": 22
        }
      ]
    };

    AttendanceService.httpClientForTests = http_testing.MockClient((req) async {
      expect(req.url.toString().contains("/api/report/student/42"), true);
      expect(req.headers["Authorization"], "Bearer mock_token");

      return http.Response(jsonEncode(fakeResponse), 200);
    });

    await AttendanceService.fetchAttendance();

    // Verify attendanceData populated
    expect(globals.attendanceData.length, 2);

    expect(globals.attendanceData[0].courseName, 'Maths');
    expect(globals.attendanceData[0].courseCode, 'M101');

    expect(globals.attendanceData[1].courseName, 'Physics');
    expect(globals.attendanceData[1].courseCode, 'P202');
  });

  test('fetchAttendance throws on non-200', () async {
    when(mockStorage.read(key: 'auth_token'))
        .thenAnswer((_) async => 'mock_token');
    when(mockStorage.read(key: 'auth_id'))
        .thenAnswer((_) async => '42');

    AttendanceService.httpClientForTests = http_testing.MockClient((req) async {
      return http.Response('Error', 500);
    });

    expect(() => AttendanceService.fetchAttendance(), throwsException);
  });
}
