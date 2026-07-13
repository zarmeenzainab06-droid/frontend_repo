import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/theme.dart';
import 'app_drawer.dart';
import '../../screens/dashboard/member_payment_screen.dart';
import '../../screens/dashboard/member_plans_screen.dart';
import '../../screens/dashboard/member_trainer.dart';
import '../../screens/dashboard/member_profile.dart';
import 'notification_bell.dart';

class MemberLayout extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final String title;

  const MemberLayout({
    super.key,
    required this.body,
    required this.currentIndex,
    this.title = 'Member Portal',
  });

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
      drawer: const AppDrawer(role: 'user'),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Same gradient top-bar look as the admin header (AppShell), minus the
  // "Live Updates" pill — just hamburger + icon badge + brand/subtitle + bell.
  Widget _buildTopBar(BuildContext context) {
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

          // Icon badge (same style as admin header)
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

          // Brand name + subtitle (no white pill)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GymFitex',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const NotificationBell(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', 0),
              _navItem(Icons.card_membership, 'Membership', 1),
              _navItem(Icons.payment_outlined, 'Payments', 2),
              _navItem(Icons.fitness_center_outlined, 'Trainer', 3),
              _navItem(Icons.account_circle_outlined, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;
    return InkWell(
      onTap: () {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            Get.offAllNamed('/dashboard');
            break;
          case 1:
            Get.offNamed('/member_membership');
            break;
          case 2:
            Get.to(() => MemberPaymentScreen());
            break;
          case 3:
            Get.to(() => MemberTrainerScreen());
            break;
          case 4:
            Get.to(() => MemberProfileScreen());
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      ),
    );
  }
}
