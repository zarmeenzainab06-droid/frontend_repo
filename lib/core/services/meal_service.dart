import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class MealService {
  static const String baseUrl = "http://localhost:3000";
  static final box = GetStorage();

  // Add meal
  static Future<Map<String, dynamic>> addMeal({
    required String foodName,
    required int calories,
    required String mealType,
    String? servingSize,
  }) async {
    try {
      final token = box.read('token');

      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/meals/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'food_name': foodName,
          'calories': calories,
          'meal_type': mealType,
          'serving_size': servingSize,
        }),
      );

      final data = json.decode(response.body);
      print('Add meal response: $data');

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'meal_id': data['meal_id']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      print('Add meal error: $e');
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // Get today's meals
  static Future<Map<String, dynamic>> getTodayMeals() async {
    try {
      final token = box.read('token');

      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/meals/today'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      print('Get meals response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'meals': data['meals'],
          'total_calories': data['total_calories'],
        };
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      print('Get meals error: $e');
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // Delete meal
  static Future<Map<String, dynamic>> deleteMeal(int mealId) async {
    try {
      final token = box.read('token');

      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/meals/$mealId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      print('Delete meal response: $data');

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      print('Delete meal error: $e');
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
}
