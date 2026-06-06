import 'package:flutter/material.dart';
import '../../core/services/admin_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/app_shell.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int totalMembers = 0;
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

  @override
  Widget build(BuildContext context) {
    return AppShell(
      role: 'admin',
      subtitle: 'Admin Panel',
      showLiveUpdates: true,
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
                  // Dashboard label
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    // cardsss on dashboard
                    const SizedBox(height: 16),
                    _statCard(
                      'Total Members',
                      totalMembers,
                      Icons.people_alt_outlined,
                      Colors.blue,
                      Colors.blue.withOpacity(0.1),
                    ),
                    const SizedBox(height: 12),
                    _statCard(
                      'Active',
                      activeMembers,
                      Icons.check_circle_outline,
                      AppTheme.active,
                      AppTheme.activeLight,
                    ),
                    const SizedBox(height: 12),
                    _statCard(
                      'Expired',
                      expiredMembers,
                      Icons.cancel_outlined,
                      AppTheme.expired,
                      AppTheme.expiredLight,
                    ),
                    const SizedBox(height: 12),
                    _statCard(
                      'Pending Payments',
                      pendingPayments,
                      Icons.access_time_outlined,
                      AppTheme.pending,
                      AppTheme.pendingLight,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
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

  /// dashboard statss
  Widget _statCard(
    String label,
    int value,
    IconData icon,
    Color iconColor,
    Color iconBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [AppTheme.cardShadow],
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
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.trending_up, size: 14, color: AppTheme.active),
                    SizedBox(width: 4),
                    Text(
                      '+12% this month',
                      style: TextStyle(fontSize: 12, color: AppTheme.active),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
        ],
      ),
    );
  }

  /// activityyy itemmmmm
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
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
