import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ProfileService {
  static const timeout = Duration(seconds: 30);

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}/profile'),
            headers: await AppConfig.getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> requestUpdate(Map<dynamic, dynamic> changes) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/profile/update-request'),
            headers: await AppConfig.getHeaders(),
            body: json.encode({'changes': Map<String, dynamic>.from(changes)}),
          )
          .timeout(timeout);

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }
      if (response.statusCode != 200) {
        throw Exception(
            'Server error: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> uploadProfilePicture(String filePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiUrl}/profile/upload-picture'),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'profile_picture',
      filePath,
    ));

    final headers = await AppConfig.getHeaders();
    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload profile picture');
    }
  }
}
