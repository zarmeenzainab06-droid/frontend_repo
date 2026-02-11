import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // IMPORTANT: Change this to your computer's IP address if testing on physical device
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use localhost
  // For Physical Device: use your computer's IP (e.g., 192.168.1.100)
  static const String baseUrl = 'http://localhost:3000/api/auth';

  // For Android Emulator, use this instead:
  // static const String baseUrl = 'http://10.0.2.2:3000/api/auth';

  // ========================================
  // REGISTER (CREATE)
  // ========================================
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    int? age,
    double? weight,
    double? height,
    String? gender,
    bool isDiabetic = false,
    bool hasHighBp = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'age': age,
          'weight': weight,
          'height': height,
          'gender': gender,
          'is_diabetic': isDiabetic,
          'has_high_bp': hasHighBp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success']) {
        // Save token to local storage
        await _saveToken(data['token']);

        // Parse user data
        final user = User.fromJson(data['user']);

        return {
          'success': true,
          'message': data['message'],
          'user': user,
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please check your internet connection.',
        'error': e.toString(),
      };
    }
  }

  // ========================================
  // LOGIN (READ)
  // ========================================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Save token to local storage
        await _saveToken(data['token']);

        // Parse user data
        final user = User.fromJson(data['user']);

        return {
          'success': true,
          'message': data['message'],
          'user': user,
          'token': data['token'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please check your internet connection.',
        'error': e.toString(),
      };
    }
  }

  // ========================================
  // Get Profile (Bonus - READ with token)
  // ========================================
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated. Please login.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        final user = User.fromJson(data['user']);

        return {'success': true, 'user': user};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error',
        'error': e.toString(),
      };
    }
  }
  // Add these methods to your existing AuthService class

  // ========================================
  // UPDATE PROFILE (UPDATE)
  // ========================================
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String fullName,
    int? age,
    double? weight,
    double? height,
    bool isDiabetic = false,
    bool hasHighBp = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'age': age,
          'weight': weight,
          'height': height,
          'is_diabetic': isDiabetic,
          'has_high_bp': hasHighBp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please check your internet connection.',
        'error': e.toString(),
      };
    }
  }

  // ========================================
  // DELETE ACCOUNT (DELETE)
  // ========================================
  Future<Map<String, dynamic>> deleteAccount({required int userId}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Delete failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error. Please check your internet connection.',
        'error': e.toString(),
      };
    }
  }

  // ========================================
  // Logout
  // ========================================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ========================================
  // Check if user is logged in
  // ========================================
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // ========================================
  // Private Helper Methods
  // ========================================

  // Save token to local storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get token from local storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
