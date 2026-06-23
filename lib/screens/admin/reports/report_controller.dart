// lib/screens/admin/reports/report_controller.dart

import 'package:get/get.dart';
import '../../../core/utils/theme.dart';
import '../../../core/services/admin_report_service.dart';
import 'report_model.dart';

class ReportController extends GetxController {
  // ─── STATE ────────────────────────────────────────────────────────────────
  final Rx<ReportSummary> summary = Rx(ReportSummary.empty());
  final RxBool isLoading = false.obs;

  // Period filter for the whole screen — mirrors the "Last 3 Months" dropdown
  // in your design. Internally we still ask the backend for 6 months of raw
  // data and slice client-side, since the backend already returns labelled
  // month buckets that are cheap to filter.
  final RxString selectedPeriod = 'Last 6 Months'.obs;
  static const periodOptions = [
    'Last 3 Months',
    'Last 6 Months',
    'Last 12 Months',
  ];

  // Custom date-range revenue lookup result (shown when user picks a range)
  final Rx<DateRangeRevenue?> dateRangeResult = Rx(null);
  final RxBool isDateRangeLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSummary();
  }

  int get _monthsForPeriod {
    switch (selectedPeriod.value) {
      case 'Last 3 Months':
        return 3;
      case 'Last 12 Months':
        return 12;
      default:
        return 6;
    }
  }

  // ─── LOAD SUMMARY ─────────────────────────────────────────────────────────
  Future<void> loadSummary() async {
    try {
      isLoading.value = true;
      summary.value = await ReportService.getSummary(months: _monthsForPeriod);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reports',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.expired,
        colorText: AppTheme.textOnPrimary,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadSummary();
  }

  // ─── CUSTOM DATE-RANGE REVENUE ────────────────────────────────────────────
  Future<void> fetchRevenueForRange(DateTime start, DateTime end) async {
    try {
      isDateRangeLoading.value = true;
      final startStr = _fmt(start);
      final endStr = _fmt(end);
      dateRangeResult.value = await ReportService.getRevenueByDateRange(
        startDate: startStr,
        endDate: endStr,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch revenue for selected range',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDateRangeLoading.value = false;
    }
  }

  void clearDateRange() => dateRangeResult.value = null;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
