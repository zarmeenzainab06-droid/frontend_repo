import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/theme.dart';
import 'package:third_task/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final String role; // 'admin' or 'user'
  const AppDrawer({Key? key, required this.role}) : super(key: key);

  void _logout() {
    final box = GetStorage();
    box.remove('token');
    box.remove('user');
    box.remove('role');
    box.remove('isLoggedIn');
    box.remove('userName');
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final user = box.read('user');
    final userName = user?['name'] ?? 'User';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final subtitle = role == 'admin' ? 'Administrator' : 'Premium Member';

    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              color: AppTheme.primary,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Menu Items (role-based) ─────────────────────────
            if (role == 'admin') ..._adminItems(),
            if (role == 'user') ..._memberItems(),

            const Spacer(),

            // ── Logout ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: ListTile(
                onTap: _logout,
                leading: const Icon(
                  Icons.logout_outlined,
                  color: AppTheme.expired,
                  size: 22,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppTheme.expired,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Admin Drawer Items ──────────────────────────────────────
  List<Widget> _adminItems() {
    return [
      // try
      _item(
        Icons.home_outlined,
        'Dashboard',
        onTap: () {
          Get.back();
          Get.toNamed('/admin-dashboard');
        },
      ),
      _item(
        Icons.card_membership_outlined,
        'Manage Packages',
        onTap: () {
          Get.back();
          Get.toNamed('/admin/packages');
        },
      ),
      _item(
        Icons.payment_outlined,
        'Payments & Transactions',
        onTap: () => Get.toNamed('/admin/payments'),
      ),
      _item(
        Icons.people_outline,
        'Manage Trainers',
        onTap: () {
          Get.back(); // close drawer
          Get.toNamed(AppRoutes.adminTrainers);
        },
      ),

      _item(
        Icons.access_time_outlined,
        'Time Slots',
        onTap: () {
          Get.back(); // close drawer
          Get.toNamed(AppRoutes.adminSlots);
        },
      ),
      //try
      _item(
        Icons.person_outline,
        'Profile',
        onTap: () {
          Get.back(); // close drawer
          Get.toNamed('/admin/profile');
        },
      ),
      _item(
        Icons.bar_chart_outlined,
        'Reports Settings',
        onTap: () => Get.back(), // placeholder
      ),
      _item(
        Icons.settings_outlined,
        'App Settings',
        onTap: () => Get.back(), // placeholder
      ),
      _item(
        Icons.help_outline,
        'Help & About',
        onTap: () => Get.back(), // placeholder
      ),
    ];
  }

  // ── Member Drawer Items ─────────────────────────────────────
  List<Widget> _memberItems() {
    return [
      _item(
        Icons.calendar_month_outlined,
        'My Schedule',
        onTap: () => Get.back(), // placeholder
      ),
      _item(
        Icons.emoji_events_outlined,
        'Achievements',
        onTap: () => Get.back(), // placeholder
      ),
      _item(
        Icons.bar_chart_outlined,
        'Progress Tracker',
        onTap: () => Get.back(), // placeholder
      ),
      _item(
        Icons.settings_outlined,
        'Settings',
        onTap: () => Get.back(), // placeholder
      ),
      _item(
        Icons.help_outline,
        'Help & Support',
        onTap: () => Get.back(), // placeholder
      ),
    ];
  }

  // ── Single Item ─────────────────────────────────────────────
  Widget _item(IconData icon, String label, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}
