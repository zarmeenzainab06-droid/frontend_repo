import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:get_storage/get_storage.dart';
import '../../screens/admin/payments/payment_model.dart';
import 'package:get/get.dart';

class PaymentService {
  static const String baseUrl = "http://127.0.0.1:3000";
  static const String _path = "/admin/payments";
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

  // ── GET ALL PAYMENTS ──────────────────────────────────────────────────────
  static Future<List<PaymentModel>> getAllPayments({
    String? month,
    int? memberId,
  }) async {
    String url = '$baseUrl$_path';
    final params = <String>[];
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

  // ── GET MEMBERS DROPDOWN ─────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getMembers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/members?dropdown=true'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['members'] ?? body['data'] ?? [];
      return data
          .map<Map<String, dynamic>>(
            (e) => {
              'id': e['id'],
              'name': e['name'] ?? '',
              'phone': e['phone'] ?? '', // TO COMES NAME + PHONE NO
              'package_id': e['package_id'],
              'package_name': e['package_name'],
              'package_amount': e['package_price'] ?? 0,
            },
          )
          .toList();
    }
    throw Exception('Failed to load members: ${response.body}');
  }

  // ── ADD PAYMENT ───────────────────────────────────────────────────────────
  // Uses multipart when screenshot provided (online), JSON otherwise (cash)
  static Future<bool> addPayment(
    PaymentModel payment, {
    Uint8List? screenshotBytes,
    String? screenshotName,
  }) async {
    if (payment.method == 'online' && screenshotBytes != null) {
      return _multipartRequest(
        method: 'POST',
        url: '$baseUrl$_path',
        payment: payment,
        screenshotBytes: screenshotBytes,
        screenshotName: screenshotName ?? 'screenshot.jpg',
        expectedStatus: 201,
      );
    }
    // Cash — plain JSON
    final response = await http.post(
      Uri.parse('$baseUrl$_path'),
      headers: _headers,
      body: jsonEncode(payment.toJson()),
    );
    debugPrint(
      'addPayment cash status: ${response.statusCode} body: ${response.body}',
    );
    return response.statusCode == 201;
  }

  // ── UPDATE PAYMENT ────────────────────────────────────────────────────────
  static Future<bool> updatePayment(
    int id,
    PaymentModel payment, {
    Uint8List? screenshotBytes,
    String? screenshotName,
  }) async {
    if (payment.method == 'online' && screenshotBytes != null) {
      return _multipartRequest(
        method: 'PUT',
        url: '$baseUrl$_path/$id',
        payment: payment,
        screenshotBytes: screenshotBytes,
        screenshotName: screenshotName ?? 'screenshot.jpg',
        expectedStatus: 200,
      );
    }
    // Cash or online without new screenshot — plain JSON
    final response = await http.put(
      Uri.parse('$baseUrl$_path/$id'),
      headers: _headers,
      body: jsonEncode(payment.toJson()),
    );
    debugPrint(
      'updatePayment status: ${response.statusCode} body: ${response.body}',
    );
    return response.statusCode == 200;
  }

  // ── DELETE PAYMENT ────────────────────────────────────────────────────────
  static Future<bool> deletePayment(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$_path/$id'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }

  // ── Add this method to PaymentService ────────────────────────────────────
  // FOR UPDATE STATUS

  static Future<bool> updateStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$_path/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': status.toLowerCase()}),
    );
    debugPrint('updateStatus: ${response.statusCode} ${response.body}');
    return response.statusCode == 200;
  }

  // ── MULTIPART HELPER ──────────────────────────────────────────────────────
  static Future<bool> _multipartRequest({
    required String method,
    required String url,
    required PaymentModel payment,
    required Uint8List screenshotBytes,
    required String screenshotName,
    required int expectedStatus,
  }) async {
    final request = http.MultipartRequest(method, Uri.parse(url))
      ..headers.addAll(_authHeader);

    // Add all JSON fields as form fields
    final json = payment.toJson();
    json.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    // Add screenshot
    final ext = screenshotName.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'png' : 'jpeg';
    request.files.add(
      http.MultipartFile.fromBytes(
        'screenshot',
        screenshotBytes,
        filename: screenshotName,
        contentType: MediaType('image', mime),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    debugPrint(
      'multipart $method status: ${response.statusCode} body: ${response.body}',
    );
    return response.statusCode == expectedStatus;
  }
}

// ignore: avoid_print
void debugPrint(String msg) => print(msg);
