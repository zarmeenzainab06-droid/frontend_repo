import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:third_task/core/utils/theme.dart';

class TrainerDrawer extends StatelessWidget {
  const TrainerDrawer({Key? key}) : super(key: key);

  String get _userName {
    final user = GetStorage().read('user');
    if (user == null) return 'Trainer';
    return user['name'] ?? 'Trainer';
  }

  String get _initial =>
      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'T';

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final box = GetStorage();
              box.remove('token');
              box.remove('user');
              box.remove('role');
              box.remove('isLoggedIn');
              Get.offAllNamed('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: Column(
        children: [
          // ── Red Header ──────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppTheme.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 16,
              bottom: 24,
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name + role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Trainer',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Close X
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

          // ── Menu Items ──────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _menuItem(
                  context: context,
                  icon: Icons.people_outline_rounded,
                  label: 'My Members',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/trainer/members');
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.calendar_month_outlined,
                  label: 'Schedule',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/trainer/schedule');
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.bar_chart_outlined,
                  label: 'Performance Report',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Performance report will be available soon',
                      backgroundColor: AppTheme.surface,
                      colorText: AppTheme.textPrimary,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Settings will be available soon',
                      backgroundColor: AppTheme.surface,
                      colorText: AppTheme.textPrimary,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Help & Support will be available soon',
                      backgroundColor: AppTheme.surface,
                      colorText: AppTheme.textPrimary,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Logout ──────────────────────────────────────────
          const Divider(height: 1, color: AppTheme.border),
          ListTile(
            onTap: () => _logout(context),
            leading: const Icon(
              Icons.logout_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _menuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
    );
  }
}
