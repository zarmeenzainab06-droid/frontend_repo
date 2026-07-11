import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  ///fooooorrrrr ediittt screennnnn// read member
  static Future<Map<String, dynamic>> getMemberById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/members/$userId'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'member': data['member']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // foe status in member module
  static Future<Map<String, dynamic>> freezeMembership({
    required int userId,
    required String action, // 'freeze' or 'unfreeze'
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/members/$userId/freeze'),
        headers: _headers,
        body: json.encode({'action': action}),
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

  // ── Get Trainers ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getTrainers() async {
    try {
      print("getAllTrainers API called");

      final response = await http.get(
        Uri.parse('$baseUrl/admin/trainers'),
        headers: _headers,
      );
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'trainers': data['trainers']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Get Slots (for dropdowns — active only by default) ────────────
  static Future<Map<String, dynamic>> getSlots({bool activeOnly = true}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/admin/slots',
      ).replace(queryParameters: activeOnly ? {'active': '1'} : null);
      final response = await http.get(uri, headers: _headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'slots': data['slots']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: \$e'};
    }
  }

  // ── Get slots linked to a specific package (for member form) ──
  static Future<Map<String, dynamic>> getPackageSlots(int packageId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/packages/$packageId/slots'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'slots': data['slots']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Get All Packages (updated — returns slot_id + slot_name) ──────
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
      return {'success': false, 'message': 'Server error: \$e'};
    }
  }

  // ── Create Package (updated — sends slot_id instead of from/to time) ──
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
      return {'success': false, 'message': 'Server error: \$e'};
    }
  }

  // ── Update Package (updated — sends slot_id instead of from/to time) ──
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
      return {'success': false, 'message': 'Server error: \$e'};
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
    required String password,
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
          'password': password,
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
    String? password, // ← add this
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
  // Cash -> JSON request
  // Online -> multipart/form-data with screenshot bytes
  // Works on web + mobile (no dart:io File used)
  static Future<Map<String, dynamic>> assignMembership({
    required int userId,
    required int packageId,
    required String startDate,
    required String endDate,
    required double amount,
    required String paymentMethod,
    Uint8List? screenshotBytes,
    String? screenshotName,
    String? existingScreenshotPath,
    String? transactionId,
  }) async {
    try {
      final token = box.read('token');
      final uri = Uri.parse('$baseUrl/admin/members/$userId/membership');

      if (screenshotBytes != null && paymentMethod == 'online') {
        // ── Multipart request (online payment with screenshot) ──
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token';

        // Form fields
        request.fields['package_id'] = packageId.toString();
        request.fields['start_date'] = startDate;
        request.fields['end_date'] = endDate;
        request.fields['amount'] = amount.toString();
        request.fields['payment_method'] = paymentMethod;
        if (transactionId != null)
          request.fields['transaction_id'] = transactionId; // ← add

        // Screenshot file — fromBytes works on web + mobile
        request.files.add(
          http.MultipartFile.fromBytes(
            'screenshot',
            screenshotBytes,
            filename: screenshotName ?? 'screenshot.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('DEBUG multipart status: ${response.statusCode}');
        print('DEBUG multipart body: ${response.body}');

        final data = json.decode(response.body);
        if (response.statusCode == 201 && data['success'] == true) {
          return {'success': true};
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save payment',
        };
      } else {
        // ── JSON request (cash payment) ─────────────────────────
        final response = await http.post(
          uri,
          headers: _headers,
          body: json.encode({
            'package_id': packageId,
            'start_date': startDate,
            'end_date': endDate,
            'amount': amount,
            'payment_method': paymentMethod,
            //send existing path so backend keeps it instead of saving null
            if (existingScreenshotPath != null)
              'existing_screenshot': existingScreenshotPath,
            if (transactionId != null) 'transaction_id': transactionId, // ← add
          }),
        );

        print('DEBUG cash status: ${response.statusCode}');
        print('DEBUG cash body: ${response.body}');

        final data = json.decode(response.body);
        if (response.statusCode == 201 && data['success'] == true) {
          return {'success': true};
        }
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to save payment',
        };
      }
    } catch (e) {
      print('DEBUG assignMembership error: $e');
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // for resolving dup issue

  static Future<Map<String, dynamic>> updateMembership({
    required int userId,
    required int packageId,
    required String startDate,
    required String endDate,
    required double amount,
    required String paymentMethod,
    Uint8List? screenshotBytes,
    String? screenshotName,
    String? existingScreenshotPath,
    String? transactionId,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/admin/members/$userId/membership'),
      );

      final token = box.read('token');

      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields['packageId'] = packageId.toString();
      request.fields['startDate'] = startDate;
      request.fields['endDate'] = endDate;
      request.fields['amount'] = amount.toString();
      request.fields['paymentMethod'] = paymentMethod;

      if (existingScreenshotPath != null) {
        request.fields['existing_screenshot'] = existingScreenshotPath;
      }
      if (transactionId != null) {
        request.fields['transaction_id'] = transactionId; // ← add
      }
      if (screenshotBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'screenshot',
            screenshotBytes,
            filename: screenshotName ?? 'payment.jpg',
          ),
        );
      }

      final response = await request.send();

      final body = await response.stream.bytesToString();

      return jsonDecode(body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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

  // ── Get All Trainers ───────────────────────────────────────
  static Future<Map<String, dynamic>> getAllTrainers({String? search}) async {
    try {
      final token = box.read('token'); // debug
      print("TOKEN: $token");

      final uri = Uri.parse('$baseUrl/admin/trainers').replace(
        // queryParameters: search != null && search.isNotEmpty
        //     ? {'search': search}
        //     : null,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          '_': DateTime.now().millisecondsSinceEpoch.toString(), // ← add this
        },
      );

      print("REQUEST URL: $uri"); // debug

      final response = await http.get(uri, headers: _headers);

      print("STATUS: ${response.statusCode}"); // debug
      print("BODY: ${response.body}");
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'trainers': data['trainers']};
      } else if (response.statusCode == 403) {
        Get.offAllNamed('/login');
        return {'success': false, 'message': 'Access denied'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Get Trainer By ID ──────────────────────────────────────
  static Future<Map<String, dynamic>> getTrainerById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/trainers/$id'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'trainer': data['trainer']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Create Trainer ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createTrainer({
    required String name,
    required String email,
    String? phone,
    String? gender,
    int? age,
    String? specialization,
    int? experience,
    String trainingSlot = 'morning',
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/trainers'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (gender != null) 'gender': gender,
          if (age != null) 'age': age,
          if (specialization != null && specialization.isNotEmpty)
            'specialization': specialization,
          if (experience != null) 'experience': experience,
          'training_slot': trainingSlot,
          'password': password, // for passsword
        }),
      );
      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true, 'trainer_id': data['trainer_id']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Update Trainer ─────────────────────────────────────────
  static Future<Map<String, dynamic>> updateTrainer({
    required int id,
    required String name,
    required String email,
    String? phone,
    String? gender,
    int? age,
    String? specialization,
    int? experience,
    String trainingSlot = 'morning',
    int isActive = 1,
    // required String password,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/trainers/$id'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (gender != null) 'gender': gender,
          if (age != null) 'age': age,
          if (specialization != null && specialization.isNotEmpty)
            'specialization': specialization,
          if (experience != null) 'experience': experience,
          'training_slot': trainingSlot,
          'is_active': isActive,
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

  // ── Delete Trainer ─────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteTrainer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/trainers/$id'),
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

  // ── Get Admin Profile ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getAdminProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/profile'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'profile': data['profile']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ── Update Admin Profile ───────────────────────────────────────
  static Future<Map<String, dynamic>> updateAdminProfile({
    required String name,
    String? phone,
    String? gymLocation,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/profile'),
        headers: _headers,
        body: json.encode({
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (gymLocation != null && gymLocation.isNotEmpty)
            'gym_location': gymLocation,
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

  // ── Change Admin Password ──────────────────────────────────────
  static Future<Map<String, dynamic>> changeAdminPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/profile/password'),
        headers: _headers,
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
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

  // ── Member Check-in ─────────────────────────────────────────
  static Future<Map<String, dynamic>> checkInMember(String searchQuery) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/members/check-in'),
        headers: _headers,
        body: json.encode({'searchQuery': searchQuery}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'access': data['access'],
          'memberName': data['memberName'],
          'message': data['message'],
        };
      }
      return {
        'success': false,
        'access': data['access'] ?? 'denied',
        'memberName': data['memberName'] ?? '',
        'reason': data['reason'] ?? data['message'] ?? 'Failed to check-in',
      };
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }
}
