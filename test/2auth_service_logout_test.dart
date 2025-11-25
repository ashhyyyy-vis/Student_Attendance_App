import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';
import '../lib/service/auth_service.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    AuthService.storageForTests = mockStorage;
  });

  test('logout clears token and id', () async {
    when(mockStorage.delete(key: 'auth_token'))
        .thenAnswer((_) async => null);

    when(mockStorage.delete(key: 'auth_id'))
        .thenAnswer((_) async => null);

    await AuthService.logout();

    verify(mockStorage.delete(key: 'auth_token')).called(1);
    verify(mockStorage.delete(key: 'auth_id')).called(1);
  });
}
