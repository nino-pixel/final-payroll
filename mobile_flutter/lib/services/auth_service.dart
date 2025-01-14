import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter/config/app_config.dart';
import 'dart:developer' as developer;

class AuthService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      developer.log('Attempting login', name: 'AuthService');
      developer.log('URL: $baseUrl/mobile/login', name: 'AuthService');

      final response = await http.post(
        Uri.parse('$baseUrl/mobile/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      developer.log('Response status: ${response.statusCode}',
          name: 'AuthService');
      developer.log('Response body: ${response.body}', name: 'AuthService');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        developer.log('Login successful', name: 'AuthService');
        await _storage.write(key: 'auth_token', value: data['token']);
        await _storage.write(
            key: 'employee_data', value: jsonEncode(data['employee']));

        return {
          'success': true,
          'data': data,
          'employee': data['employee'],
        };
      }

      developer.log('Login failed: ${data['message']}', name: 'AuthService');
      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
      };
    } catch (e, stackTrace) {
      developer.log(
        'Login error: $e',
        name: 'AuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'auth_token');

      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/mobile/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }
    } finally {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'employee_data');
    }
  }

  Future<Map<String, dynamic>?> getStoredEmployeeData() async {
    final employeeJson = await _storage.read(key: 'employee_data');
    if (employeeJson != null) {
      return jsonDecode(employeeJson);
    }
    return null;
  }

  Future<bool> validateToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/mobile/validate-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
