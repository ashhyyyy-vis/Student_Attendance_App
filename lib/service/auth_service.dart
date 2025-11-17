import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../utils/globals.dart' as globals;

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _idKey = 'auth_id';

  // Login method with enhanced error handling
  static Future<bool> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Attempting login for email: $email');
      }

      final response = await http.post(
        Uri.parse('${globals.baseurl}/api/auth/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': "student"
        }),
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Login response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check if the response has the expected structure
        if (responseData['data']?['token'] == null) {
          throw Exception('Invalid response format: Missing token');
        }

        if (responseData['data']['user']?['id'] == null) {
          
          throw Exception('Invalid response format: Missing user ID');
        }

        final token = responseData['data']['token'];
        final id = responseData['data']['user']['id'].toString();
        globals.currentUser=responseData['data']['user']['firstName']+" "+ responseData['data']['user']['lastName'];
        globals.MIS=responseData['data']['user']['MIS'];
        globals.semester=responseData['data']['user']['semester'];
        
        // Store student logo if image field is present in response
        if (responseData['data']['user']?['image'] != null) {
          globals.studentLogo = responseData['data']['user']['image'].toString();
        }
        globals.department=responseData['data']['user']['department'];
        globals.classs=responseData['data']['user']['class']['name'];
        await saveToken(token);
        await saveID(id);
        
        if (kDebugMode) {
          //
          print('Login successful for user ID: ${getID()}');
        }
        return true;
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Unknown error';
        throw Exception('Login failed: $error (Status: ${response.statusCode})');
      }
    } on TimeoutException {
      if (kDebugMode) {
        print('Login request timed out');
      }
      throw Exception('Connection timeout. Please check your internet connection.');
    } catch (e) {
      if (kDebugMode) {
        print('Error in login: $e');
      }
      rethrow;
    }
  }

  // Save JWT token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      if (kDebugMode) {
        print('Token saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
      rethrow;
    }
  }
  static Future<void> saveID(String id) async {
    try {
      await _storage.write(key: _idKey, value: id);
      if (kDebugMode) {
        print('Token saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
      rethrow;
    }
  }
  // Get JWT token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (kDebugMode) {
        print('Token ${token != null ? 'found' : 'not found'} in storage');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading token: $e');
      }
      return null;
    }
  }
  static Future<String?> getID() async {
    try {
      final id = await _storage.read(key: _idKey);
      if (kDebugMode) {
        print('ID ${id != null ? 'found' : 'not found'} in storage');
      }
      return id;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading token: $e');
      }
      return null;
    }
  }
  static Future<bool> isTokenValid() async {
  try {
    final token = await getToken();
    
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('No token found or token is empty');
      }
      return false;
    }
    return true;

  } catch (e) {
    if (kDebugMode) {
      print('Error in isTokenValid: $e');
    }
    return false;
  }
}
  // Logout
  static Future<void> logout() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _idKey);
      globals.currentUser = null;
      globals.MIS = null;
      globals.semester = null;
      globals.department = null;
      globals.isLoggedIn = false; 
      if (kDebugMode) {
        print('Logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
      rethrow;
    }
  }
}