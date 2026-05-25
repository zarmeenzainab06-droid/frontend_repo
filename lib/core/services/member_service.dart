// services/member_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:third_task/models/member_model.dart';

class MemberService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Token nikalne ka helper
  static String _getToken() {
    final box = GetStorage();
    return box.read('token') ?? '';
  }

  // Profile fetch karo
  static Future<MemberModel?> getMyProfile() async {
    try {
      final token = _getToken();

      print('Token: $token'); // Debug ke liye

      final response = await http.get(
        Uri.parse('$baseUrl/members/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status: ${response.statusCode}');   // Debug
      print('Body: ${response.body}');            // Debug

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MemberModel.fromJson(data['member']);
      }
      return null;
    } catch (e) {
      print('Profile Error: $e');
      return null;
    }
  }
}