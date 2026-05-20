import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class TrainerService {
  static const String baseUrl = "http://127.0.0.1:3000";
  static final box = GetStorage();

  static Map<String, String> get _headers {
    final token = box.read('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Dashboard Stats ────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/stats'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'stats': data['stats']};
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Assigned Members ───────────────────────────────────────
  static Future<Map<String, dynamic>> getMyMembers({String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/trainer/members').replace(
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
      );
      final response = await http.get(uri, headers: _headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'members': data['members']};
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Today's Schedule ───────────────────────────────────────
  static Future<Map<String, dynamic>> getTodaySchedule() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/schedule/today'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'schedule': data['schedule']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Recent Member Activity ─────────────────────────────────
  static Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/activity'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'activity': data['activity']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Trainer Profile ────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/profile'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'profile': data['profile']};
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
}
