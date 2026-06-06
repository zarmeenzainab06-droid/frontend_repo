import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../screens/admin/payments/payment_model.dart';

class PaymentService {
  static const String baseUrl = "http://127.0.0.1:3000";
  static const String _path = "/admin/payments";
  static final box = GetStorage();

  // ── Auth headers — same as AdminService ────────────────────────────────
  static Map<String, String> get _headers {
    final token = box.read('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── GET ALL PAYMENTS ────────────────────────────────────────────────────
  static Future<List<PaymentModel>> getAllPayments({
    String? month,
    int? memberId,
  }) async {
    String url = '$baseUrl$_path';
    List<String> params = [];
    if (month != null) params.add('membership_month=$month');
    if (memberId != null) params.add('user_id=$memberId');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((e) => PaymentModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load payments: ${response.body}');
  }

  // ── GET MEMBERS DROPDOWN ────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getMembers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/members?dropdown=true'),
      headers: _headers,
    );
    print('MEMBERS BODY: ${response.body}'); // ← paste this output for me

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // members endpoint returns 'members' key (see AdminService.getAllMembers)
      final List data = body['members'] ?? body['data'] ?? [];
      return data
          .map<Map<String, dynamic>>(
            (e) => {
              'id': e['id'],
              'name': e['name'] ?? '',
              'package_id': e['package_id'],
              'package_name': e['package_name'],
              'package_amount':
                  e['package_price'] ??
                  0, // ← was package_amount, backend sends package_price
            },
          )
          .toList();
    }
    throw Exception('Failed to load members: ${response.body}');
  }

  // ── ADD PAYMENT ─────────────────────────────────────────────────────────
  static Future<bool> addPayment(PaymentModel payment) async {
    final response = await http.post(
      Uri.parse('$baseUrl$_path'),
      headers: _headers,
      body: jsonEncode(payment.toJson()),
    );
    return response.statusCode == 201;
  }

  // ── UPDATE PAYMENT ──────────────────────────────────────────────────────
  static Future<bool> updatePayment(int id, PaymentModel payment) async {
    final response = await http.put(
      Uri.parse('$baseUrl$_path/$id'),
      headers: _headers,
      body: jsonEncode(payment.toJson()),
    );
    return response.statusCode == 200;
  }

  // ── DELETE PAYMENT ──────────────────────────────────────────────────────
  static Future<bool> deletePayment(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$_path/$id'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }
}
