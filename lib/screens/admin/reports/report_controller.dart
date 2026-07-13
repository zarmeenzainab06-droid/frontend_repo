// lib/screens/admin/reports/report_controller.dart

import 'package:get/get.dart';
import '../../../core/utils/theme.dart';
import '../../../core/services/admin_report_service.dart';
import 'report_model.dart';

class ReportController extends GetxController {
  // ─── FLAT Rx FIELDS (each tracked independently by GetX) ─────────────────
  // Using a single Rx<ReportSummary> object caused nested Obx widgets to miss
  // updates when the whole object was replaced — GetX only fires if .value
  // is re-read inside the Obx after replacement. Flat fields fix this cleanly.
  final RxDouble totalRevenue = 0.0.obs;
  final RxDouble revenueThisMonth = 0.0.obs;
  final RxDouble averageMonthlyRevenue = 0.0.obs;
  final RxList<MonthDataPoint> revenueByMonth = <MonthDataPoint>[].obs;
  final RxList<MonthDataPoint> newMembersByMonth = <MonthDataPoint>[].obs;
  final RxList<PackageReportItem> packages = <PackageReportItem>[].obs;

  final RxBool isLoading = false.obs;

  // ─── PERIOD FILTER ────────────────────────────────────────────────────────
  final RxString selectedPeriod = 'Last 6 Months'.obs;
  static const periodOptions = [
    'Last 3 Months',
    'Last 6 Months',
    'Last 12 Months',
  ];

  // ─── DATE-RANGE RESULT ───────────────────────────────────────────────────
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

  // ─── COMPUTED ─────────────────────────────────────────────────────────────
  // Growth % between the two most recent months in revenueByMonth
  double? get latestGrowthPercent {
    final months = revenueByMonth;
    if (months.length < 2) return null;
    final prev = months[months.length - 2].revenue;
    final curr = months.last.revenue;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100;
  }

  int get newMembersInPeriod =>
      newMembersByMonth.fold(0, (sum, m) => sum + m.newMembers);

  // ─── LOAD ─────────────────────────────────────────────────────────────────
  Future<void> loadSummary() async {
    try {
      isLoading.value = true;
      final summary = await ReportService.getSummary(months: _monthsForPeriod);

      // Assign each field individually — GetX notifies each Obx that reads it
      totalRevenue.value = summary.totalRevenue;
      revenueThisMonth.value = summary.revenueThisMonth;
      averageMonthlyRevenue.value = summary.averageMonthlyRevenue;
      revenueByMonth.assignAll(summary.revenueByMonth);
      newMembersByMonth.assignAll(summary.newMembersByMonth);
      packages.assignAll(summary.packages);
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

  // Period changed from dropdown — re-fetch with new month window
  void changePeriod(String period) {
    selectedPeriod.value = period;
    loadSummary();
  }

  // ─── DATE-RANGE REVENUE ───────────────────────────────────────────────────
  Future<void> fetchRevenueForRange(DateTime start, DateTime end) async {
    try {
      isDateRangeLoading.value = true;
      dateRangeResult.value = await ReportService.getRevenueByDateRange(
        startDate: _fmt(start),
        endDate: _fmt(end),
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
