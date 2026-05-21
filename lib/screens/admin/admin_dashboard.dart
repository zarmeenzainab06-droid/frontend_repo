import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/services/admin_service.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/app_drawer.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final box = GetStorage();
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const AppDrawer(role: 'admin'),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
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
                          // ── Dashboard title ──────────────────
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Stat cards ───────────────────────
                          _buildStatCard(
                            label: 'Total Members',
                            value: totalMembers,
                            icon: Icons.people_alt_outlined,
                            iconColor: const Color.fromARGB(255, 50, 127, 204),
                            iconBg: const Color.fromARGB(
                              255,
                              0,
                              1,
                              2,
                            ).withOpacity(0.1),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            label: 'Active',
                            value: activeMembers,
                            icon: Icons.check_circle_outline,
                            iconColor: const Color.fromARGB(255, 236, 241, 236),
                            iconBg: const Color.fromARGB(255, 24, 211, 39),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            label: 'Expired',
                            value: expiredMembers,
                            icon: Icons.cancel_outlined,
                            iconColor: const Color.fromARGB(255, 250, 243, 243),
                            iconBg: const Color.fromARGB(246, 255, 2, 40),
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            label: 'Pending Payments',
                            value: pendingPayments,
                            icon: Icons.access_time_outlined,
                            iconColor: const Color.fromARGB(255, 255, 250, 243),
                            iconBg: const Color.fromARGB(255, 247, 142, 22),
                          ),
                          const SizedBox(height: 24),

                          // ── Recent Activity ──────────────────
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
                                .map((item) => _buildActivityItem(item))
                                .toList(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 4,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Hamburger opens drawer
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            ),
          ),

          // Logo pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.fitness_center, size: 14, color: AppTheme.primary),
                SizedBox(width: 4),
                Text(
                  'GymFitex',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Admin Panel',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),

          // Live Updates badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.bolt, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Live Updates',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Card ─────────────────────────────────────────────────
  Widget _buildStatCard({
    required String label,
    required int value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
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

  // ── Activity Item ─────────────────────────────────────────────
  Widget _buildActivityItem(Map<String, dynamic> item) {
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

  // ── Bottom Nav ────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', isActive: true),
              _navItem(
                Icons.people_outline,
                'Members',
                onTap: () => Get.toNamed('/admin/members'),
              ),
              _navItem(
                Icons.bar_chart_outlined,
                'Reports',
                onTap: () => Get.toNamed('/admin/reports'),
              ),
              _navItem(
                Icons.person_outline,
                'Profile',
                onTap: () => Get.toNamed('/admin/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
