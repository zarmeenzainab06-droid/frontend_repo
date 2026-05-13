import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/theme.dart';

class MemberDashboard extends StatefulWidget {
  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final box = GetStorage();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    final user = box.read('user');
    _userName = user?['name'] ?? 'Member';
  }

  void _logout() {
    box.remove('token');
    box.remove('user');
    box.remove('role');
    box.remove('isLoggedIn');
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      // ── Side Drawer ──────────────────────────────────────────
      drawer: _buildDrawer(),

      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome text
                  Text(
                    'Welcome back, $_userName!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Here's your fitness journey overview",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Placeholder cards — will be wired to API later
                  _buildPlaceholderCard(
                    'Membership Status',
                    Icons.card_membership_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildPlaceholderCard(
                    'Next Payment',
                    Icons.attach_money_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildPlaceholderCard(
                    'Workout Sessions',
                    Icons.fitness_center_outlined,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlaceholderCard(
                    'Activity will appear here',
                    Icons.history_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Nav ───────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          // Hamburger icon opens drawer
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
                  'GymSwift',
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
            'Member Portal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Side Drawer ──────────────────────────────────────────────
  Widget _buildDrawer() {
    final initial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'M';
    final role = box.read('role') ?? 'user';

    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              color: AppTheme.primary,
              child: Row(
                children: [
                  // Avatar circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
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
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role == 'admin' ? 'Administrator' : 'Premium Member',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
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

            // Menu items
            _drawerItem(
              Icons.calendar_month_outlined,
              'My Schedule',
              onTap: () {
                Get.back();
                // TODO: Get.toNamed('/member/schedule');
              },
            ),
            _drawerItem(
              Icons.emoji_events_outlined,
              'Achievements',
              onTap: () {
                Get.back();
                // TODO: Get.toNamed('/member/achievements');
              },
            ),
            _drawerItem(
              Icons.bar_chart_outlined,
              'Progress Tracker',
              onTap: () {
                Get.back();
                // TODO: Get.toNamed('/member/progress');
              },
            ),
            _drawerItem(
              Icons.settings_outlined,
              'Settings',
              onTap: () {
                Get.back();
                // TODO: Get.toNamed('/member/settings');
              },
            ),
            _drawerItem(
              Icons.help_outline,
              'Help & Support',
              onTap: () {
                Get.back();
                // TODO: Get.toNamed('/member/help');
              },
            ),

            const Spacer(),

            // Logout
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

  Widget _drawerItem(IconData icon, String label, {VoidCallback? onTap}) {
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
        hoverColor: AppTheme.primaryLight,
      ),
    );
  }

  // ── Placeholder Card ─────────────────────────────────────────
  Widget _buildPlaceholderCard(String label, IconData icon) {
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
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
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
                Icons.card_membership_outlined,
                'Membership',
                onTap: () {
                  // TODO: Get.toNamed('/member/membership');
                },
              ),
              _navItem(
                Icons.person_outline,
                'Trainer',
                onTap: () {
                  // TODO: Get.toNamed('/member/trainer');
                },
              ),
              _navItem(
                Icons.account_circle_outlined,
                'Profile',
                onTap: () {
                  // TODO: Get.toNamed('/member/profile');
                },
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
