import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/theme.dart';
import 'app_drawer.dart';
import 'notification_bell.dart';

/// AppShell wraps every screen with:
/// - Gradient top bar (hamburger + optional brand name + subtitle + optional badge)
/// - Shared drawer (role-based via AppDrawer)
/// - Bottom nav (passed per screen since items differ)
///
/// The top bar no longer hard-codes a brand/gym name — pass [brandName] if
/// you want one shown, or omit it to keep AppShell generic and reusable
/// across different apps/clients without editing this file.
///
/// Usage:
/// return AppShell(
///   role: 'admin',
///   subtitle: 'Admin Panel',
///   brandName: 'GymFitex', // optional
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
  final String? brandName; // optional brand/gym name shown in the top bar
  final bool showNotificationBell; // ← this line

  const AppShell({
    Key? key,
    required this.role,
    required this.subtitle,
    required this.body,
    this.bottomNav,
    this.showLiveUpdates = false,
    this.actions,
    this.brandName,
    this.showNotificationBell = false, // ← and this line
  }) : super(key: key);

  Color _darken(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

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
    final hasBrand = brandName != null && brandName!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, _darken(AppTheme.primary, 0.18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 4,
        right: 12,
        bottom: 14,
      ),
      child: Row(
        children: [
          // Hamburger — opens drawer
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Generic icon badge — no hardcoded app/gym name baked in
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),

          // Brand name (only if provided) + subtitle
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasBrand)
                  Text(
                    brandName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: hasBrand ? 12 : 14,
                    color: hasBrand
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white,
                    fontWeight: hasBrand ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Live Updates badge (admin dashboard only)
          if (showLiveUpdates)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Live Updates',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          // Notification bell (opt-in per screen)
          if (showNotificationBell) const NotificationBell(),
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
