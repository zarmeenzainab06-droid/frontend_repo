// lib/core/services/admin_report_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../screens/admin/reports/report_model.dart';

class ReportService {
  static const String baseUrl = "http://localhost:3002";
  static const String _path = "/admin/reports";
  static final box = GetStorage();

  static Map<String, String> get _headers {
    final token = box.read('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── ONE-SHOT SUMMARY (used by main Reports screen) ───────────────────────
  static Future<ReportSummary> getSummary({int months = 6}) async {
    final url = '$baseUrl$_path/summary?months=$months';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return ReportSummary.fromJson(body['data']);
    }
    throw Exception('Failed to load reports summary: ${response.body}');
  }

  // ── CUSTOM DATE-RANGE REVENUE ─────────────────────────────────────────────
  static Future<DateRangeRevenue> getRevenueByDateRange({
    required String startDate, // 'YYYY-MM-DD'
    required String endDate, // 'YYYY-MM-DD'
  }) async {
    final url = '$baseUrl$_path/revenue?start=$startDate&end=$endDate';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final dateRange = body['data']['date_range'];
      if (dateRange == null) {
        return DateRangeRevenue(
          startDate: startDate,
          endDate: endDate,
          revenue: 0,
        );
      }
      return DateRangeRevenue.fromJson(dateRange);
    }
    throw Exception('Failed to load revenue by date range: ${response.body}');
  }

  // ── MEMBERSHIP REPORT (per-package breakdown only, if needed standalone) ─
  static Future<List<PackageReportItem>> getMembershipReport() async {
    final url = '$baseUrl$_path/membership';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data']['packages'];
      return data.map((e) => PackageReportItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load membership report: ${response.body}');
  }

  // ── TRENDS REPORT (standalone, if needed without the full summary) ───────
  static Future<List<MonthDataPoint>> getTrendsReport({int months = 6}) async {
    final url = '$baseUrl$_path/trends?months=$months';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data']['months'];
      return data.map((e) => MonthDataPoint.fromJson(e)).toList();
    }
    throw Exception('Failed to load trends report: ${response.body}');
  }
}
