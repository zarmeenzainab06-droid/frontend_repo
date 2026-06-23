import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:third_task/core/utils/theme.dart';
import 'package:third_task/core/widgets/app_shell.dart';
import 'report_controller.dart';
import 'report_model.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  // ---------- color helpers (same pattern as Payments/Members screens) ----
  Color _lighten(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReportController());

    return AppShell(
      role: 'admin',
      subtitle: 'GymFitex',
      bottomNav: const AdminBottomNav(activeIndex: 2),

      body: Obx(() {
        if (c.isLoading.value && c.summary.value.revenueByMonth.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: c.loadSummary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeader(c),
              const SizedBox(height: 18),
              _sectionTitle('💰 Revenue Report'),
              const SizedBox(height: 10),
              _revenueStatsGrid(c),
              const SizedBox(height: 16),
              _revenueByMonthChart(c),
              const SizedBox(height: 16),
              _dateRangeCard(context, c),
              const SizedBox(height: 26),
              _sectionTitle('📦 Membership Report'),
              const SizedBox(height: 10),
              _packageBreakdownList(c),
              const SizedBox(height: 26),
              _sectionTitle('📈 Trends & Analytics'),
              const SizedBox(height: 10),
              _trendsCard(c),
            ],
          ),
        );
      }),
    );
  }

  // ---------- header (same gradient hero as Payments screen) -------------
  Widget _buildHeader(ReportController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _darken(AppTheme.primary, 0.18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Reports & Analytics',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              _periodDropdown(c),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodDropdown(ReportController c) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: c.selectedPeriod.value,
            dropdownColor: AppTheme.primary,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 18,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            items: ReportController.periodOptions
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) {
              if (v != null) c.changePeriod(v);
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: AppTheme.textPrimary,
    ),
  );

  // ---------- 💰 Revenue stat cards (Total / This Month / Average) -------
  Widget _revenueStatsGrid(ReportController c) {
    return Obx(() {
      final s = c.summary.value;
      final growth = s.latestGrowthPercent;
      return Column(
        children: [
          _statCard(
            label: 'Total Revenue',
            value: 'Rs ${_fmtMoney(s.totalRevenue)}',
            icon: Icons.attach_money_rounded,
            iconColor: AppTheme.active,
            growth: null,
          ),
          const SizedBox(height: 12),
          _statCard(
            label: 'Revenue This Month',
            value: 'Rs ${_fmtMoney(s.revenueThisMonth)}',
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF1E88E5),
            growth: growth,
          ),
          const SizedBox(height: 12),
          _statCard(
            label: 'Average Monthly',
            value: 'Rs ${_fmtMoney(s.averageMonthlyRevenue)}',
            icon: Icons.show_chart_rounded,
            iconColor: AppTheme.pending,
            growth: null,
          ),
        ],
      );
    });
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    double? growth,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (growth != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        growth >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: growth >= 0 ? AppTheme.active : AppTheme.expired,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}% from last period',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: growth >= 0
                              ? AppTheme.active
                              : AppTheme.expired,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  // ---------- Revenue by month bar chart ----------------------------------
  Widget _revenueByMonthChart(ReportController c) {
    return Obx(() {
      final months = c.summary.value.revenueByMonth;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (months.isEmpty)
              const SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No revenue data yet',
                    style: TextStyle(color: AppTheme.textHint, fontSize: 13),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _niceMaxY(months.map((m) => m.revenue).toList()),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval:
                          _niceMaxY(months.map((m) => m.revenue).toList()) / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.border,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          getTitlesWidget: (value, meta) => Text(
                            _shortMoney(value),
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppTheme.textHint,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= months.length) {
                              return const SizedBox.shrink();
                            }
                            final label = months[i].month.split(' ').first;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(months.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: months[i].revenue,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppTheme.primary,
                                _lighten(AppTheme.primary, 0.15),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ---------- Custom date-range revenue lookup ----------------------------
  Widget _dateRangeCard(BuildContext context, ReportController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue by Date Range',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickDateRange(context, c),
              icon: const Icon(
                Icons.date_range_outlined,
                size: 18,
                color: AppTheme.primary,
              ),
              label: const Text(
                'Pick a date range',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Obx(() {
            if (c.isDateRangeLoading.value) {
              return const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              );
            }
            final r = c.dateRangeResult.value;
            if (r == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.activeLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.active.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.startDate}  →  ${r.endDate}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${_fmtMoney(r.revenue)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.active,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: c.clearDateRange,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context, ReportController c) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      await c.fetchRevenueForRange(picked.start, picked.end);
    }
  }

  // ---------- 📦 Membership / package breakdown ----------------------------
  Widget _packageBreakdownList(ReportController c) {
    return Obx(() {
      final packages = c.summary.value.packages;
      if (packages.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Text(
              'No packages found',
              style: TextStyle(color: AppTheme.textHint),
            ),
          ),
        );
      }
      return Column(
        children:
            packages
                .map((p) => _packageCard(p, packages))
                .expand((w) => [w, const SizedBox(height: 12)])
                .toList()
              ..removeLast(),
      );
    });
  }

  Widget _packageCard(
    PackageReportItem p,
    List<PackageReportItem> allPackages,
  ) {
    final maxRevenue = allPackages
        .map((x) => x.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final progress = maxRevenue > 0 ? (p.revenue / maxRevenue) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p.packageName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${p.memberCount} member${p.memberCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppTheme.background,
              valueColor: const AlwaysStoppedAnimation(AppTheme.active),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs ${_fmtMoney(p.revenue)} generated',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 📈 Trends: new members line chart ---------------------------
  Widget _trendsCard(ReportController c) {
    return Obx(() {
      final months = c.summary.value.newMembersByMonth;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Membership Growth',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.activeLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${c.summary.value.newMembersInPeriod} new',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.active,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (months.isEmpty)
              const SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No membership data yet',
                    style: TextStyle(color: AppTheme.textHint, fontSize: 13),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.border,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppTheme.textHint,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= months.length) {
                              return const SizedBox.shrink();
                            }
                            final label = months[i].month.split(' ').first;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          months.length,
                          (i) => FlSpot(
                            i.toDouble(),
                            months[i].newMembers.toDouble(),
                          ),
                        ),
                        isCurved: true,
                        color: AppTheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primary.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ---------- formatting helpers -------------------------------------------
  String _fmtMoney(double v) {
    final isWhole = v == v.roundToDouble();
    final s = isWhole ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    // add thousands separators
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return parts.length > 1 ? '${buf.toString()}.${parts[1]}' : buf.toString();
  }

  String _shortMoney(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  double _niceMaxY(List<double> values) {
    if (values.isEmpty) return 100;
    final maxV = values.fold<double>(0, (a, b) => a > b ? a : b);
    if (maxV <= 0) return 100;
    // round up to a nice number above the max
    final magnitude = (maxV.toString().split('.').first.length - 1).clamp(
      0,
      10,
    );
    final step = [1, 2, 5, 10]
        .map((m) => m * pow10(magnitude))
        .firstWhere((s) => s >= maxV, orElse: () => pow10(magnitude + 1));
    return step.toDouble();
  }

  num pow10(int n) {
    num r = 1;
    for (int i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}
