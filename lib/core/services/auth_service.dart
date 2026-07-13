import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class AuthService {
  static const String baseUrl = "http://localhost:3000";
  static final box = GetStorage();

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // ── Login ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: json.encode({'email': email, 'password': password}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (data['token'] != null) {
          box.write('token', data['token']);
          box.write('user', data['user']);
          box.write('role', data['user']['role']);
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Register ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: _headers,
        body: json.encode(body),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  static void logout() {
    box.remove('token');
    box.remove('user');
    box.remove('role');
    box.remove('isLoggedIn');
  }

  // ── Get Profile ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = box.read('token');
      if (token == null) return {'success': false, 'message': 'No token'};
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message']};
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
