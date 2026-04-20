import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class AdminService {
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
  // Returns: { success, stats: { totalMembers, active, expired, pendingPayments } }
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'stats': data['stats']};
      } else if (response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Recent Activity ────────────────────────────────────────
  // Returns: { success, activity: [ { memberName, action, status, timeAgo } ] }
  static Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/activity'),
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

  // ── All Members ────────────────────────────────────────────
  // Returns: { success, members: [ { id, name, email, gender, membership_status, plan, end_date } ] }
  static Future<Map<String, dynamic>> getAllMembers({String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/members').replace(
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
      );
      final response = await http.get(uri, headers: _headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'members': data['members']};
      } else if (response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Add Membership to existing member ─────────────────────
  static Future<Map<String, dynamic>> assignMembership({
    required int userId,
    required String plan, // e.g. 'monthly', 'quarterly', 'yearly'
    required String startDate, // 'YYYY-MM-DD'
    required String endDate,
    required double amount,
    required String paymentMethod, // 'cash', 'card', 'online'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/members/$userId/membership'),
        headers: _headers,
        body: json.encode({
          'plan': plan,
          'start_date': startDate,
          'end_date': endDate,
          'amount': amount,
          'payment_method': paymentMethod,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Delete member ──────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteMember(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/members/$userId'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
}
