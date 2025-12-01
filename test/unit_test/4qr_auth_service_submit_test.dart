import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart' as http_testing;
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';
import 'package:StudentApp/service/qr_auth_service.dart';
import 'package:StudentApp/service/auth_service.dart'; // For globals if needed

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    QRAuthService.storageForTests = mockStorage;
  });

  tearDown(() {
    QRAuthService.httpClientForTests = null;
    QRAuthService.storageForTests = null;
  });

  test('successful QR submit returns success true', () async {
    // Return a fake token
    when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => "TOKEN123");

    // Fake 200 API response
    QRAuthService.httpClientForTests = http_testing.MockClient((req) async {
      return http.Response(jsonEncode({
        "message": "Marked Present",
        "data": {"status": "present"},
        "timer": 5000
      }), 200);
    });

    final result = await QRAuthService.submitQRToken("QR123");

    expect(result['success'], true);
    expect(result['message'], "Marked Present");
    expect(result['data']['status'], "present");
  });

  test('missing token returns auth error', () async {
    when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

    final result = await QRAuthService.submitQRToken("QR123");

    expect(result['success'], false);
    expect(result['message'], 'Authentication token not found');
  });

  test('401 returns expired message', () async {
    when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => "TOKEN123");

    QRAuthService.httpClientForTests = http_testing.MockClient((req) async {
      return http.Response("", 401);
    });

    final result = await QRAuthService.submitQRToken("QR123");

    expect(result['success'], false);
    expect(result['message'], 'Authentication expired. Please login again.');
  });

  test('400 returns invalid qr message', () async {
    when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => "TOKEN123");

    QRAuthService.httpClientForTests = http_testing.MockClient((req) async {
      return http.Response(jsonEncode({"message": "Invalid Token"}), 400);
    });

    final result = await QRAuthService.submitQRToken("QR123");

    expect(result['success'], false);
    expect(result['message'], 'Invalid Token');
  });
}
