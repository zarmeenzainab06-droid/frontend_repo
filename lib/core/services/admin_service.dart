import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class AdminService {
  static const String baseUrl = "http://127.0.0.1:3000";
  static final box = GetStorage();

  // ✅ Helper - gets auth header with token
  static Map<String, String> get _headers {
    final token = box.read('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ✅ GET all foods
  static Future<Map<String, dynamic>> getAllFoods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/foods'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'foods': data['foods']};
      } else if (response.statusCode == 403) {
        Get.offAllNamed('/login'); // token expired or not admin
        return {'success': false, 'message': 'Access denied'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load foods',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ✅ POST add new food
  static Future<Map<String, dynamic>> addFood({
    required String name,
    required int calories,
    required String portion,
    required bool isDiabeticSafe,
    required bool isBpSafe,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/foods'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'calories': calories,
          'portion': portion,
          'is_diabetic_safe': isDiabeticSafe,
          'is_bp_safe': isBpSafe,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add food',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ✅ PUT update food
  static Future<Map<String, dynamic>> updateFood({
    required int foodId,
    required String name,
    required int calories,
    required String portion,
    required bool isDiabeticSafe,
    required bool isBpSafe,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/foods/$foodId'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'calories': calories,
          'portion': portion,
          'is_diabetic_safe': isDiabeticSafe,
          'is_bp_safe': isBpSafe,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update food',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ✅ DELETE food
  static Future<Map<String, dynamic>> deleteFood(int foodId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/foods/$foodId'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete food',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
}
