import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class AuthService {
  static const String baseUrl = "http://gym.sandbox.pk";
  static final box = GetStorage();
  static const Map<String, String> _headers = {
    // for forget password and reset password
    'Content-Type': 'application/json',
  };

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        }, // Set content type to JSON
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);
      // print('Login response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        // ✅ SAVE TOKEN
        if (data['token'] != null) {
          box.write('token', data['token']); // Save token to local storage
          box.write('user', data['user']); // Save user data to local storage
          box.write('role', data['user']['role']); // for admin
          // print('✅ Token saved: ${data['token']}');
          // print('✅ Role saved: ${data['user']['role']}'); //  for admin
        }

        return {
          'success': true,
          'data': data,
        }; // Return the back to login screen
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
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ✅ LOGOUT - Clear token
  static void logout() {
    box.remove('token');
    box.remove('user');
  }

  // ✅ GET PROFILE (Protected route example)
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = box.read('token');

      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', //  Send token in header
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
  // ══════════════════════════════════════════════════════════
  // FORGOT PASSWORD METHODS
  // ══════════════════════════════════════════════════════════

  // ── Step 1: Send reset email ───────────────────────────────
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: _headers,
        body: json.encode({'email': email}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Step 2: Verify reset token ─────────────────────────────
  static Future<Map<String, dynamic>> verifyResetToken(
    String token,
    String email,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/verify-reset-token',
      ).replace(queryParameters: {'token': token, 'email': email});
      final response = await http.get(uri, headers: _headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'message': data['message'] ?? 'Invalid token'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Step 3: Reset password with token ─────────────────────
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: _headers,
        body: json.encode({
          'token': token,
          'email': email,
          'newPassword': newPassword,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
}
