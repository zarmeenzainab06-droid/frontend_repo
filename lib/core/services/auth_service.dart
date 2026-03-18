import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = "http://localhost:3000";

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error'};
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error'};
    }
  }
}