import 'package:flutter/material.dart';
import '../../core/services/admin_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/widgets/notification_bell.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int totalMembers = 0;
  int totalTrainers = 0;
  int activeMembers = 0;
  int expiredMembers = 0;
  int pendingPayments = 0;
  List<Map<String, dynamic>> recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final statsResult = await AdminService.getDashboardStats();
    final activityResult = await AdminService.getRecentActivity();

    if (statsResult['success']) {
      final s = statsResult['stats'];
      setState(() {
        totalMembers = s['totalMembers'] ?? 0;
        totalTrainers = s['totalTrainers'] ?? 0;
        activeMembers = s['active'] ?? 0;
        expiredMembers = s['expired'] ?? 0;
        pendingPayments = s['pendingPayments'] ?? 0;
      });
    }
    if (activityResult['success']) {
      setState(() {
        recentActivity = List<Map<String, dynamic>>.from(
          activityResult['activity'],
        );
      });
    }
    setState(() => _isLoading = false);
  }

  Color _darken(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: 'admin',
      subtitle: 'Admin Panel',
      showLiveUpdates: true,
      showNotificationBell: true,
      bottomNav: const AdminBottomNav(activeIndex: 0),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat cards
                    _sectionLabel('OVERVIEW'),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _statCard(
                                'Total Members',
                                totalMembers,
                                Icons.people_alt_outlined,
                                AppTheme.primary,
                                AppTheme.primaryLight,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _statCard(
                                'Total Trainers',
                                totalTrainers,
                                Icons.sports_gymnastics_outlined,
                                const Color.fromARGB(255, 15, 124, 226),
                                const Color.fromARGB(255, 250, 250, 245),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _statCard(
                                'Active',
                                activeMembers,
                                Icons.check_circle_outline,
                                AppTheme.active,
                                AppTheme.activeLight,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _statCard(
                                'Expired',
                                expiredMembers,
                                Icons.cancel_outlined,
                                AppTheme.expired,
                                AppTheme.expiredLight,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _statCard(
                                'Pending Payments',
                                pendingPayments,
                                Icons.access_time_outlined,
                                AppTheme.pending,
                                AppTheme.pendingLight,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel('RECENT ACTIVITY'),
                    const SizedBox(height: 10),
                    if (recentActivity.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No recent activity',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ...recentActivity
                          .map((item) => _activityItem(item))
                          .toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: AppTheme.textSecondary.withOpacity(0.8),
      ),
    );
  }

  /// compact stat card (2-column grid)
  Widget _statCard(
    String label,
    int value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// recent activity row
  Widget _activityItem(Map<String, dynamic> item) {
    final name = item['memberName'] ?? '';
    final action = item['action'] ?? '';
    final status = (item['status'] ?? '').toString().toLowerCase();
    final timeAgo = item['timeAgo'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final statusColor = AppColors.statusColor(status);
    final statusBg = AppColors.statusLightColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primary, _darken(AppTheme.primary, 0.18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
