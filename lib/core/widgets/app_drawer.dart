import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../screens/dashboard/member_plans_screen.dart';
import '../utils/theme.dart';
import '../../routes/app_routes.dart';

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

  Color _darken(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
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
            _buildHeader(userName, initial, subtitle),
            const SizedBox(height: 6),
            // Scrollable so the item list never overflows on shorter screens
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: role == 'admin' ? _adminItems() : _memberItems(),
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: _item(
                Icons.logout_outlined,
                'Logout',
                color: AppTheme.expired,
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────
  Widget _buildHeader(String userName, String initial, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _darken(AppTheme.primary, 0.18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Admin Drawer Items (same routes/logic as before) ───────
  List<Widget> _adminItems() {
    return [
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
          Get.back();
          Get.toNamed(AppRoutes.adminTrainers);
        },
      ),
      _item(
        Icons.access_time_outlined,
        'Time Slots',
        onTap: () {
          Get.back();
          Get.toNamed(AppRoutes.adminSlots);
        },
      ),
      _item(
        Icons.person_outline,
        'Profile',
        onTap: () {
          Get.back();
          Get.toNamed('/admin/profile');
        },
      ),
      _item(
        Icons.bar_chart_outlined,
        'Reports Settings',
        onTap: () => Get.back(),
      ),
      _item(Icons.settings_outlined, 'App Settings', onTap: () => Get.back()),
      _item(Icons.help_outline, 'Help & About', onTap: () => Get.back()),
    ];
  }

  // ── Member Drawer Items (same routes/logic as before) ──────
  List<Widget> _memberItems() {
    return [
      _item(
        Icons.home_outlined,
        'Home',
        onTap: () {
          Get.back();
          Get.offAllNamed('/dashboard');
        },
      ),
      _item(
        Icons.card_membership_outlined,
        'My Membership',
        onTap: () {
          Get.back();
          Get.toNamed('/member_membership');
        },
      ),
      _item(
        Icons.payment_outlined,
        'Payments',
        onTap: () {
          Get.back();
          Get.toNamed('/member-payment');
        },
      ),
      _item(
        Icons.fitness_center_outlined,
        'My Trainer',
        onTap: () {
          Get.back();
          Get.toNamed('/member_trainer');
        },
      ),
      _item(
        Icons.restaurant_outlined,
        'My Diet Plan',
        onTap: () {
          Get.back();
          Get.toNamed('/member_diet');
        },
      ),
      _item(
        Icons.card_membership_outlined,
        'Plans',
        onTap: () {
          Get.back();
          Get.to(() => const MemberPlansScreen());
        },
      ),
      _item(
        Icons.person_outline,
        'My Profile',
        onTap: () {
          Get.back();
          Get.toNamed('/member_profile');
        },
      ),
    ];
  }

  // ── Single Item ─────────────────────────────────────────────
  Widget _item(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Color? color,
  }) {
    final tint = color ?? AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: tint.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: tint),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: color ?? AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
