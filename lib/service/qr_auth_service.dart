import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../utils/globals.dart' as globals;
import '../service/auth_service.dart';

class QRAuthService {
  static http.Client? httpClientForTests;
  static FlutterSecureStorage? storageForTests;
  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage();
  static FlutterSecureStorage get _storage => storageForTests ?? _defaultStorage;
  static Future<Map<String, dynamic>> submitQRToken(String qrToken) async {
    try {
      // Get auth token from secure storage
      final String? token = await _storage.read(key: 'auth_token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
          'data': null
        };
      }
      debugPrint('Submitting QR token: $qrToken');
      String scannedAt=DateTime.now().millisecondsSinceEpoch.toString();
      final client = httpClientForTests ?? http.Client();
      final response = await client.post(
        Uri.parse('${globals.baseurl}/api/student/scan'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'qrToken': qrToken,
            'scannedAt': scannedAt,
            'role':"student"
          }),
        );

      debugPrint('QR submission response status: ${response.statusCode}');
      debugPrint('QR submission response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['timer'] != null) {
          final scannedAtInt = int.tryParse(scannedAt) ?? 0;
          globals.timer = (responseData['timer'] - scannedAtInt) / 1000;
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'QR token submitted successfully',
          'data': responseData['data'] ?? null
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication expired. Please login again.',
          'data': null
        };
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid QR token',
          'data': null
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit QR token. Status: ${response.statusCode}',
          'data': null
        };
      }
    } catch (e) {
      debugPrint('Error submitting QR token: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null
      };
    }
  }
}