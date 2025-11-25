import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart' as http_testing;
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';
import '../lib/service/auth_service.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    AuthService.storageForTests = mockStorage;
  });

  test('successful login saves token and id and returns true', () async {
    final fakeResponse = {
      "data": {
        "token": "abc123",
        "user": {
          "id": "10",
          "firstName": "Jane",
          "lastName": "Doe",
          "MIS": "12345",
          "semester": 5,
          "department": "ECE",
          "class": {"name": "TE-A"},
          "image": "x.png"
        }
      }
    };

    AuthService.httpClientForTests = http_testing.MockClient((req) async {
      return http.Response(jsonEncode(fakeResponse), 200);
    });

    when(mockStorage.write(key: 'auth_token', value: anyNamed('value')))
        .thenAnswer((_) async => null);

    when(mockStorage.write(key: 'auth_id', value: anyNamed('value')))
        .thenAnswer((_) async => null);

    final result = await AuthService.login("a@b.com", "pass");

    expect(result, true);

    verify(mockStorage.write(key: 'auth_token', value: 'abc123')).called(1);
    verify(mockStorage.write(key: 'auth_id', value: '10')).called(1);
  });

  test('failed login throws', () async {
    AuthService.httpClientForTests = http_testing.MockClient((req) async {
      return http.Response(jsonEncode({"message": "Invalid"}), 401);
    });

    expect(() => AuthService.login("x", "y"), throwsException);
  });
}
