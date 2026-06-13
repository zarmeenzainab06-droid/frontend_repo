import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/theme.dart';
import '../../core/widgets/app_drawer.dart';

class MemberDashboard extends StatefulWidget {
  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final box = GetStorage();
  String _userName = '';
  int _currentIndex = 0; // ✅ Active tab track karne ke liye

  @override
  void initState() {
    super.initState();
    // ✅ Fix - userName sahi se nikalo
    _userName = box.read('userName') ?? 'Member';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const AppDrawer(role: 'user'),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  // ✅ Cards clickable hain
                  GestureDetector(
                    onTap: () => Get.toNamed('/member-membership'),
                    onLongPress: () => Get.toNamed('/member-profile'),
                    onDoubleTap: () => Get.toNamed('/member-trainer'),
                    child: _placeholderCard(
                      'Membership Status',
                      Icons.card_membership_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onDoubleTap: () => Get.toNamed('/member-trainer'),
                    child: _placeholderCard('My Trainer', Icons.person_outline),
                  ),
                  const SizedBox(height: 12),
                  _placeholderCard('Next Payment', Icons.attach_money_outlined),
                  const SizedBox(height: 12),
                  _placeholderCard(
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
                  _placeholderCard(
                    'Activity will appear here',
                    Icons.history_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Top Bar ─────────────────────────────────────────
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
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
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
            'Member Portal',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderCard(String label, IconData icon) {
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

  // ── Bottom Nav ───────────────────────────────────────
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
              // ✅ Home - Active
              _navItem(
                Icons.home_outlined,
                'Home',
                isActive: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _navItem(
                Icons.card_membership_outlined,
                'Membership',
                isActive: _currentIndex == 1,
                onTap: () {
                  setState(() => _currentIndex = 1);
                  Get.toNamed('/member_membership');
                },
              ),
              _navItem(
                Icons.person_outline,
                'Trainer',
                isActive: _currentIndex == 2,
                onTap: () {
                  setState(() => _currentIndex = 2);
                  Get.toNamed('/member_trainer');
                },
              ),
              _navItem(
                Icons.account_circle_outlined,
                'Profile',
                isActive: _currentIndex == 3,
                onTap: () {
                  setState(() => _currentIndex = 3);
                  Get.toNamed('/member_profile');
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
    VoidCallback? onTap, // ✅ onTap parameter
  }) {
    return InkWell(
      onTap: onTap, // ✅ Ab kaam karega
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
