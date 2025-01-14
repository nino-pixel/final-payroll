import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class LeaveService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final _storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getLeaveBalances() async {
    final token = await _storage.read(key: 'auth_token');
    final employeeData = await _storage.read(key: 'employee_data');
    final employee = jsonDecode(employeeData!);

    final response = await http.get(
      Uri.parse(
          '$baseUrl/mobile/leave/balances?employee_id=${employee['employee_id']}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load leave balances');
    }

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  }

  Future<List<Map<String, dynamic>>> getLeaveHistory() async {
    final token = await _storage.read(key: 'auth_token');
    final employeeData = await _storage.read(key: 'employee_data');
    final employee = jsonDecode(employeeData!);

    final response = await http.get(
      Uri.parse(
          '$baseUrl/mobile/leave/history?employee_id=${employee['employee_id']}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to load leave history');
    }

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  }

  Future<void> submitLeaveRequest(Map<String, dynamic> leaveData) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final employeeData = await _storage.read(key: 'employee_data');
      final employee = jsonDecode(employeeData!);

      final response = await http.post(
        Uri.parse('$baseUrl/mobile/leave/request'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'employee_id': employee['employee_id'],
          'leave_type_id': leaveData['leave_type_id'],
          'start_date': leaveData['start_date'],
          'end_date': leaveData['end_date'],
          'total_days': leaveData['total_days'],
          'reason': leaveData['reason'],
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        print('Leave request error: ${response.body}');
        throw Exception(error['message'] ?? 'Failed to submit leave request');
      }
    } catch (e) {
      rethrow;
    }
  }
}
