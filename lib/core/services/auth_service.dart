import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = "https://wholesaleapp.sandbox.pk/api"; // Changed for Chrome

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'), // Correct ✅
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);
      // print('Login response: $data');

      if (response.statusCode == 200 && data['message'] == 'Login successful') {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      // print('Login error: $e');
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> body,
  ) async {
    try {
      // print('Sending registration data: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/signup'), // Changed to /signup ✅
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);
      // print('Register response: $data');

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      // print('Register error: $e');
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
}
