import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class AdminService {
  static const String baseUrl = "http://gym.sandbox.pk";
  static final box = GetStorage();

  static Map<String, String> get _headers {
    final token = box.read('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Get All Slots ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAllSlots({String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/slots').replace(
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
      );
      final response = await http.get(uri, headers: _headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'slots': data['slots']};
      } else if (response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Get Slot By ID ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getSlotById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/slots/$id'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'slot': data['slot']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Get Slot Members ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getSlotMembers(int slotId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/slots/$slotId/members'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'members': data['members']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Create Slot ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createSlot({
    required String name,
    required String startTime,
    required String endTime,
    required int capacity,
    required String status,
    String scheduleDays = 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', // ← ADD
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/slots'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'start_time': startTime,
          'end_time': endTime,
          'capacity': capacity,
          'status': status,
          'schedule_days': scheduleDays, // ← ADD
        }),
      );
      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Update Slot ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateSlot({
    required int id,
    required String name,
    required String startTime,
    required String endTime,
    required int capacity,
    required String status,
    String scheduleDays = 'Mon,Tue,Wed,Thu,Fri,Sat,Sun', // ← ADD
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/slots/$id'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'start_time': startTime,
          'end_time': endTime,
          'capacity': capacity,
          'status': status,
          'schedule_days': scheduleDays, // ← ADD
        }),
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

  // ── Delete Slot ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteSlot(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/slots/$id'),
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
