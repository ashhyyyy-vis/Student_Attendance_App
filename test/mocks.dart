import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {}
