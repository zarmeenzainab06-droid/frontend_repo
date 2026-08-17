import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '/core/utils/theme.dart';
import '/core/widgets/app_shell.dart';
import 'report_controller.dart';
import 'report_model.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  Color _darken(Color c, [double amount = .18]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lighten(Color c, [double amount = .15]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  String _fmtMoney(double val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    }
    return val.toStringAsFixed(0);
  }

  String _shortMoney(double val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}k';
    return val.toStringAsFixed(0);
  }

  double _niceMaxY(List<double> values) {
    if (values.isEmpty) return 10;
    final maxVal = values.fold<double>(0, (a, b) => a > b ? a : b);
    if (maxVal == 0) return 10;
    return maxVal * 1.25;
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReportController());

    return AppShell(
      role: 'admin',
      subtitle: 'Admin Panel',
      bottomNav: const AdminBottomNav(activeIndex: 2),
      actions: [
        AppShellAction(
          icon: Icons.refresh_rounded,
          onTap: c.loadSummary,
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (c.isLoading.value && c.revenueByMonth.isEmpty) {
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
              const SizedBox(height: 20),

              _sectionTitle('💰 Financial Overview'),
              const SizedBox(height: 12),
              _revenueStatsGrid(c),
              const SizedBox(height: 20),

              _revenueByMonthChart(c),
              const SizedBox(height: 20),

              _sectionTitle('💳 Payment Methods & Breakdown'),
              const SizedBox(height: 12),
              _paymentMethodsPieChart(c),
              const SizedBox(height: 20),

              _sectionTitle('📈 Membership Growth Trends'),
              const SizedBox(height: 12),
              _trendsCard(c),
              const SizedBox(height: 20),

              _sectionTitle('👥 Membership Status Distribution'),
              const SizedBox(height: 12),
              _membershipStatusCards(c),
              const SizedBox(height: 20),

              _sectionTitle('📦 Package Revenue Performance'),
              const SizedBox(height: 12),
              _packageBreakdownList(c),
              const SizedBox(height: 20),

              _dateRangeCard(context, c),
            ],
          ),
        );
      }),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(ReportController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _darken(AppTheme.primary)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Reports & Analytics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Real-time Gym Performance Dashboard',
                  style: TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
              ],
            ),
          ),
          _periodDropdown(c),
        ],
      ),
    );
  }

  Widget _periodDropdown(ReportController c) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
      fontWeight: FontWeight.bold,
      color: AppTheme.textPrimary,
    ),
  );

  // ── 💰 Financial KPI Cards ───────────────────────────────────────────────
  Widget _revenueStatsGrid(ReportController c) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _kpiCard(
                  label: 'Total Revenue',
                  value: 'Rs ${_fmtMoney(c.totalRevenue.value)}',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _kpiCard(
                  label: 'This Month',
                  value: 'Rs ${_fmtMoney(c.revenueThisMonth.value)}',
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                  growth: c.latestGrowthPercent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _kpiCard(
                  label: 'Uncollected Dues',
                  value: 'Rs ${_fmtMoney(c.pendingDuesAmount.value)}',
                  icon: Icons.pending_actions_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFFFBEB),
                  subtext: '${c.pendingDuesCount.value} pending member(s)',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _kpiCard(
                  label: 'Avg Monthly',
                  value: 'Rs ${_fmtMoney(c.averageMonthlyRevenue.value)}',
                  icon: Icons.analytics_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF5F3FF),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    double? growth,
    String? subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (growth != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: growth >= 0
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        growth >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: growth >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: growth >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(
              subtext,
              style: TextStyle(
                fontSize: 10,
                color: iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Monthly Revenue Bar Chart ────────────────────────────────────────────
  Widget _revenueByMonthChart(ReportController c) {
    return Obx(() {
      final months = c.revenueByMonth;
      final maxY = _niceMaxY(months.map((m) => m.revenue).toList());

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Revenue Trend',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PKR (Rs)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (months.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'No revenue data available for this period',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF1E293B),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final m = months[group.x.toInt()];
                          return BarTooltipItem(
                            '${m.month}\nRs ${rod.toY.toStringAsFixed(0)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (val) => FlLine(
                        color: Colors.grey.shade200,
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
                          reservedSize: 36,
                          getTitlesWidget: (val, meta) => Text(
                            _shortMoney(val),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (val, meta) {
                            if (val % 1 != 0) return const SizedBox.shrink();
                            final idx = val.toInt();
                            if (idx < 0 || idx >= months.length)
                              return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                months[idx].month.split(' ').first,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
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
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF34D399)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
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

  // ── Payment Methods Pie/Donut Chart ──────────────────────────────────────
  Widget _paymentMethodsPieChart(ReportController c) {
    return Obx(() {
      final methods = c.paymentMethods;
      final totalAmount = methods.fold<double>(
        0,
        (sum, m) => sum + m.totalAmount,
      );

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method Share',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (methods.isEmpty || totalAmount == 0)
              const SizedBox(
                height: 150,
                child: Center(
                  child: Text(
                    'No payment method data',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Row(
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 35,
                        sections: methods.map((m) {
                          final pct = totalAmount > 0
                              ? (m.totalAmount / totalAmount) * 100
                              : 0.0;
                          final color = _getMethodColor(m.method);
                          return PieChartSectionData(
                            color: color,
                            value: m.totalAmount,
                            title: '${pct.toStringAsFixed(0)}%',
                            radius: 30,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: methods.map((m) {
                        final pct = totalAmount > 0
                            ? (m.totalAmount / totalAmount) * 100
                            : 0.0;
                        final color = _getMethodColor(m.method);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    m.method.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Rs ${_fmtMoney(m.totalAmount)} (${pct.toStringAsFixed(0)}%)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return const Color(0xFF10B981);
      case 'online':
      case 'bank':
      case 'easypaisa':
      case 'jazzcash':
        return const Color(0xFF2563EB);
      case 'card':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  // ── Membership Growth Spline Line Chart ─────────────────────────────────
  Widget _trendsCard(ReportController c) {
    return Obx(() {
      final months = c.newMembersByMonth;
      final maxY = _niceMaxY(
        months.map((m) => m.newMembers.toDouble()).toList(),
      );

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Member Signups',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${c.newMembersInPeriod} total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (months.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'No membership growth data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    maxY: maxY,
                    minY: 0,
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: Colors.grey.shade200,
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
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) => Text(
                            val.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (val, meta) {
                            if (val % 1 != 0) return const SizedBox.shrink();
                            final idx = val.toInt();
                            if (idx < 0 || idx >= months.length)
                              return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                months[idx].month.split(' ').first,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
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
                        curveSmoothness: 0.35,
                        barWidth: 3,
                        color: AppTheme.primary,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                                radius: 5,
                                color: AppTheme.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withOpacity(0.3),
                              AppTheme.primary.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
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

  // ── Membership Status Distribution Cards ─────────────────────────────────
  Widget _membershipStatusCards(ReportController c) {
    return Obx(() {
      final statuses = c.membershipStatuses;
      final total = statuses.fold<int>(0, (sum, s) => sum + s.count);

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statusChip(
                  'Active',
                  _getStatusCount(statuses, 'active'),
                  total,
                  const Color(0xFF10B981),
                  Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statusChip(
                  'Expired',
                  _getStatusCount(statuses, 'expired'),
                  total,
                  const Color(0xFFEF4444),
                  Icons.cancel_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statusChip(
                  'Frozen',
                  _getStatusCount(statuses, 'frozen'),
                  total,
                  const Color(0xFF3B82F6),
                  Icons.pause_circle_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statusChip(
                  'Pending',
                  _getStatusCount(statuses, 'pending'),
                  total,
                  const Color(0xFFF59E0B),
                  Icons.pending_rounded,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  int _getStatusCount(List<MembershipStatusItem> list, String statusName) {
    final item = list.firstWhere(
      (s) => s.status.toLowerCase() == statusName,
      orElse: () => MembershipStatusItem(status: statusName, count: 0),
    );
    return item.count;
  }

  Widget _statusChip(
    String title,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final pct = total > 0 ? (count / total) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count member(s)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Package Breakdown List ────────────────────────────────────────────────
  Widget _packageBreakdownList(ReportController c) {
    return Obx(() {
      final pkgs = c.packages;
      if (pkgs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'No package data available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
      final maxRevenue = pkgs
          .map((p) => p.revenue)
          .fold<double>(0, (a, b) => a > b ? a : b);

      return Column(
        children: pkgs.map((p) {
          final progress = maxRevenue > 0
              ? (p.revenue / maxRevenue).clamp(0.0, 1.0)
              : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.packageName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${p.memberCount} active member(s)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs ${_fmtMoney(p.revenue)} total revenue generated',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  // ── Date Range Revenue Lookup Card ───────────────────────────────────────
  Widget _dateRangeCard(BuildContext context, ReportController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Date Range Revenue Lookup',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                'Select Start & End Date',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Obx(() {
            if (c.isDateRangeLoading.value) {
              return const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              );
            }
            final r = c.dateRangeResult.value;
            if (r == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
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
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${_fmtMoney(r.revenue)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
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
                      color: Colors.grey,
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
}
