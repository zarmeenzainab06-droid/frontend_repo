import 'dart:convert';
import 'package:http/http.dart' as http;

class MealService {
  static Future<void> addMeal({
    required String name,
    required int calories,
    required String category,
  }) async {
    final url = Uri.parse("https://your-api.com/meals");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "calories": calories,
        "category": category,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add meal");
    }
  }
}