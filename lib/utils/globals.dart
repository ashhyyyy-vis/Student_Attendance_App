import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//library globals;
class AttendanceData {
  final String courseName;
  final String courseCode;
  final int present;
  final int total;
  
  AttendanceData({
    required this.courseName,
    required this.courseCode,
    required this.present,
    required this.total,
  });

  // Add a factory constructor to create AttendanceData from JSON
  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      courseName: json['courseName'] ?? 'Unknown Course',
      courseCode: json['courseCode']??'Unknown Course Code',
      present: json['present'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}


String? currentUser;
String? MIS;
int? semester;
String? department;
String? classs;
bool isLoggedIn = false;

bool scannedToday = false;     // prevents double-marking in same session


const String validQrPayload = "VALID_QR_123";

const String baseurl="https://situated-encouraging-object-trademarks.trycloudflare.com";

const String wallpaperImage="assets/images/wallpaperImage.jpg";
String? studentLogo;
const String userPic="assets/images/studentLogo.jpg";
const String logoSmall = "assets/images/collegeLogoSmall.png";
const String logoLarge = "assets/images/collegeLogoLarge.png";
List <AttendanceData> attendanceData = [];
