// lib/services/member_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:third_task/models/member_model.dart';

class MemberService {
  static const String baseUrl = 'http://localhost:3000/api';

  static String _getToken() {
    final box = GetStorage();
    return box.read('token') ?? '';
  }

  static Future<MemberModel?> getMyProfile() async {
    try {
      final token = _getToken();
      print('Token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/members/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

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

  static Future<Map<String, dynamic>?> getMembership() async {
    try {
      final token = _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/members/membership'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Membership Status: ${response.statusCode}');
      print('Membership Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['membership'];
      }
      return null;
    } catch (e) {
      print('Membership Error: $e');
      return null;
    }
  }
}