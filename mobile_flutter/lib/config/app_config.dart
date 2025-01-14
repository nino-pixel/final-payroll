import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfig {
  static const String appName = 'PayrollEmp';

  // For web browser
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api';
  static const String apiUrl = apiBaseUrl; // For backward compatibility

  static Future<Map<String, String>> getHeaders() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }
}
