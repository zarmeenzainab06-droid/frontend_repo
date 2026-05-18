import 'dart:io';
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

  static Map<String, String> get _authHeader {
    final token = box.read('token');
    return {'Authorization': 'Bearer $token'};
  }

  // ── Dashboard Stats ────────────────────────────────────────
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

  // ── Get Trainers ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getTrainers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/trainers'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'trainers': data['trainers']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Get All Packages ───────────────────────────────────────
  static Future<Map<String, dynamic>> getPackages({
    bool activeOnly = false,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/admin/packages',
      ).replace(queryParameters: activeOnly ? {'active': '1'} : null);
      final response = await http.get(uri, headers: _headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'packages': data['packages']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Create Package ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createPackage(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/packages'),
        headers: _headers,
        body: json.encode(data),
      );
      final res = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          res['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'message': res['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Update Package ─────────────────────────────────────────
  static Future<Map<String, dynamic>> updatePackage({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/packages/$id'),
        headers: _headers,
        body: json.encode(data),
      );
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'message': res['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Delete Package ─────────────────────────────────────────
  static Future<Map<String, dynamic>> deletePackage(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/packages/$id'),
        headers: _headers,
      );
      final res = json.decode(response.body);
      if (response.statusCode == 200 && res['success'] == true) {
        return {'success': true};
      }
      return {'success': false, 'message': res['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Create Member ──────────────────────────────────────────
  static Future<Map<String, dynamic>> createMember({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String trainingSlot,
    String? trainerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/members'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          'training_slot': trainingSlot,
          if (trainerId != null) 'trainer_id': int.tryParse(trainerId),
          'password': 'GymSwift@123',
        }),
      );
      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true, 'user_id': data['user_id']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Update Member ──────────────────────────────────────────
  static Future<Map<String, dynamic>> updateMember({
    required int userId,
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String trainingSlot,
    String? trainerId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/members/$userId'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          'training_slot': trainingSlot,
          if (trainerId != null) 'trainer_id': int.tryParse(trainerId),
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

  // ── Assign Membership ──────────────────────────────────────
  // Uses multipart when screenshot file is present (online payment)
  // Uses JSON when cash payment (no file)
  static Future<Map<String, dynamic>> assignMembership({
    required int userId,
    required int packageId,
    required String startDate,
    required String endDate,
    required double amount,
    required String paymentMethod,
    File? screenshotFile,
  }) async {
    try {
      final token = box.read('token');
      final uri = Uri.parse('$baseUrl/admin/members/$userId/membership');

      if (screenshotFile != null && paymentMethod == 'online') {
        // ── Multipart request (with screenshot) ─────────────
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['package_id'] = packageId.toString()
          ..fields['start_date'] = startDate
          ..fields['end_date'] = endDate
          ..fields['amount'] = amount.toString()
          ..fields['payment_method'] = paymentMethod
          ..files.add(
            await http.MultipartFile.fromPath(
              'screenshot',
              screenshotFile.path,
            ),
          );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final data = json.decode(response.body);

        if (response.statusCode == 201 && data['success'] == true) {
          return {'success': true};
        }
        return {'success': false, 'message': data['message'] ?? 'Failed'};
      } else {
        // ── JSON request (cash payment) ──────────────────────
        final response = await http.post(
          uri,
          headers: _headers,
          body: json.encode({
            'package_id': packageId,
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
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Delete Member ──────────────────────────────────────────
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
