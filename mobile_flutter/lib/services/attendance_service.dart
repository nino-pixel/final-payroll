import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class AttendanceService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getAttendanceStatus() async {
    final token = await _storage.read(key: 'auth_token');
    final employeeData = await _storage.read(key: 'employee_data');
    final employee = jsonDecode(employeeData!);

    final response = await http.get(
      Uri.parse(
          '$baseUrl/mobile/attendance/status?employee_id=${employee['employee_id']}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return jsonDecode(response.body)['data'];
  }

  Future<void> timeIn() async {
    final token = await _storage.read(key: 'auth_token');
    final employeeData = await _storage.read(key: 'employee_data');
    final employee = jsonDecode(employeeData!);

    await http.post(
      Uri.parse('$baseUrl/mobile/attendance/mark'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'employee_id': employee['employee_id'],
        'type': 'in',
        'time': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> timeOut() async {
    final token = await _storage.read(key: 'auth_token');
    final employeeData = await _storage.read(key: 'employee_data');
    final employee = jsonDecode(employeeData!);

    await http.post(
      Uri.parse('$baseUrl/mobile/attendance/mark'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'employee_id': employee['employee_id'],
        'type': 'out',
        'time': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<List<Map<String, dynamic>>> getAttendanceHistory() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final employeeData = await _storage.read(key: 'employee_data');
      final employee = jsonDecode(employeeData!);

      final response = await http.get(
        Uri.parse(
            '$baseUrl/mobile/attendance/history?employee_id=${employee['employee_id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load attendance history: ${response.body}');
      }

      final data = jsonDecode(response.body);
      if (data['data'] == null) {
        return [];
      }

      return List<Map<String, dynamic>>.from(data['data']);
    } catch (e) {
      print('Error fetching attendance history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentStatus() async {
    final token = await _storage.read(key: 'auth_token');
    final employeeData = await _storage.read(key: 'employee_data');
    final employee = jsonDecode(employeeData!);

    final response = await http.get(
      Uri.parse(
          '$baseUrl/mobile/attendance/status?employee_id=${employee['employee_id']}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load current status');
    }

    final data = jsonDecode(response.body);
    return data['data'];
  }

  Future<void> markAttendance(String type) async {
    if (type == 'time_in') {
      await timeIn();
    } else if (type == 'time_out') {
      await timeOut();
    }
  }
}
