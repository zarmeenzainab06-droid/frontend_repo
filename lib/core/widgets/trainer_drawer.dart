import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/theme.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF757575), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF757575)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
    final String currentRoute = Get.currentRoute;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Red Header ──────────────────────────────────────
          Container(
            width: double.infinity,
            color: const Color(0xFFE53935),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 16,
              bottom: 24,
            ),
            child: Row(
              children: [
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
                  icon: Icons.home_outlined,
                  label: 'Dashboard',
                  isActive: currentRoute == '/trainer-dashboard',
                  onTap: () {
                    Get.back();
                    if (currentRoute != '/trainer-dashboard') {
                      Get.offNamed('/trainer-dashboard');
                    }
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.people_outline_rounded,
                  label: 'My Members',
                  isActive: currentRoute == '/trainer/members',
                  onTap: () {
                    Get.back();
                    if (currentRoute != '/trainer/members') {
                      Get.toNamed('/trainer/members');
                    }
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.restaurant_menu_outlined,
                  label: 'Diet Plans',
                  isActive: currentRoute == '/trainer/diet-plans',
                  onTap: () {
                    Get.back();
                    if (currentRoute != '/trainer/diet-plans') {
                      Get.toNamed('/trainer/diet-plans');
                    }
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.calendar_month_outlined,
                  label: 'Schedule',
                  isActive: currentRoute == '/trainer/schedule',
                  onTap: () {
                    Get.back();
                    if (currentRoute != '/trainer/schedule') {
                      Get.toNamed('/trainer/schedule');
                    }
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.bar_chart_outlined,
                  label: 'Performance Report',
                  isActive: false,
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Performance report will be available soon',
                      backgroundColor: Colors.white,
                      colorText: const Color(0xFF212121),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isActive: false,
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Settings will be available soon',
                      backgroundColor: Colors.white,
                      colorText: const Color(0xFF212121),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  isActive: false,
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Coming Soon',
                      'Help & Support will be available soon',
                      backgroundColor: Colors.white,
                      colorText: const Color(0xFF212121),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                    );
                  },
                ),
                _menuItem(
                  context: context,
                  icon: Icons.person_outline,
                  label: 'Profile',
                  isActive: currentRoute == '/trainer/profile',
                  onTap: () {
                    Get.back();
                    if (currentRoute != '/trainer/profile') {
                      Get.toNamed('/trainer/profile');
                    }
                  },
                ),
              ],
            ),
          ),

          // ── Logout ──────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          ListTile(
            onTap: () => _logout(context),
            leading: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFE53935),
              size: 22,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE53935),
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
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isActive ? const Color(0xFFE53935) : const Color(0xFF757575),
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? const Color(0xFFE53935) : const Color(0xFF212121),
        ),
      ),
      tileColor: isActive ? const Color(0xFFFFEBEE) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}
