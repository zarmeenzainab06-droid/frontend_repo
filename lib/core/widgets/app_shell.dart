import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/theme.dart';
import 'app_drawer.dart';

/// AppShell wraps every screen with:
/// - Red top bar (GymFitex logo + hamburger + optional badge)
/// - Shared drawer (role-based via AppDrawer)
/// - Bottom nav (passed per screen since items differ)
///
/// Usage:
/// return AppShell(
///   role: 'admin',
///   subtitle: 'Admin Panel',
///   showLiveUpdates: true,
///   body: _buildBody(),
///   bottomNav: _buildBottomNav(),
/// );

class AppShell extends StatelessWidget {
  final String role; // 'admin' or 'user'
  final String subtitle; // e.g. 'Admin Panel' or 'Member Portal'
  final Widget body; // main content
  final Widget? bottomNav; // bottom navigation bar
  final bool showLiveUpdates; // show live updates badge (admin only)
  final List<AppShellAction>? actions; // optional right side actions

  const AppShell({
    Key? key,
    required this.role,
    required this.subtitle,
    required this.body,
    this.bottomNav,
    this.showLiveUpdates = false,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: AppDrawer(role: role),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: bottomNav,
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
          // Hamburger — opens drawer
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

          // Subtitle e.g. 'Admin Panel'
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),

          const Spacer(),

          // Live Updates badge (admin dashboard only)
          if (showLiveUpdates)
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

          // Optional extra actions
          if (actions != null)
            ...actions!.map(
              (a) => IconButton(
                onPressed: a.onTap,
                icon: Icon(a.icon, color: Colors.white, size: 22),
                tooltip: a.tooltip,
              ),
            ),
        ],
      ),
    );
  }
}

/// Optional action button for top bar right side
class AppShellAction {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const AppShellAction({required this.icon, required this.onTap, this.tooltip});
}

/// Reusable bottom nav bar used across admin screens
class AdminBottomNav extends StatelessWidget {
  final int activeIndex; // 0=Home, 1=Members, 2=Reports, 3=Profile

  const AdminBottomNav({Key? key, required this.activeIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              _item(
                context,
                Icons.home_outlined,
                'Home',
                0,
                onTap: () => Get.offNamed('/admin-dashboard'),
              ),
              _item(
                context,
                Icons.people_outline,
                'Members',
                1,
                onTap: () => Get.offNamed('/admin/members'),
              ),
              _item(
                context,
                Icons.bar_chart_outlined,
                'Reports',
                2,
                onTap: () => Get.toNamed('/admin/reports'),
              ),
              _item(
                context,
                Icons.person_outline,
                'Profile',
                3,
                onTap: () => Get.offNamed('/admin/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    int index, {
    VoidCallback? onTap,
  }) {
    final isActive = index == activeIndex;
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

/// Reusable bottom nav bar for member screens
class MemberBottomNav extends StatelessWidget {
  final int activeIndex; // 0=Home, 1=Membership, 2=Trainer, 3=Profile

  const MemberBottomNav({Key? key, required this.activeIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              _item(
                Icons.home_outlined,
                'Home',
                0,
                onTap: () => Get.offNamed('/dashboard'),
              ),
              _item(
                Icons.card_membership_outlined,
                'Membership',
                1,
                onTap: () => Get.toNamed('/member/membership'),
              ),
              _item(
                Icons.person_outline,
                'Trainer',
                2,
                onTap: () => Get.toNamed('/member/trainer'),
              ),
              _item(
                Icons.account_circle_outlined,
                'Profile',
                3,
                onTap: () => Get.offNamed('/admin/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, int index, {VoidCallback? onTap}) {
    final isActive = index == activeIndex;
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
