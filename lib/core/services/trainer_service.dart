import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class TrainerService {
  static const String baseUrl = "http://gym.sandbox.pk";
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
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true, 'stats': data['stats']};
      if (response.statusCode == 401 || response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Assigned Members (includes diet_plan info) ─────────────
  static Future<Map<String, dynamic>> getMyMembers({String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/trainer/members').replace(
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
      );
      final response = await http.get(uri, headers: _headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true, 'members': data['members']};
      if (response.statusCode == 401 || response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Get Single Member by ID ────────────────────────────────
  static Future<Map<String, dynamic>> getMemberById(int memberId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/members/$memberId'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'member': data['member']};
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
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true, 'schedule': data['schedule']};
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Recent Activity ────────────────────────────────────────
  static Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/activity'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true, 'activity': data['activity']};
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
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true, 'profile': data['profile']};
      if (response.statusCode == 401 || response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Update Profile ─────────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    required String specialization,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trainer/profile'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'phone': phone,
          'specialization': specialization,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final user = box.read('user') ?? {};
        user['name'] = name;
        box.write('user', user);
        return {'success': true};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Change Password ────────────────────────────────────────
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trainer/change-password'),
        headers: _headers,
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true};
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════
  // DIET PLAN METHODS
  // ══════════════════════════════════════════════════════════

  // ── Get all diet plans ─────────────────────────────────────
  static Future<Map<String, dynamic>> getDietPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/diet-plans'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'plans': data['plans'],
          'stats': data['stats'],
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Get single diet plan ───────────────────────────────────
  static Future<Map<String, dynamic>> getDietPlan(int planId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/diet-plans/$planId'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true, 'plan': data['plan']};
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Create diet plan ───────────────────────────────────────
  static Future<Map<String, dynamic>> createDietPlan({
    required int memberId,
    required String title,
    required String assignmentDate,
    required String breakfast,
    required String lunch,
    required String dinner,
    required String snacks,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trainer/diet-plans'),
        headers: _headers,
        body: json.encode({
          'member_id': memberId,
          'title': title,
          'assignment_date': assignmentDate,
          'breakfast': breakfast,
          'lunch': lunch,
          'dinner': dinner,
          'snacks': snacks,
        }),
      );
      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true, 'plan_id': data['plan_id']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Update diet plan ───────────────────────────────────────
  static Future<Map<String, dynamic>> updateDietPlan({
    required int planId,
    required int memberId,
    required String title,
    required String assignmentDate,
    required String breakfast,
    required String lunch,
    required String dinner,
    required String snacks,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trainer/diet-plans/$planId'),
        headers: _headers,
        body: json.encode({
          'member_id': memberId,
          'title': title,
          'assignment_date': assignmentDate,
          'breakfast': breakfast,
          'lunch': lunch,
          'dinner': dinner,
          'snacks': snacks,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true};
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Delete diet plan ───────────────────────────────────────
  static Future<Map<String, dynamic>> deleteDietPlan(int planId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/trainer/diet-plans/$planId'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true)
        return {'success': true};
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
}
