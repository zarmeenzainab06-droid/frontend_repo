import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/theme.dart';
import 'app_drawer.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const AppDrawer(role: 'user'),
      appBar: _buildAppBar(context),
      body: body,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primary, // ✅ Theme color
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center, size: 14, color: AppTheme.primary),
                const SizedBox(width: 4),
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
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', 0),
              _navItem(Icons.card_membership_outlined, 'Membership', 1),
              _navItem(Icons.fitness_center_outlined, 'Trainer', 2),
              _navItem(Icons.account_circle_outlined, 'Profile', 3),
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
            Get.offAllNamed('/member_membership');
            break;
          case 2:
            Get.offAllNamed('/member_trainer');
            break;
          case 3:
            Get.offAllNamed('/member_profile');
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 24,
                color: isActive ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}