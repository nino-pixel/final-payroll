import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class PayslipService {
  final String baseUrl = AppConfig.apiBaseUrl;
  final _storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getPayslips() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final employeeData = await _storage.read(key: 'employee_data');
      final employee = jsonDecode(employeeData!);

      final response = await http.get(
        Uri.parse(
            '$baseUrl/mobile/payroll/payment-history?employee_id=${employee['employee_id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load payslips');
      }

      final data = jsonDecode(response.body);

      // Add debug print to check the response
      print('Payslip data: $data');

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error in getPayslips: $e'); // Debug print
      throw Exception('Failed to load payslips: $e');
    }
  }
}
