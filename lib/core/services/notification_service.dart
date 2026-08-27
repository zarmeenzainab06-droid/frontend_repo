import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = "http://gym.sandbox.pk";
  static const String _path = "/notifications";
  static final box = GetStorage();

  static Map<String, String> get _headers {
    final token = box.read('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── GET ALL NOTIFICATIONS FOR THE LOGGED-IN USER ────────────────────────
  static Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
  }) async {
    final url = unreadOnly ? '$baseUrl$_path?unread=true' : '$baseUrl$_path';
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load notifications: ${response.body}');
  }

  // ── GET UNREAD COUNT ─────────────────────────────────────────────────────
  static Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$_path/unread-count'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['count'] ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // ── MARK A SINGLE NOTIFICATION AS READ ──────────────────────────────────
  static Future<bool> markAsRead(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$_path/$id/read'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }

  // ── MARK ALL NOTIFICATIONS AS READ ──────────────────────────────────────
  static Future<bool> markAllAsRead() async {
    final response = await http.patch(
      Uri.parse('$baseUrl$_path/read-all'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }
}
