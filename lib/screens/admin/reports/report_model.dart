// lib/screens/admin/reports/report_model.dart

/// Single point on the revenue-by-month / new-members-by-month chart.
class MonthDataPoint {
  final String month; // e.g. "Jun 2026" — display label
  final String monthKey; // e.g. "2026-06" — sort key
  final double revenue;
  final int newMembers;
  final double? revenueGrowthPercent; // null for the first month in range

  MonthDataPoint({
    required this.month,
    required this.monthKey,
    this.revenue = 0.0,
    this.newMembers = 0,
    this.revenueGrowthPercent,
  });

  factory MonthDataPoint.fromJson(Map<String, dynamic> json) {
    return MonthDataPoint(
      month: json['month']?.toString() ?? '',
      monthKey: json['month_key']?.toString() ?? '',
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0.0,
      newMembers: int.tryParse(json['new_members']?.toString() ?? '0') ?? 0,
      revenueGrowthPercent: json['revenue_growth_percent'] == null
          ? null
          : double.tryParse(json['revenue_growth_percent'].toString()),
    );
  }
}

/// Per-package breakdown row.
class PackageReportItem {
  final int packageId;
  final String packageName;
  final int memberCount;
  final double revenue;

  PackageReportItem({
    required this.packageId,
    required this.packageName,
    required this.memberCount,
    required this.revenue,
  });

  factory PackageReportItem.fromJson(Map<String, dynamic> json) {
    return PackageReportItem(
      packageId: json['package_id'] is int
          ? json['package_id']
          : int.tryParse(json['package_id']?.toString() ?? '0') ?? 0,
      packageName: json['package_name']?.toString() ?? 'Unknown',
      memberCount: int.tryParse(json['member_count']?.toString() ?? '0') ?? 0,
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0.0,
    );
  }
}

/// Top-level container for the /admin/reports/summary response — this is
/// the single object the Reports screen binds to.
class ReportSummary {
  final double totalRevenue;
  final double revenueThisMonth;
  final double averageMonthlyRevenue;
  final List<MonthDataPoint> revenueByMonth;
  final List<MonthDataPoint> newMembersByMonth;
  final List<PackageReportItem> packages;

  ReportSummary({
    required this.totalRevenue,
    required this.revenueThisMonth,
    required this.averageMonthlyRevenue,
    required this.revenueByMonth,
    required this.newMembersByMonth,
    required this.packages,
  });

  factory ReportSummary.empty() => ReportSummary(
    totalRevenue: 0,
    revenueThisMonth: 0,
    averageMonthlyRevenue: 0,
    revenueByMonth: [],
    newMembersByMonth: [],
    packages: [],
  );

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalRevenue:
          double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      revenueThisMonth:
          double.tryParse(json['revenue_this_month']?.toString() ?? '0') ?? 0.0,
      averageMonthlyRevenue:
          double.tryParse(json['average_monthly_revenue']?.toString() ?? '0') ??
          0.0,
      revenueByMonth: (json['revenue_by_month'] as List? ?? [])
          .map((e) => MonthDataPoint.fromJson(e))
          .toList(),
      newMembersByMonth: (json['new_members_by_month'] as List? ?? [])
          .map((e) => MonthDataPoint.fromJson(e))
          .toList(),
      packages: (json['packages'] as List? ?? [])
          .map((e) => PackageReportItem.fromJson(e))
          .toList(),
    );
  }

  /// Total members across all packages (used for "Member Growth" style chip)
  int get totalMembersAcrossPackages =>
      packages.fold(0, (sum, p) => sum + p.memberCount);

  /// Growth % between the most recent two months in revenueByMonth
  double? get latestGrowthPercent {
    if (revenueByMonth.length < 2) return null;
    final prev = revenueByMonth[revenueByMonth.length - 2].revenue;
    final curr = revenueByMonth.last.revenue;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100;
  }

  /// New members added during the period covered by revenueByMonth/newMembersByMonth
  int get newMembersInPeriod =>
      newMembersByMonth.fold(0, (sum, m) => sum + m.newMembers);
}

/// Result of a custom date-range revenue lookup.
class DateRangeRevenue {
  final String startDate;
  final String endDate;
  final double revenue;

  DateRangeRevenue({
    required this.startDate,
    required this.endDate,
    required this.revenue,
  });

  factory DateRangeRevenue.fromJson(Map<String, dynamic> json) {
    return DateRangeRevenue(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0.0,
    );
  }
}
